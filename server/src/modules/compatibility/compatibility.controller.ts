/**
 * 配对控制器
 */
import { Router, Request, Response } from 'express';
import prisma from '../../config/database';
import { getCacheService } from '../../config/redis';
import { authRequired } from '../../middleware/auth.middleware';
import { astrologyService } from '../../services/astrology.service';
import { aiService } from '../../services/ai.service';
import { CACHE_TTL } from '../../config/constants';

const router = Router();
const cache = getCacheService();

/**
 * 获取配对详情
 * GET /compatibility/:friendId
 */
router.get('/:friendId', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const { friendId } = req.params;

    // 检查是否是好友
    const friendship = await prisma.friendship.findUnique({
      where: {
        userId_friendId: { userId, friendId }
      }
    });

    if (!friendship || friendship.status !== 1) {
      return res.status(400).json({
        code: 10001,
        message: '请先添加好友',
        data: null
      });
    }

    // 获取双方星盘
    const [userChart, friendChart, friend] = await Promise.all([
      prisma.natalChart.findUnique({ where: { userId } }),
      prisma.natalChart.findUnique({ where: { userId: friendId } }),
      prisma.user.findUnique({
        where: { id: friendId },
        include: { natalChart: true }
      })
    ]);

    if (!userChart || !friendChart) {
      return res.status(400).json({
        code: 12005,
        message: '双方需要先填写出生信息',
        data: null
      });
    }

    // 尝试从缓存获取配对分数
    const cacheKey = `compatibility:${[userId, friendId].sort().join(':')}`;
    let compatibility = await cache.get<{
      totalScore: number;
      dimensions: Record<string, number>;
    }>(cacheKey);

    if (!compatibility) {
      // 计算配对分数
      compatibility = astrologyService.calculateCompatibility(
        {
          sunSign: userChart.sunSign,
          sunDegree: Number(userChart.sunDegree),
          moonSign: userChart.moonSign,
          moonDegree: Number(userChart.moonDegree),
          risingSign: userChart.risingSign,
          risingDegree: Number(userChart.risingDegree),
          planets: userChart.planets as Record<string, { sign: string; degree: number }>,
          houses: userChart.houses as Record<string, { sign: string; degree: number }>,
          aspects: (userChart.aspects || []) as Array<{ planet1: string; planet2: string; aspect: string; orb: number }>,
          elements: {
            fire: userChart.elementFire,
            earth: userChart.elementEarth,
            air: userChart.elementAir,
            water: userChart.elementWater
          },
          modes: {
            cardinal: userChart.modeCardinal,
            fixed: userChart.modeFixed,
            mutable: userChart.modeMutable
          }
        },
        {
          sunSign: friendChart.sunSign,
          sunDegree: Number(friendChart.sunDegree),
          moonSign: friendChart.moonSign,
          moonDegree: Number(friendChart.moonDegree),
          risingSign: friendChart.risingSign,
          risingDegree: Number(friendChart.risingDegree),
          planets: friendChart.planets as Record<string, { sign: string; degree: number }>,
          houses: friendChart.houses as Record<string, { sign: string; degree: number }>,
          aspects: (friendChart.aspects || []) as Array<{ planet1: string; planet2: string; aspect: string; orb: number }>,
          elements: {
            fire: friendChart.elementFire,
            earth: friendChart.elementEarth,
            air: friendChart.elementAir,
            water: friendChart.elementWater
          },
          modes: {
            cardinal: friendChart.modeCardinal,
            fixed: friendChart.modeFixed,
            mutable: friendChart.modeMutable
          }
        }
      );

      // 永久缓存
      await cache.set(cacheKey, compatibility, -1);

      // 更新好友关系表中的分数
      await prisma.friendship.updateMany({
        where: {
          OR: [
            { userId, friendId },
            { userId: friendId, friendId: userId }
          ]
        },
        data: { compatibilityScore: compatibility.totalScore }
      });
    }

    // 检查是否已购买报告
    const report = await prisma.compatibilityReport.findUnique({
      where: {
        userId_friendId: { userId, friendId }
      }
    });

    // 生成简单摘要
    let summary = '';
    if (compatibility.totalScore >= 80) {
      summary = '你们是非常契合的组合，有着深层的理解和共鸣。';
    } else if (compatibility.totalScore >= 60) {
      summary = '你们是互补型的组合，有很强的吸引力，也需要相互理解。';
    } else {
      summary = '你们之间有一些挑战，但也有很大的成长空间。';
    }

    return res.json({
      code: 0,
      message: 'success',
      data: {
        friend: {
          id: friend!.id,
          nickname: friend!.nickname || '未设置昵称',
          sunSign: friendChart.sunSign,
          moonSign: friendChart.moonSign,
          risingSign: friendChart.risingSign
        },
        compatibility: {
          totalScore: compatibility.totalScore,
          summary,
          dimensions: {
            overall: { score: compatibility.dimensions.overall, preview: '整体契合度分析' },
            communication: { score: compatibility.dimensions.communication, preview: '沟通方式分析' },
            emotion: { score: compatibility.dimensions.emotion, preview: '情感需求分析' },
            values: { score: compatibility.dimensions.values, preview: '价值观分析' },
            attraction: { score: compatibility.dimensions.attraction, preview: '吸引力分析' },
            conflict: { score: compatibility.dimensions.conflict, preview: '潜在冲突分析' },
            growth: { score: compatibility.dimensions.growth, preview: '成长空间分析' }
          },
          isPurchased: report?.isPurchased || false,
          reportPrice: 9.9
        }
      }
    });
  } catch (err) {
    const error = err as Error;
    console.error('Get compatibility error:', error);
    return res.status(500).json({
      code: 10000,
      message: '获取配对信息失败',
      data: null
    });
  }
});

