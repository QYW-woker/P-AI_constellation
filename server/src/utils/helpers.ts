/**
 * 通用工具函数
 */
import crypto from 'crypto';
import { v4 as uuidv4 } from 'uuid';

/**
 * 生成唯一邀请码
 * 6位大写字母和数字组合，排除易混淆字符
 */
export function generateInviteCode(): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // 排除易混淆字符 I,O,0,1
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

/**
 * 生成6位数字验证码
 */
export function generateVerificationCode(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

/**
 * 生成UUID
 */
export function generateUUID(): string {
  return uuidv4();
}

/**
 * 生成安全订单号
 * 时间戳（base36）+ 随机数 + 校验位
 */
export function generateOrderId(): string {
  const timestamp = Date.now().toString(36);
  const random = crypto.randomBytes(4).toString('hex');
  const raw = `${timestamp}${random}`;
  const checksum = calculateChecksum(raw);
  return `${raw}${checksum}`.toUpperCase();
}

/**
 * 计算校验位
 */
function calculateChecksum(input: string): string {
  let sum = 0;
  for (let i = 0; i < input.length; i++) {
    sum += input.charCodeAt(i);
  }
  return (sum % 36).toString(36);
}

/**
 * 生成随机字符串（用于nonce等）
 */
export function generateNonce(length: number = 16): string {
  return crypto.randomBytes(length).toString('hex');
}

/**
 * SHA256哈希
 */
export function sha256(data: string): string {
  return crypto.createHash('sha256').update(data).digest('hex');
}

/**
 * HMAC-SHA256签名
 */
export function hmacSha256(data: string, secret: string): string {
  return crypto.createHmac('sha256', secret).update(data).digest('hex');
}

/**
 * AES-256-GCM加密
 */
export function encrypt(plaintext: string, key: string): {
  ciphertext: string;
  iv: string;
  authTag: string;
} {
  const iv = crypto.randomBytes(16);
  const keyBuffer = Buffer.from(key, 'hex');
  const cipher = crypto.createCipheriv('aes-256-gcm', keyBuffer, iv);

  let encrypted = cipher.update(plaintext, 'utf8', 'hex');
  encrypted += cipher.final('hex');

  const authTag = cipher.getAuthTag();

  return {
    ciphertext: encrypted,
    iv: iv.toString('hex'),
    authTag: authTag.toString('hex')
  };
}

/**
 * AES-256-GCM解密
 */
export function decrypt(data: {
  ciphertext: string;
  iv: string;
  authTag: string;
}, key: string): string {
  const keyBuffer = Buffer.from(key, 'hex');
  const decipher = crypto.createDecipheriv(
    'aes-256-gcm',
    keyBuffer,
    Buffer.from(data.iv, 'hex')
  );
  decipher.setAuthTag(Buffer.from(data.authTag, 'hex'));

  let decrypted = decipher.update(data.ciphertext, 'hex', 'utf8');
  decrypted += decipher.final('utf8');

  return decrypted;
}

/**
 * 格式化日期为 YYYY-MM-DD
 */
export function formatDate(date: Date): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

/**
 * 格式化时间为 HH:mm
 */
export function formatTime(date: Date): string {
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');
  return `${hours}:${minutes}`;
}

/**
 * 获取今天的日期（零点）
 */
export function getToday(): Date {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return today;
}

/**
 * 日期加减天数
 */
export function addDays(date: Date, days: number): Date {
  const result = new Date(date);
  result.setDate(result.getDate() + days);
  return result;
}

/**
 * 日期加减小时
 */
export function addHours(date: Date, hours: number): Date {
  const result = new Date(date);
  result.setTime(result.getTime() + hours * 60 * 60 * 1000);
  return result;
}

/**
 * 日期加减分钟
 */
export function addMinutes(date: Date, minutes: number): Date {
  const result = new Date(date);
  result.setTime(result.getTime() + minutes * 60 * 1000);
  return result;
}

/**
 * 判断日期是否是今天
 */
export function isToday(date: Date): boolean {
  const today = new Date();
  return date.getFullYear() === today.getFullYear() &&
         date.getMonth() === today.getMonth() &&
         date.getDate() === today.getDate();
}

/**
 * 计算两个日期之间的天数差
 */
export function daysBetween(date1: Date, date2: Date): number {
  const oneDay = 24 * 60 * 60 * 1000;
  return Math.round(Math.abs((date1.getTime() - date2.getTime()) / oneDay));
}

/**
 * 解析时间字符串为小时和分钟
 */
export function parseTime(timeStr: string): { hours: number; minutes: number } | null {
  const match = timeStr.match(/^(\d{1,2}):(\d{2})$/);
  if (!match) return null;

  const hours = parseInt(match[1], 10);
  const minutes = parseInt(match[2], 10);

  if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
    return null;
  }

  return { hours, minutes };
}

/**
 * 将本地时间转换为UTC
 */
export function toUTC(date: Date, timezone: string = 'Asia/Shanghai'): Date {
  // 简化实现：假设东八区
  // 实际项目中应使用 luxon 或 moment-timezone
  const offset = 8 * 60 * 60 * 1000; // 东八区偏移
  return new Date(date.getTime() - offset);
}

/**
 * 深拷贝对象
 */
export function deepClone<T>(obj: T): T {
  return JSON.parse(JSON.stringify(obj));
}

/**
 * 对象按key排序
 */
export function sortObjectKeys(obj: Record<string, unknown>): Record<string, unknown> {
  return Object.keys(obj)
    .sort()
    .reduce((result, key) => {
      result[key] = obj[key];
      return result;
    }, {} as Record<string, unknown>);
}

/**
 * 生成API签名
 */
export function generateSignature(
  params: Record<string, unknown>,
  timestamp: number,
  nonce: string,
  secret: string
): string {
  const sortedKeys = Object.keys(params).sort();

  let signString = '';
  for (const key of sortedKeys) {
    signString += `${key}=${params[key]}&`;
  }
  signString += `timestamp=${timestamp}&nonce=${nonce}&secret=${secret}`;

  return hmacSha256(signString, secret);
}

/**
 * 休眠函数
 */
export function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * 重试函数
 */
export async function retry<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3,
  delay: number = 1000
): Promise<T> {
  let lastError: Error | undefined;

  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error as Error;
      if (i < maxRetries - 1) {
        await sleep(delay * Math.pow(2, i)); // 指数退避
      }
    }
  }

  throw lastError;
}

/**
 * 安全的JSON解析
 */
export function safeJsonParse<T>(json: string, defaultValue: T): T {
  try {
    return JSON.parse(json) as T;
  } catch {
    return defaultValue;
  }
}
