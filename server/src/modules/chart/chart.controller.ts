/**
 * 星盘控制器
 */
import { Router, Request, Response } from 'express';
import prisma from '../../config/database';
import { authRequired, vipRequired } from '../../middleware/auth.middleware';
import { aiService } from '../../services/ai.service';

const router = Router();

/**
 * 获取我的星盘
 * GET /chart/me
 */
router.get('/me', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;

    const chart = await prisma.natalChart.findUnique({
      where: { userId }
    });

    if (!chart) {
      return res.status(400).json({
        code: 12005,
        message: '请先填写出生信息',
        data: null
      });
    }

    return res.json({
      code: 0,
      message: 'success',
      data: {
        sunSign: chart.sunSign,
        sunDegree: Number(chart.sunDegree),
        moonSign: chart.moonSign,
        moonDegree: Number(chart.moonDegree),
        risingSign: chart.risingSign,
        risingDegree: Number(chart.risingDegree),
        planets: chart.planets,
        houses: chart.houses,
        aspects: chart.aspects,
        elements: {
          fire: chart.elementFire,
          earth: chart.elementEarth,
          air: chart.elementAir,
          water: chart.elementWater
        },
        modes: {
          cardinal: chart.modeCardinal,
          fixed: chart.modeFixed,
          mutable: chart.modeMutable
        }
      }
    });
  } catch (err) {
    const error = err as Error;
    console.error('Get chart error:', error);
    return res.status(500).json({
      code: 10000,
      message: '获取星盘失败',
      data: null
    });
  }
});

/**
 * 获取星盘解读
 * GET /chart/interpretation
 */
router.get('/interpretation', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const type = req.query.type as string || 'basic';

    const chart = await prisma.natalChart.findUnique({
      where: { userId }
    });

    if (!chart) {
      return res.status(400).json({
        code: 12005,
        message: '请先填写出生信息',
        data: null
      });
    }

    // 基础解读（太阳、月亮、上升）
    const interpretation = await aiService.generateChartInterpretation({
      sunSign: chart.sunSign,
      moonSign: chart.moonSign,
      risingSign: chart.risingSign,
      planets: chart.planets as Record<string, unknown>,
      type
    });

    // 检查是否已购买完整报告
    const hasPurchased = await prisma.purchase.findFirst({
      where: {
        userId,
        productType: 'deep_chart_report',
        status: 'completed'
      }
    });

    return res.json({
      code: 0,
      message: 'success',
      data: {
        sun: {
          sign: chart.sunSign,
          title: '核心性格',
          content: interpretation.sun
        },
        moon: {
          sign: chart.moonSign,
          title: '情感需求',
          content: interpretation.moon
        },
        rising: {
          sign: chart.risingSign,
          title: '外在形象',
          content: interpretation.rising
        },
        fullReportPrice: 18,
        hasFullReport: !!hasPurchased
      }
    });
  } catch (err) {
    const error = err as Error;
    console.error('Get interpretation error:', error);
    return res.status(500).json({
      code: 10000,
      message: '获取解读失败',
      data: null
    });
  }
});

/**
 * 购买深度星盘报告
 * POST /chart/report/purchase
 */
router.post('/report/purchase', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const { paymentChannel } = req.body;

    // 检查是否已购买
    const existing = await prisma.purchase.findFirst({
      where: {
        userId,
        productType: 'deep_chart_report',
        status: 'completed'
      }
    });

    if (existing) {
      return res.status(400).json({
        code: 13003,
        message: '您已购买过该商品',
        data: null
      });
    }

    // 创建订单
    const orderId = `ORDER_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    await prisma.order.create({
      data: {
        id: orderId,
        userId,
        productType: 'deep_chart_report',
        amount: 1800, // 18元
        payChannel: paymentChannel,
        status: 'pending',
        expireAt: new Date(Date.now() + 30 * 60 * 1000)
      }
    });

    // TODO: 调用支付接口获取支付参数

    return res.json({
      code: 0,
      message: 'success',
      data: {
        orderId,
        paymentParams: {} // 支付参数
      }
    });
  } catch (err) {
    const error = err as Error;
    console.error('Purchase report error:', error);
    return res.status(500).json({
      code: 10000,
      message: '创建订单失败',
      data: null
    });
  }
});

export default router;
