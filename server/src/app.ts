/**
 * 应用入口
 * AI星座应用 - 后端服务
 */
import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';

import { appConfig } from './config';
import { testDatabaseConnection, disconnectDatabase } from './config/database';
import { testRedisConnection, disconnectRedis } from './config/redis';
import { globalRateLimiter } from './middleware/rate-limit';

// 导入路由
import authRouter from './modules/auth/auth.controller';
import userRouter from './modules/user/user.controller';
import chartRouter from './modules/chart/chart.controller';
import horoscopeRouter from './modules/horoscope/horoscope.controller';
import friendshipRouter from './modules/friendship/friendship.controller';
import compatibilityRouter from './modules/compatibility/compatibility.controller';
import paymentRouter from './modules/payment/payment.controller';
import shareRouter from './modules/share/share.controller';

const app: Express = express();

// ============================
// 中间件配置
// ============================

// 安全头
app.use(helmet({
  contentSecurityPolicy: false, // API服务器不需要CSP
  crossOriginEmbedderPolicy: false
}));

// CORS配置
app.use(cors({
  origin: true, // 开发阶段允许所有来源
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: [
    'Content-Type',
    'Authorization',
    'X-Timestamp',
    'X-Nonce',
    'X-Signature',
    'X-Device-Id',
    'X-Platform',
    'X-Version'
  ],
  credentials: true,
  maxAge: 86400
}));

// 压缩
app.use(compression());

// 请求日志
if (appConfig.nodeEnv !== 'test') {
  app.use(morgan('combined'));
}

// 请求体解析
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// 全局限流
app.use(globalRateLimiter);

// ============================
// 健康检查
// ============================
app.get('/health', (req: Request, res: Response) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    env: appConfig.nodeEnv
  });
});

// ============================
// API路由
// ============================
const apiPrefix = '/api/v1';

app.use(`${apiPrefix}/auth`, authRouter);
app.use(`${apiPrefix}/user`, userRouter);
app.use(`${apiPrefix}/chart`, chartRouter);
app.use(`${apiPrefix}/horoscope`, horoscopeRouter);
app.use(`${apiPrefix}/friends`, friendshipRouter);
app.use(`${apiPrefix}/compatibility`, compatibilityRouter);
app.use(`${apiPrefix}/payment`, paymentRouter);
app.use(`${apiPrefix}/share`, shareRouter);

// 城市搜索API（不需要认证）
app.get(`${apiPrefix}/cities/search`, async (req: Request, res: Response) => {
  try {
    const { q, limit = 10 } = req.query;
    const prisma = (await import('./config/database')).default;

    const cities = await prisma.city.findMany({
      where: {
        OR: [
          { name: { contains: q as string } },
          { pinyin: { contains: (q as string).toLowerCase() } }
        ]
      },
      take: Number(limit),
      select: {
        id: true,
        name: true,
        province: true,
        country: true
      }
    });

    res.json({
      code: 0,
      message: 'success',
      data: { cities }
    });
  } catch (error) {
    console.error('City search error:', error);
    res.status(500).json({
      code: 10000,
      message: '搜索失败',
      data: null
    });
  }
});

// 热门城市API
app.get(`${apiPrefix}/cities/hot`, async (req: Request, res: Response) => {
  try {
    const prisma = (await import('./config/database')).default;
    const cache = (await import('./config/redis')).getCacheService();

    // 先从缓存获取
    const cached = await cache.get<Array<{ id: number; name: string; province: string }>>('cities:hot');
    if (cached) {
      return res.json({
        code: 0,
        message: 'success',
        data: { cities: cached }
      });
    }

    // 从数据库获取
    const cities = await prisma.city.findMany({
      where: { isHot: true },
      select: {
        id: true,
        name: true,
        province: true
      },
      orderBy: { id: 'asc' }
    });

    // 缓存24小时
    await cache.set('cities:hot', cities, 86400);

    res.json({
      code: 0,
      message: 'success',
      data: { cities }
    });
  } catch (error) {
    console.error('Hot cities error:', error);
    res.status(500).json({
      code: 10000,
      message: '获取热门城市失败',
      data: null
    });
  }
});

// ============================
// 404处理
// ============================
app.use((req: Request, res: Response) => {
  res.status(404).json({
    code: 404,
    message: 'Not Found',
    data: null
  });
});

// ============================
// 错误处理
// ============================
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    code: 10000,
    message: appConfig.nodeEnv === 'development' ? err.message : '系统错误',
    data: null
  });
});

// ============================
// 启动服务器
// ============================
async function bootstrap() {
  try {
    console.log('🚀 Starting server...');
    console.log(`📍 Environment: ${appConfig.nodeEnv}`);

    // 测试数据库连接
    await testDatabaseConnection();

    // 测试Redis连接
    await testRedisConnection();

    // 启动HTTP服务器
    const server = app.listen(appConfig.port, () => {
      console.log(`✅ Server is running on port ${appConfig.port}`);
      console.log(`📡 API endpoint: http://localhost:${appConfig.port}${apiPrefix}`);
    });

    // 优雅关闭
    const gracefulShutdown = async (signal: string) => {
      console.log(`\n${signal} received. Starting graceful shutdown...`);

      server.close(async () => {
        console.log('HTTP server closed');

        try {
          await disconnectDatabase();
          await disconnectRedis();
          console.log('All connections closed');
          process.exit(0);
        } catch (error) {
          console.error('Error during shutdown:', error);
          process.exit(1);
        }
      });

      // 强制关闭超时
      setTimeout(() => {
        console.error('Forced shutdown due to timeout');
        process.exit(1);
      }, 10000);
    };

    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));

  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

// 启动
bootstrap();

export default app;
