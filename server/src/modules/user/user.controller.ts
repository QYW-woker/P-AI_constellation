/**
 * 用户控制器
 */
import { Router, Request, Response } from 'express';
import { userService } from './user.service';
import { updateUserSchema, submitBirthInfoSchema } from './user.dto';
import { authRequired } from '../../middleware/auth.middleware';

const router = Router();

/**
 * 获取当前用户信息
 * GET /user/me
 */
router.get('/me', authRequired, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const profile = await userService.getCurrentUser(userId);

    return res.json({
      code: 0,
      message: 'success',
      data: profile
    });
  } catch (err) {
    const error = err as Error;
    console.error('Get user profile error:', error);
    return res.status(400).json({
      code: 11005,
      message: error.message || '获取用户信息失败',
      data: null
    });
  }
});

/**
 * 更新用户信息
 * PUT /user/me
 */
router.put('/me', authRequired, async (req: Request, res: Response) => {
  try {
    // 参数验证
    const { error, value } = updateUserSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        code: 10001,
        message: error.details[0].message,
        data: null
      });
    }

    const userId = req.user!.id;
    const profile = await userService.updateUser(userId, value);

    return res.json({
      code: 0,
      message: 'success',
      data: profile
    });
  } catch (err) {
    const error = err as Error;
    console.error('Update user error:', error);
    return res.status(400).json({
      code: 10001,
      message: error.message || '更新用户信息失败',
      data: null
    });
  }
});

/**
 * 提交出生信息
 * POST /user/birth-info
 */
router.post('/birth-info', authRequired, async (req: Request, res: Response) => {
  try {
    // 参数验证
    const { error, value } = submitBirthInfoSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        code: 10001,
        message: error.details[0].message,
        data: null
      });
    }

    const userId = req.user!.id;
    const result = await userService.submitBirthInfo(userId, value);

    return res.json({
      code: 0,
      message: 'success',
      data: result
    });
  } catch (err) {
    const error = err as Error;
    console.error('Submit birth info error:', error);
    return res.status(400).json({
      code: 12006,
      message: error.message || '提交出生信息失败',
      data: null
    });
  }
});

export default router;
