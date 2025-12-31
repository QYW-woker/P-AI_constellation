/**
 * 认证控制器
 */
import { Router, Request, Response } from 'express';
import { authService } from './auth.service';
import {
  sendSmsSchema,
  phoneLoginSchema,
  wechatLoginSchema,
  refreshTokenSchema
} from './auth.dto';
import { smsRateLimiter, authRateLimiter } from '../../middleware/rate-limit';

const router = Router();

/**
 * 发送验证码
 * POST /auth/sms/send
 */
router.post('/sms/send', smsRateLimiter, async (req: Request, res: Response) => {
  try {
    // 参数验证
    const { error, value } = sendSmsSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        code: 10001,
        message: error.details[0].message,
        data: null
      });
    }

    const result = await authService.sendSms(value);

    return res.json({
      code: 0,
      message: 'success',
      data: result
    });
  } catch (err) {
    const error = err as Error;
    console.error('Send SMS error:', error);
    return res.status(400).json({
      code: 11007,
      message: error.message || '发送验证码失败',
      data: null
    });
  }
});

/**
 * 手机号登录/注册
 * POST /auth/phone/login
 */
router.post('/phone/login', authRateLimiter, async (req: Request, res: Response) => {
  try {
    // 参数验证
    const { error, value } = phoneLoginSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        code: 10001,
        message: error.details[0].message,
        data: null
      });
    }

    const result = await authService.phoneLogin(value);

    return res.json({
      code: 0,
      message: 'success',
      data: result
    });
  } catch (err) {
    const error = err as Error;
    console.error('Phone login error:', error);
    return res.status(400).json({
      code: 11001,
      message: error.message || '登录失败',
      data: null
    });
  }
});

/**
 * 微信登录
 * POST /auth/wechat/login
 */
router.post('/wechat/login', authRateLimiter, async (req: Request, res: Response) => {
  try {
    // 参数验证
    const { error, value } = wechatLoginSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        code: 10001,
        message: error.details[0].message,
        data: null
      });
    }

    const result = await authService.wechatLogin(value);

    return res.json({
      code: 0,
      message: 'success',
      data: result
    });
  } catch (err) {
    const error = err as Error;
    console.error('Wechat login error:', error);
    return res.status(400).json({
      code: 11001,
      message: error.message || '微信登录失败',
      data: null
    });
  }
});

/**
 * 刷新Token
 * POST /auth/token/refresh
 */
router.post('/token/refresh', async (req: Request, res: Response) => {
  try {
    // 参数验证
    const { error, value } = refreshTokenSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        code: 10001,
        message: error.details[0].message,
        data: null
      });
    }

    const result = await authService.refreshToken(value);

    return res.json({
      code: 0,
      message: 'success',
      data: result
    });
  } catch (err) {
    const error = err as Error;
    console.error('Refresh token error:', error);
    return res.status(401).json({
      code: 11003,
      message: error.message || 'Token刷新失败',
      data: null
    });
  }
});

export default router;
