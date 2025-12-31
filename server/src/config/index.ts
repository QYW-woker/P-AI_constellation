/**
 * 应用配置
 * 从环境变量加载并验证配置
 */
import { z } from 'zod';
import dotenv from 'dotenv';

// 加载环境变量
dotenv.config();

// 配置校验Schema
const configSchema = z.object({
  nodeEnv: z.enum(['development', 'test', 'staging', 'production']).default('development'),
  port: z.number().default(3000),

  database: z.object({
    url: z.string().url(),
  }),

  redis: z.object({
    url: z.string(),
  }),

  jwt: z.object({
    secret: z.string().min(32),
    expiresIn: z.string().default('7d'),
    refreshExpiresIn: z.string().default('30d'),
  }),

  encryption: z.object({
    key: z.string().min(32),
  }),

  orderSignSecret: z.string().min(16),

  wechat: z.object({
    appId: z.string(),
    appSecret: z.string(),
    mchId: z.string(),
    apiKey: z.string(),
    sandbox: z.boolean().default(true),
  }),

  apple: z.object({
    bundleId: z.string(),
    sharedSecret: z.string(),
  }),

  sms: z.object({
    accessKeyId: z.string(),
    accessKeySecret: z.string(),
    signName: z.string(),
    templateCode: z.string(),
    testMode: z.boolean().default(true),
    testCode: z.string().optional(),
  }),

  ai: z.object({
    apiKey: z.string(),
    model: z.string().default('gpt-4'),
  }),

  oss: z.object({
    region: z.string(),
    accessKeyId: z.string(),
    accessKeySecret: z.string(),
    bucket: z.string(),
  }),

  push: z.object({
    appKey: z.string(),
    masterSecret: z.string(),
  }),

  apiBaseUrl: z.string().url(),
});

// 构建配置对象
function buildConfig() {
  const rawConfig = {
    nodeEnv: process.env.NODE_ENV,
    port: parseInt(process.env.PORT || '3000', 10),

    database: {
      url: process.env.DATABASE_URL || 'postgresql://user:password@localhost:5432/starapp_dev',
    },

    redis: {
      url: process.env.REDIS_URL || 'redis://localhost:6379',
    },

    jwt: {
      secret: process.env.JWT_SECRET || 'default_jwt_secret_key_at_least_32_chars',
      expiresIn: process.env.JWT_EXPIRES_IN || '7d',
      refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
    },

    encryption: {
      key: process.env.ENCRYPTION_KEY || 'default_encryption_key_32_chars_xxx',
    },

    orderSignSecret: process.env.ORDER_SIGN_SECRET || 'default_order_sign_secret',

    wechat: {
      appId: process.env.WECHAT_APP_ID || '',
      appSecret: process.env.WECHAT_APP_SECRET || '',
      mchId: process.env.WECHAT_MCH_ID || '',
      apiKey: process.env.WECHAT_API_KEY || '',
      sandbox: process.env.WECHAT_PAY_SANDBOX === 'true',
    },

    apple: {
      bundleId: process.env.APPLE_BUNDLE_ID || '',
      sharedSecret: process.env.APPLE_SHARED_SECRET || '',
    },

    sms: {
      accessKeyId: process.env.ALIYUN_SMS_ACCESS_KEY_ID || '',
      accessKeySecret: process.env.ALIYUN_SMS_ACCESS_KEY_SECRET || '',
      signName: process.env.ALIYUN_SMS_SIGN_NAME || '',
      templateCode: process.env.ALIYUN_SMS_TEMPLATE_CODE || '',
      testMode: process.env.SMS_TEST_MODE === 'true',
      testCode: process.env.SMS_TEST_CODE,
    },

    ai: {
      apiKey: process.env.OPENAI_API_KEY || '',
      model: process.env.AI_MODEL || 'gpt-4',
    },

    oss: {
      region: process.env.ALIYUN_OSS_REGION || '',
      accessKeyId: process.env.ALIYUN_OSS_ACCESS_KEY_ID || '',
      accessKeySecret: process.env.ALIYUN_OSS_ACCESS_KEY_SECRET || '',
      bucket: process.env.ALIYUN_OSS_BUCKET || '',
    },

    push: {
      appKey: process.env.JPUSH_APP_KEY || '',
      masterSecret: process.env.JPUSH_MASTER_SECRET || '',
    },

    apiBaseUrl: process.env.API_BASE_URL || 'http://localhost:3000',
  };

  return rawConfig;
}

// 导出配置
export const appConfig = buildConfig();

// 环境判断辅助函数
export const isDev = () => appConfig.nodeEnv === 'development';
export const isProd = () => appConfig.nodeEnv === 'production';
export const isTest = () => appConfig.nodeEnv === 'test';

export default appConfig;
