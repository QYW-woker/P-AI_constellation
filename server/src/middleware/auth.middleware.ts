/**
 * 认证中间件
 */
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { appConfig } from '../config';
import prisma from '../config/database';
import { ERROR_CODES } from '../config/constants';

// 扩展Request类型
declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        phone?: string;
        isVip: boolean;
      };
    }
  }
}

// JWT Payload类型
interface JWTPayload {
  userId: string;
  type: 'access' | 'refresh';
  iat: number;
  exp: number;
}

/**
 * 验证JWT Token
 */
export function verifyToken(token: string): JWTPayload | null {
  try {
    const decoded = jwt.verify(token, appConfig.jwt.secret) as JWTPayload;
    return decoded;
  } catch (error) {
    return null;
  }
}

/**
 * 生成访问Token
 */
export function generateAccessToken(userId: string): string {
  return jwt.sign(
    { userId, type: 'access' },
    appConfig.jwt.secret,
    { expiresIn: appConfig.jwt.expiresIn }
  );
}

/**
 * 生成刷新Token
 */
export function generateRefreshToken(userId: string): string {
  return jwt.sign(
    { userId, type: 'refresh' },
    appConfig.jwt.secret,
    { expiresIn: appConfig.jwt.refreshExpiresIn }
  );
}

/**
 * 认证中间件 - 必须登录
 */
export async function authRequired(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({
        code: 11003,
        message: ERROR_CODES[11003],
        data: null
      });
      return;
    }

    const token = authHeader.substring(7);
    const payload = verifyToken(token);

    if (!payload) {
      res.status(401).json({
        code: 11003,
        message: ERROR_CODES[11003],
        data: null
      });
      return;
    }

    // 检查是否是访问Token
    if (payload.type !== 'access') {
      res.status(401).json({
        code: 11003,
        message: ERROR_CODES[11003],
        data: null
      });
      return;
    }

    // 检查Token是否过期
    if (payload.exp * 1000 < Date.now()) {
      res.status(401).json({
        code: 11004,
        message: ERROR_CODES[11004],
        data: null
      });
      return;
    }

    // 查询用户
    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
      select: {
        id: true,
        phone: true,
        isVip: true,
        status: true
      }
    });

    if (!user || user.status === 0) {
      res.status(401).json({
        code: 11005,
        message: ERROR_CODES[11005],
        data: null
      });
      return;
    }

    // 设置用户信息到请求对象
    req.user = {
      id: user.id,
      phone: user.phone || undefined,
      isVip: user.isVip
    };

    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(500).json({
      code: 10000,
      message: ERROR_CODES[10000],
      data: null
    });
  }
}

/**
 * 可选认证中间件 - 不强制登录
 */
export async function authOptional(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      next();
      return;
    }

    const token = authHeader.substring(7);
    const payload = verifyToken(token);

    if (!payload || payload.type !== 'access' || payload.exp * 1000 < Date.now()) {
      next();
      return;
    }

    // 查询用户
    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
      select: {
        id: true,
        phone: true,
        isVip: true,
        status: true
      }
    });

    if (user && user.status === 1) {
      req.user = {
        id: user.id,
        phone: user.phone || undefined,
        isVip: user.isVip
      };
    }

    next();
  } catch (error) {
    // 可选认证失败不阻止请求
    next();
  }
}

/**
 * VIP会员权限中间件
 */
export async function vipRequired(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  if (!req.user) {
    res.status(401).json({
      code: 11003,
      message: ERROR_CODES[11003],
      data: null
    });
    return;
  }

  // 检查VIP状态
  const user = await prisma.user.findUnique({
    where: { id: req.user.id },
    select: {
      isVip: true,
      vipExpireAt: true
    }
  });

  if (!user || !user.isVip) {
    res.status(403).json({
      code: 12001,
      message: '此功能需要会员权限',
      data: null
    });
    return;
  }

  // 检查VIP是否过期
  if (user.vipExpireAt && user.vipExpireAt < new Date()) {
    // 更新VIP状态
    await prisma.user.update({
      where: { id: req.user.id },
      data: { isVip: false }
    });

    res.status(403).json({
      code: 12001,
      message: '您的会员已过期',
      data: null
    });
    return;
  }

  next();
}

/**
 * 请求签名验证中间件
 */
export function signatureRequired(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const signature = req.headers['x-signature'] as string;
  const timestamp = req.headers['x-timestamp'] as string;
  const nonce = req.headers['x-nonce'] as string;

  if (!signature || !timestamp || !nonce) {
    res.status(400).json({
      code: 10001,
      message: '缺少签名参数',
      data: null
    });
    return;
  }

  // 检查时间戳（5分钟有效期）
  const now = Date.now();
  const requestTime = parseInt(timestamp, 10);
  if (Math.abs(now - requestTime) > 5 * 60 * 1000) {
    res.status(400).json({
      code: 10001,
      message: '请求已过期',
      data: null
    });
    return;
  }

  // TODO: 验证nonce防重放
  // TODO: 验证签名

  next();
}
