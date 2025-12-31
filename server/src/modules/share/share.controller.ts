/**
 * 分享控制器
 */
import { Router, Request, Response } from 'express';
import prisma from '../../config/database';
import { authRequired } from '../../middleware/auth.middleware';
import { formatDate, getToday } from '../../utils/helpers';

const router = Router();

/**
 * 生成运势分享卡片
 * POST /share/horoscope
 */
router.post('/horoscope', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const { date, style = 'default', size = 'story' } = req.body;

    const targetDate = date ? new Date(date) : getToday();

    // 获取运势数据
    const horoscope = await prisma.dailyHoroscope.findUnique({
      where: {
        userId_date: {
          userId,
          date: targetDate
        }
      }
    });

    if (!horoscope) {
      return res.status(400).json({
        code: 10001,
        message: '运势数据不存在',
        data: null
      });
    }

    // 获取用户星盘
    const chart = await prisma.natalChart.findUnique({
      where: { userId }
    });

    // TODO: 实际生成图片
    // 这里返回一个模拟的URL
    const imageUrl = `https://cdn.yourapp.com/share/horoscope_${userId}_${formatDate(targetDate)}.png`;

    return res.json({
      code: 0,
      message: 'success',
      data: {
        imageUrl,
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
      }
    });
  } catch (err) {
    const error = err as Error;
    console.error('Generate horoscope share card error:', error);
    return res.status(500).json({
      code: 10000,
      message: '生成分享卡片失败',
      data: null
    });
  }
});

/**
 * 生成配对分享卡片
 * POST /share/compatibility
 */
router.post('/compatibility', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const { friendId, style = 'default', size = 'square' } = req.body;

    if (!friendId) {
      return res.status(400).json({
        code: 10001,
        message: '好友ID不能为空',
        data: null
      });
    }

    // 检查好友关系
    const friendship = await prisma.friendship.findUnique({
      where: {
        userId_friendId: { userId, friendId }
      }
    });

    if (!friendship) {
      return res.status(400).json({
        code: 10001,
        message: '请先添加好友',
        data: null
      });
    }

    // TODO: 实际生成图片
    const imageUrl = `https://cdn.yourapp.com/share/compatibility_${userId}_${friendId}.png`;

    return res.json({
      code: 0,
      message: 'success',
      data: {
        imageUrl
      }
    });
  } catch (err) {
    const error = err as Error;
    console.error('Generate compatibility share card error:', error);
    return res.status(500).json({
      code: 10000,
      message: '生成分享卡片失败',
      data: null
    });
  }
});

/**
 * 生成星座性格卡片
 * POST /share/profile
 */
router.post('/profile', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const { style = 'default', size = 'story' } = req.body;

    // 获取用户信息和星盘
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { natalChart: true }
    });

    if (!user?.natalChart) {
      return res.status(400).json({
        code: 12005,
        message: '请先填写出生信息',
        data: null
      });
    }

    // TODO: 实际生成图片
    const imageUrl = `https://cdn.yourapp.com/share/profile_${userId}.png`;

    return res.json({
      code: 0,
      message: 'success',
      data: {
        imageUrl
      }
    });
  } catch (err) {
    const error = err as Error;
    console.error('Generate profile share card error:', error);
    return res.status(500).json({
      code: 10000,
      message: '生成分享卡片失败',
      data: null
    });
  }
});

export default router;
