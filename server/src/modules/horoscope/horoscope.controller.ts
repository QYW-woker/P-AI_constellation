/**
 * 运势控制器
 */
import { Router, Request, Response } from 'express';
import prisma from '../../config/database';
import { getCacheService } from '../../config/redis';
import { authRequired, vipRequired } from '../../middleware/auth.middleware';
import { aiService } from '../../services/ai.service';
import { formatDate, getToday, addDays } from '../../utils/helpers';
import { CACHE_TTL, DISCLAIMER } from '../../config/constants';

const router = Router();
const cache = getCacheService();

/**
 * 获取今日运势
 * GET /horoscope/today
 */
router.get('/today', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const today = formatDate(getToday());

    // 先从缓存获取
    const cacheKey = `horoscope:${userId}:${today}`;
    const cached = await cache.get(cacheKey);
    if (cached) {
      return res.json({
        code: 0,
        message: 'success',
        data: cached
      });
    }

    // 查询用户星盘
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

    // 检查数据库是否有今日运势
    let horoscope = await prisma.dailyHoroscope.findUnique({
      where: {
        userId_date: {
          userId,
          date: getToday()
        }
      }
    });

    if (!horoscope) {
      // 生成运势
      const isPersonalized = user.isVip;
      const generated = await aiService.generateDailyHoroscope({
        sunSign: user.natalChart.sunSign,
        moonSign: user.natalChart.moonSign,
        risingSign: user.natalChart.risingSign,
        isPersonalized,
        date: today
      });

      // 保存到数据库
      horoscope = await prisma.dailyHoroscope.create({
        data: {
          userId,
          date: getToday(),
          summary: generated.summary,
          scoreOverall: generated.scores.overall,
          scoreLove: generated.scores.love,
          scoreCareer: generated.scores.career,
          scoreWealth: generated.scores.wealth,
          scoreSocial: generated.scores.social,
          doList: generated.doList,
          dontList: generated.dontList,
          luckyColor: generated.lucky.color,
          luckyNumber: generated.lucky.number,
          luckyDirection: generated.lucky.direction,
          luckyTime: generated.lucky.time,
          isPersonalized
        }
      });
    }

    const responseData = {
      date: today,
      summary: horoscope.summary,
      scores: {
        overall: horoscope.scoreOverall,
        love: horoscope.scoreLove,
        career: horoscope.scoreCareer,
        wealth: horoscope.scoreWealth,
        social: horoscope.scoreSocial
      },
      doList: horoscope.doList,
      dontList: horoscope.dontList,
      lucky: {
        color: horoscope.luckyColor,
        number: horoscope.luckyNumber,
        direction: horoscope.luckyDirection,
        time: horoscope.luckyTime
      },
      isPersonalized: horoscope.isPersonalized,
      disclaimer: DISCLAIMER
    };

    // 缓存24小时
    await cache.set(cacheKey, responseData, CACHE_TTL.horoscope);

    return res.json({
      code: 0,
      message: 'success',
      data: responseData
    });
  } catch (err) {
    const error = err as Error;
    console.error('Get today horoscope error:', error);
    return res.status(500).json({
      code: 10000,
      message: '获取运势失败',
      data: null
    });
  }
});

/**
 * 获取历史运势
 * GET /horoscope/history
 */
router.get('/history', authRequired, vipRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const days = parseInt(req.query.days as string) || 7;

    const startDate = addDays(getToday(), -days);

    const horoscopes = await prisma.dailyHoroscope.findMany({
      where: {
        userId,
        date: {
          gte: startDate,
          lte: getToday()
        }
      },
      orderBy: { date: 'desc' }
    });

    return res.json({
      code: 0,
      message: 'success',
      data: {
        horoscopes: horoscopes.map(h => ({
          date: formatDate(h.date),
          scores: {
            overall: h.scoreOverall,
            love: h.scoreLove,
            career: h.scoreCareer,
            wealth: h.scoreWealth,
            social: h.scoreSocial
          },
          summary: h.summary,
          isPersonalized: h.isPersonalized
        }))
      }
    });
  } catch (err) {
    const error = err as Error;
    console.error('Get history error:', error);
    return res.status(500).json({
      code: 10000,
      message: '获取历史运势失败',
      data: null
    });
  }
});

export default router;
