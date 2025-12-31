/**
 * Redis配置
 */
import Redis from 'ioredis';

// Redis客户端实例
let redisClient: Redis | null = null;

/**
 * 获取Redis客户端
 */
export function getRedisClient(): Redis {
  if (!redisClient) {
    const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';

    redisClient = new Redis(redisUrl, {
      maxRetriesPerRequest: 3,
      retryStrategy(times) {
        const delay = Math.min(times * 50, 2000);
        return delay;
      },
      reconnectOnError(err) {
        const targetError = 'READONLY';
        if (err.message.includes(targetError)) {
          return true;
        }
        return false;
      },
    });

    redisClient.on('error', (err) => {
      console.error('Redis connection error:', err);
    });

    redisClient.on('connect', () => {
      console.log('✅ Redis connected successfully');
    });

    redisClient.on('ready', () => {
      console.log('✅ Redis is ready');
    });

    redisClient.on('close', () => {
      console.log('Redis connection closed');
    });
  }

  return redisClient;
}

/**
 * Redis缓存服务
 */
export class CacheService {
  private redis: Redis;

  constructor() {
    this.redis = getRedisClient();
  }

  /**
   * 设置缓存
   */
  async set(key: string, value: unknown, ttl?: number): Promise<void> {
    const stringValue = JSON.stringify(value);
    if (ttl && ttl > 0) {
      await this.redis.setex(key, ttl, stringValue);
    } else {
      await this.redis.set(key, stringValue);
    }
  }

  /**
   * 获取缓存
   */
  async get<T>(key: string): Promise<T | null> {
    const value = await this.redis.get(key);
    if (value) {
      try {
        return JSON.parse(value) as T;
      } catch {
        return value as unknown as T;
      }
    }
    return null;
  }

  /**
   * 删除缓存
   */
  async del(key: string): Promise<void> {
    await this.redis.del(key);
  }

  /**
   * 批量删除（支持通配符）
   */
  async delPattern(pattern: string): Promise<void> {
    const keys = await this.redis.keys(pattern);
    if (keys.length > 0) {
      await this.redis.del(...keys);
    }
  }

  /**
   * 检查key是否存在
   */
  async exists(key: string): Promise<boolean> {
    const result = await this.redis.exists(key);
    return result === 1;
  }

  /**
   * 设置过期时间
   */
  async expire(key: string, seconds: number): Promise<void> {
    await this.redis.expire(key, seconds);
  }

  /**
   * 递增
   */
  async incr(key: string): Promise<number> {
    return await this.redis.incr(key);
  }

  /**
   * 带过期时间的递增
   */
  async incrWithExpire(key: string, ttl: number): Promise<number> {
    const result = await this.redis.incr(key);
    if (result === 1) {
      await this.redis.expire(key, ttl);
    }
    return result;
  }

  /**
   * 获取TTL
   */
  async ttl(key: string): Promise<number> {
    return await this.redis.ttl(key);
  }

  /**
   * Sorted Set操作 - 用于滑动窗口限流
   */
  async zremrangebyscore(key: string, min: number, max: number): Promise<number> {
    return await this.redis.zremrangebyscore(key, min, max);
  }

  async zcard(key: string): Promise<number> {
    return await this.redis.zcard(key);
  }

  async zadd(key: string, score: number, member: string): Promise<number> {
    return await this.redis.zadd(key, score, member);
  }
}

// 缓存服务单例
let cacheServiceInstance: CacheService | null = null;

export function getCacheService(): CacheService {
  if (!cacheServiceInstance) {
    cacheServiceInstance = new CacheService();
  }
  return cacheServiceInstance;
}

/**
 * 测试Redis连接
 */
export async function testRedisConnection(): Promise<boolean> {
  try {
    const redis = getRedisClient();
    await redis.ping();
    console.log('✅ Redis connection successful');
    return true;
  } catch (error) {
    console.error('❌ Redis connection failed:', error);
    return false;
  }
}

/**
 * 关闭Redis连接
 */
export async function disconnectRedis(): Promise<void> {
  if (redisClient) {
    await redisClient.quit();
    redisClient = null;
    console.log('Redis disconnected');
  }
}

export default getRedisClient;
