/**
 * 好友控制器
 */
import { Router, Request, Response } from 'express';
import prisma from '../../config/database';
import { authRequired } from '../../middleware/auth.middleware';
import { maskPhone } from '../../utils/filter';
import { generateInviteCode } from '../../utils/helpers';
import { FREE_USER_FRIEND_LIMIT, ERROR_CODES } from '../../config/constants';
import { astrologyService } from '../../services/astrology.service';

const router = Router();

/**
 * 获取好友列表
 * GET /friends
 */
router.get('/', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const skip = (page - 1) * limit;

    const [friends, total] = await Promise.all([
      prisma.friendship.findMany({
        where: { userId, status: 1 },
        include: {
          friend: {
            include: { natalChart: true }
          }
        },
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' }
      }),
      prisma.friendship.count({
        where: { userId, status: 1 }
      })
    ]);

    return res.json({
      code: 0,
      message: 'success',
      data: {
        friends: friends.map(f => ({
          id: f.id,
          friendId: f.friendId,
          nickname: f.friend.nickname || '未设置昵称',
          avatarUrl: f.friend.avatarUrl,
          sunSign: f.friend.natalChart?.sunSign,
          compatibilityScore: f.compatibilityScore,
          addedAt: f.createdAt.toISOString()
        })),
        total,
        page,
        limit
      }
    });
  } catch (err) {
    const error = err as Error;
    console.error('Get friends error:', error);
    return res.status(500).json({
      code: 10000,
      message: '获取好友列表失败',
      data: null
    });
  }
});

/**
 * 搜索用户（通过手机号）
 * GET /friends/search
 */
router.get('/search', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const phone = req.query.phone as string;

    if (!phone || !/^1[3-9]\d{9}$/.test(phone)) {
      return res.status(400).json({
        code: 10001,
        message: '手机号格式错误',
        data: null
      });
    }

    const user = await prisma.user.findUnique({
      where: { phone },
      include: { natalChart: true }
    });

    if (!user) {
      return res.json({
        code: 0,
        message: 'success',
        data: {
          user: null,
          needInvite: true
        }
      });
    }

    // 检查是否已是好友
    const friendship = await prisma.friendship.findUnique({
      where: {
        userId_friendId: { userId, friendId: user.id }
      }
    });

    return res.json({
      code: 0,
      message: 'success',
      data: {
        user: {
          id: user.id,
          nickname: user.nickname || '未设置昵称',
          avatarUrl: user.avatarUrl,
          sunSign: user.natalChart?.sunSign,
          isFriend: !!friendship && friendship.status === 1
        }
      }
    });
  } catch (err) {
    const error = err as Error;
    console.error('Search user error:', error);
    return res.status(500).json({
      code: 10000,
      message: '搜索失败',
      data: null
    });
  }
});

/**
 * 添加好友
 * POST /friends/add
 */
router.post('/add', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const { friendId } = req.body;

    if (!friendId) {
      return res.status(400).json({
        code: 10001,
        message: '好友ID不能为空',
        data: null
      });
    }

    // 不能添加自己
    if (friendId === userId) {
      return res.status(400).json({
        code: 12003,
        message: ERROR_CODES[12003],
        data: null
      });
    }

    // 检查好友是否存在
    const friend = await prisma.user.findUnique({
      where: { id: friendId }
    });

    if (!friend) {
      return res.status(400).json({
        code: 11005,
        message: '用户不存在',
        data: null
      });
    }

    // 检查是否已是好友
    const existing = await prisma.friendship.findUnique({
      where: {
        userId_friendId: { userId, friendId }
      }
    });

    if (existing && existing.status === 1) {
      return res.status(400).json({
        code: 12002,
        message: ERROR_CODES[12002],
        data: null
      });
    }

    // 检查好友数量限制（非会员）
    if (!req.user!.isVip) {
      const friendCount = await prisma.friendship.count({
        where: { userId, status: 1 }
      });

      if (friendCount >= FREE_USER_FRIEND_LIMIT) {
        return res.status(400).json({
          code: 12001,
          message: `免费用户最多添加${FREE_USER_FRIEND_LIMIT}位好友，升级会员可添加更多`,
          data: null
        });
      }
    }

    // 计算配对分数
    let compatibilityScore: number | undefined;
    const userChart = await prisma.natalChart.findUnique({ where: { userId } });
    const friendChart = await prisma.natalChart.findUnique({ where: { userId: friendId } });

    if (userChart && friendChart) {
      const result = astrologyService.calculateCompatibility(
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
      compatibilityScore = result.totalScore;
    }

    // 创建或更新好友关系（双向）
    if (existing) {
      await prisma.friendship.update({
        where: { id: existing.id },
        data: { status: 1, compatibilityScore }
      });
    } else {
      await prisma.friendship.create({
        data: { userId, friendId, status: 1, compatibilityScore }
      });
    }

    // 创建反向关系
    const reverseExisting = await prisma.friendship.findUnique({
      where: {
        userId_friendId: { userId: friendId, friendId: userId }
      }
    });

    if (reverseExisting) {
      await prisma.friendship.update({
        where: { id: reverseExisting.id },
        data: { status: 1, compatibilityScore }
      });
    } else {
      await prisma.friendship.create({
        data: { userId: friendId, friendId: userId, status: 1, compatibilityScore }
      });
    }

    return res.json({
      code: 0,
      message: 'success',
      data: {
        friendship: {
          friendId,
          compatibilityScore
        }
      }
    });
  } catch (err) {
    const error = err as Error;
    console.error('Add friend error:', error);
    return res.status(500).json({
      code: 10000,
      message: '添加好友失败',
      data: null
    });
  }
});

/**
 * 生成邀请链接
 * POST /friends/invite/link
 */
router.post('/invite/link', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const { channel } = req.body;

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { inviteCode: true }
    });

    if (!user) {
      return res.status(400).json({
        code: 11005,
        message: '用户不存在',
        data: null
      });
    }

    const inviteUrl = `https://app.yourapp.com/invite/${user.inviteCode}`;

    return res.json({
      code: 0,
      message: 'success',
      data: {
        inviteCode: user.inviteCode,
        inviteUrl,
        shareText: '我在用一个超准的星座App，快来看看咱俩配对多少分！',
        shareImage: null // TODO: 生成分享图片
      }
    });
  } catch (err) {
    const error = err as Error;
    console.error('Generate invite link error:', error);
    return res.status(500).json({
      code: 10000,
      message: '生成邀请链接失败',
      data: null
    });
  }
});

/**
 * 删除好友
 * DELETE /friends/:friendId
 */
router.delete('/:friendId', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const { friendId } = req.params;

    // 更新好友关系状态为已删除
    await prisma.friendship.updateMany({
      where: {
        OR: [
          { userId, friendId },
          { userId: friendId, friendId: userId }
        ]
      },
      data: { status: 0 }
    });

    return res.json({
      code: 0,
      message: '删除成功',
      data: null
    });
  } catch (err) {
    const error = err as Error;
    console.error('Delete friend error:', error);
    return res.status(500).json({
      code: 10000,
      message: '删除好友失败',
      data: null
    });
  }
});

export default router;
