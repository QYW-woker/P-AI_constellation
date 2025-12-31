/**
 * 限流中间件
 * 使用Redis实现滑动窗口限流
 */
import { Request, Response, NextFunction } from 'express';
import { getCacheService } from '../config/redis';
import { RATE_LIMIT_CONFIG, ERROR_CODES } from '../config/constants';

interface RateLimitOptions {
  windowMs: number;      // 时间窗口（毫秒）
  max: number;           // 最大请求数
  keyPrefix?: string;    // 缓存key前缀
  keyGenerator?: (req: Request) => string; // 自定义key生成器
  message?: string;      // 超限提示消息
  skipSuccessfulRequests?: boolean; // 是否跳过成功请求
}

/**
 * 创建限流中间件
 */
export function createRateLimiter(options: RateLimitOptions) {
  const {
    windowMs,
    max,
    keyPrefix = 'ratelimit',
    keyGenerator = (req) => req.ip || 'unknown',
    message = ERROR_CODES[10002],
    skipSuccessfulRequests = false
  } = options;

  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const cache = getCacheService();
      const key = `${keyPrefix}:${keyGenerator(req)}`;

      const now = Date.now();
      const windowStart = now - windowMs;

      // 清除过期记录
      await cache.zremrangebyscore(key, 0, windowStart);

      // 获取当前窗口内的请求数
      const count = await cache.zcard(key);

      if (count >= max) {
        res.status(429).json({
          code: 10002,
          message,
          data: null
        });
        return;
      }

      // 添加当前请求
      await cache.zadd(key, now, `${now}-${Math.random()}`);

      // 设置过期时间
      const ttl = Math.ceil(windowMs / 1000);
      const currentTtl = await cache.ttl(key);
      if (currentTtl < 0) {
        await cache.expire(key, ttl);
      }

      // 设置响应头
      res.setHeader('X-RateLimit-Limit', max);
      res.setHeader('X-RateLimit-Remaining', Math.max(0, max - count - 1));
      res.setHeader('X-RateLimit-Reset', Math.ceil((now + windowMs) / 1000));

      next();
    } catch (error) {
      console.error('Rate limiter error:', error);
      // 限流器出错时允许请求通过
      next();
    }
  };
}

/**
 * 全局限流中间件
 */
export const globalRateLimiter = createRateLimiter({
  ...RATE_LIMIT_CONFIG.global,
  keyPrefix: 'ratelimit:global'
});

/**
 * 认证接口限流
 */
export const authRateLimiter = createRateLimiter({
  ...RATE_LIMIT_CONFIG.auth,
  keyPrefix: 'ratelimit:auth'
});

/**
 * 短信验证码限流
 */
export const smsRateLimiter = createRateLimiter({
  ...RATE_LIMIT_CONFIG.sms,
  keyPrefix: 'ratelimit:sms',
  keyGenerator: (req) => req.body?.phone || req.ip || 'unknown',
  message: '验证码发送过于频繁，请稍后再试'
});

/**
 * AI接口限流
 */
export const aiRateLimiter = createRateLimiter({
  ...RATE_LIMIT_CONFIG.ai,
  keyPrefix: 'ratelimit:ai',
  keyGenerator: (req) => req.user?.id || req.ip || 'unknown',
  message: 'AI服务繁忙，请稍后再试'
});

/**
 * 支付接口限流
 */
export const paymentRateLimiter = createRateLimiter({
  ...RATE_LIMIT_CONFIG.payment,
  keyPrefix: 'ratelimit:payment',
  keyGenerator: (req) => req.user?.id || req.ip || 'unknown',
  message: '操作过于频繁，请稍后再试'
});

/**
 * 短信发送限流检查（更严格）
 * 60秒内1次，1小时内5次
 */
export async function checkSmsLimit(phone: string): Promise<{
  allowed: boolean;
  message?: string;
}> {
  try {
    const cache = getCacheService();
    const minuteKey = `sms:minute:${phone}`;
    const hourKey = `sms:hour:${phone}`;

    // 检查60秒限制
    const minuteCount = await cache.get<number>(minuteKey);
    if (minuteCount && minuteCount >= 1) {
      return {
        allowed: false,
        message: '请60秒后再试'
      };
    }

    // 检查1小时限制
    const hourCount = await cache.get<number>(hourKey);
    if (hourCount && hourCount >= 5) {
      return {
        allowed: false,
        message: '发送次数过多，请1小时后再试'
      };
    }

    return { allowed: true };
  } catch (error) {
    console.error('Check SMS limit error:', error);
    return { allowed: true }; // 出错时允许发送
  }
}

/**
 * 记录短信发送
 */
export async function recordSmsSent(phone: string): Promise<void> {
  try {
    const cache = getCacheService();
    const minuteKey = `sms:minute:${phone}`;
    const hourKey = `sms:hour:${phone}`;

    // 记录60秒限制
    await cache.set(minuteKey, 1, 60);

    // 递增1小时计数
    await cache.incrWithExpire(hourKey, 3600);
  } catch (error) {
    console.error('Record SMS sent error:', error);
  }
}

/**
 * 登录失败次数检查
 */
export async function checkLoginAttempts(identifier: string): Promise<{
  allowed: boolean;
  remainingAttempts?: number;
  lockUntil?: Date;
}> {
  try {
    const cache = getCacheService();
    const attemptsKey = `login:attempts:${identifier}`;
    const lockKey = `login:lock:${identifier}`;

    // 检查是否被锁定
    const lockUntil = await cache.get<number>(lockKey);
    if (lockUntil && lockUntil > Date.now()) {
      return {
        allowed: false,
        lockUntil: new Date(lockUntil)
      };
    }

    // 获取失败次数
    const attempts = await cache.get<number>(attemptsKey) || 0;
    const maxAttempts = 10;

    if (attempts >= maxAttempts) {
      // 锁定30分钟
      const lockDuration = 30 * 60 * 1000;
      await cache.set(lockKey, Date.now() + lockDuration, lockDuration / 1000);

      return {
        allowed: false,
        lockUntil: new Date(Date.now() + lockDuration)
      };
    }

    return {
      allowed: true,
      remainingAttempts: maxAttempts - attempts
    };
  } catch (error) {
    console.error('Check login attempts error:', error);
    return { allowed: true };
  }
}

/**
 * 记录登录失败
 */
export async function recordLoginFailure(identifier: string): Promise<void> {
  try {
    const cache = getCacheService();
    const attemptsKey = `login:attempts:${identifier}`;

    await cache.incrWithExpire(attemptsKey, 3600); // 1小时过期
  } catch (error) {
    console.error('Record login failure error:', error);
  }
}

/**
 * 清除登录失败记录（登录成功后调用）
 */
export async function clearLoginAttempts(identifier: string): Promise<void> {
  try {
    const cache = getCacheService();
    const attemptsKey = `login:attempts:${identifier}`;
    const lockKey = `login:lock:${identifier}`;

    await cache.del(attemptsKey);
    await cache.del(lockKey);
  } catch (error) {
    console.error('Clear login attempts error:', error);
  }
}
