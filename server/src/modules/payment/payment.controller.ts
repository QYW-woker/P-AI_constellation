/**
 * 支付控制器
 */
import { Router, Request, Response } from 'express';
import prisma from '../../config/database';
import { authRequired } from '../../middleware/auth.middleware';
import { paymentRateLimiter } from '../../middleware/rate-limit';
import { MEMBERSHIP_PLANS, PRODUCT_PRICES } from '../../config/constants';
import { generateOrderId, addDays } from '../../utils/helpers';

const router = Router();

/**
 * 获取会员套餐
 * GET /membership/plans
 */
router.get('/membership/plans', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;

    // 获取当前会员信息
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { isVip: true, vipExpireAt: true }
    });

    let currentPlan = null;
    if (user?.isVip && user.vipExpireAt && user.vipExpireAt > new Date()) {
      const membership = await prisma.membership.findFirst({
        where: { userId, status: 'active' },
        orderBy: { createdAt: 'desc' }
      });
      if (membership) {
        currentPlan = {
          plan: membership.plan,
          expireAt: user.vipExpireAt.toISOString()
        };
      }
    }

    return res.json({
      code: 0,
      message: 'success',
      data: {
        plans: MEMBERSHIP_PLANS,
        currentPlan
      }
    });
  } catch (err) {
    const error = err as Error;
    console.error('Get membership plans error:', error);
    return res.status(500).json({
      code: 10000,
      message: '获取套餐失败',
      data: null
    });
  }
});

/**
 * 创建会员订单
 * POST /membership/order
 */
router.post('/membership/order', authRequired, paymentRateLimiter, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const { planId, paymentChannel } = req.body;

    // 验证套餐
    const plan = MEMBERSHIP_PLANS.find(p => p.id === planId);
    if (!plan) {
      return res.status(400).json({
        code: 10001,
        message: '套餐不存在',
        data: null
      });
    }

    // 创建订单
    const orderId = generateOrderId();

    await prisma.order.create({
      data: {
        id: orderId,
        userId,
        productType: `membership_${planId}`,
        amount: plan.price,
        payChannel: paymentChannel,
        status: 'pending',
        expireAt: new Date(Date.now() + 30 * 60 * 1000)
      }
    });

    // 根据支付渠道返回支付参数
    if (paymentChannel === 'wechat') {
      // TODO: 调用微信支付API获取支付参数
      return res.json({
        code: 0,
        message: 'success',
        data: {
          orderId,
          wechatPayParams: {
            appId: '',
            partnerId: '',
            prepayId: '',
            nonceStr: '',
            timeStamp: '',
            sign: ''
          }
        }
      });
    } else if (paymentChannel === 'apple') {
      return res.json({
        code: 0,
        message: 'success',
        data: {
          orderId,
          appleProductId: plan.appleProductId
        }
      });
    }

    return res.status(400).json({
      code: 10001,
      message: '不支持的支付渠道',
      data: null
    });
  } catch (err) {
    const error = err as Error;
    console.error('Create membership order error:', error);
    return res.status(500).json({
      code: 10000,
      message: '创建订单失败',
      data: null
    });
  }
});

/**
 * 验证苹果支付
 * POST /membership/apple/verify
 */
router.post('/membership/apple/verify', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const { orderId, receipt } = req.body;

    // 查询订单
    const order = await prisma.order.findUnique({
      where: { id: orderId }
    });

    if (!order || order.userId !== userId) {
      return res.status(400).json({
        code: 13001,
        message: '订单不存在',
        data: null
      });
    }

    if (order.status !== 'pending') {
      return res.status(400).json({
        code: 10001,
        message: '订单状态异常',
        data: null
      });
    }

    // TODO: 验证苹果收据

    // 更新订单状态
    await prisma.order.update({
      where: { id: orderId },
      data: {
        status: 'paid',
        paidAt: new Date()
      }
    });

    // 发放会员权益
    const planDuration: Record<string, number> = {
      'membership_monthly': 30,
      'membership_quarterly': 90,
      'membership_yearly': 365
    };

    const days = planDuration[order.productType] || 30;
    const user = await prisma.user.findUnique({ where: { id: userId } });

    const now = new Date();
    const currentExpire = user?.vipExpireAt && user.vipExpireAt > now
      ? user.vipExpireAt
      : now;

    const newExpire = addDays(currentExpire, days);

    await prisma.user.update({
      where: { id: userId },
      data: {
        isVip: true,
        vipExpireAt: newExpire
      }
    });

    // 创建会员记录
    await prisma.membership.create({
      data: {
        userId,
        plan: order.productType.replace('membership_', ''),
        price: order.amount / 100,
        startDate: now,
        endDate: newExpire,
        status: 'active',
        paymentChannel: 'apple',
        transactionId: orderId
      }
    });

    return res.json({
      code: 0,
      message: 'success',
      data: {
        success: true,
        membership: {
          plan: order.productType,
          startDate: now.toISOString(),
          endDate: newExpire.toISOString()
        }
      }
    });
  } catch (err) {
    const error = err as Error;
    console.error('Apple verify error:', error);
    return res.status(500).json({
      code: 10000,
      message: '验证失败',
      data: null
    });
  }
});

/**
 * 微信支付回调
 * POST /membership/wechat/callback
 */
router.post('/membership/wechat/callback', async (req: Request, res: Response) => {
  try {
    // TODO: 验证微信回调签名
    // TODO: 处理支付结果

    res.set('Content-Type', 'application/xml');
    res.send('<xml><return_code><![CDATA[SUCCESS]]></return_code></xml>');
  } catch (err) {
    const error = err as Error;
    console.error('Wechat callback error:', error);
    res.set('Content-Type', 'application/xml');
    res.send('<xml><return_code><![CDATA[FAIL]]></return_code></xml>');
  }
});

export default router;