/**
 * 购买配对报告
 * POST /compatibility/:friendId/purchase
 */
router.post('/:friendId/purchase', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const { friendId } = req.params;
    const { paymentChannel } = req.body;

    // 检查是否已购买
    const existing = await prisma.compatibilityReport.findUnique({
      where: {
        userId_friendId: { userId, friendId }
      }
    });

    if (existing?.isPurchased) {
      return res.status(400).json({
        code: 13003,
        message: '您已购买过该报告',
        data: null
      });
    }

    // 创建订单
    const orderId = `ORDER_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    await prisma.order.create({
      data: {
        id: orderId,
        userId,
        productType: 'compatibility_report',
        productId: friendId,
        amount: 990, // 9.9元
        payChannel: paymentChannel,
        status: 'pending',
        expireAt: new Date(Date.now() + 30 * 60 * 1000)
      }
    });

    return res.json({
      code: 0,
      message: 'success',
      data: {
        orderId,
        paymentParams: {} // TODO: 支付参数
      }
    });
  } catch (err) {
    const error = err as Error;
    console.error('Purchase compatibility report error:', error);
    return res.status(500).json({
      code: 10000,
      message: '创建订单失败',
      data: null
    });
  }
});

/**
 * 获取已购买的配对报告详情
 * GET /compatibility/:friendId/report
 */
router.get('/:friendId/report', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const { friendId } = req.params;

    const report = await prisma.compatibilityReport.findUnique({
      where: {
        userId_friendId: { userId, friendId }
      }
    });

    if (!report || !report.isPurchased) {
      return res.status(400).json({
        code: 13001,
        message: '请先购买报告',
        data: null
      });
    }

    return res.json({
      code: 0,
      message: 'success',
      data: {
        totalScore: report.totalScore,
        summary: report.summary,
        dimensions: report.details,
        suggestions: report.suggestions,
        generatedAt: report.createdAt.toISOString()
      }
    });
  } catch (err) {
    const error = err as Error;
    console.error('Get compatibility report error:', error);
    return res.status(500).json({
      code: 10000,
      message: '获取报告失败',
      data: null
    });
  }
});

export default router;
