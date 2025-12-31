/**
 * 认证服务
 */
import prisma from '../../config/database';
import { getCacheService } from '../../config/redis';
import { appConfig } from '../../config';
import { generateInviteCode, generateVerificationCode, addMinutes } from '../../utils/helpers';
import { maskPhone } from '../../utils/filter';
import { generateAccessToken, generateRefreshToken, verifyToken } from '../../middleware/auth.middleware';
import { checkSmsLimit, recordSmsSent, checkLoginAttempts, recordLoginFailure, clearLoginAttempts } from '../../middleware/rate-limit';
import { CACHE_TTL, ERROR_CODES, INVITE_REWARD_DAYS } from '../../config/constants';
import {
  SendSmsDto,
  PhoneLoginDto,
  WechatLoginDto,
  RefreshTokenDto,
  LoginResponse,
  SendSmsResponse,
  RefreshTokenResponse
} from './auth.dto';

export class AuthService {
  private cache = getCacheService();

  /**
   * 发送短信验证码
   */
  async sendSms(dto: SendSmsDto): Promise<SendSmsResponse> {
    const { phone, type } = dto;

    // 检查限流
    const limitCheck = await checkSmsLimit(phone);
    if (!limitCheck.allowed) {
      throw new Error(limitCheck.message || ERROR_CODES[11007]);
    }

    // 生成验证码
    const code = appConfig.sms.testMode
      ? appConfig.sms.testCode || '123456'
      : generateVerificationCode();

    // 保存验证码到数据库
    const expiresAt = addMinutes(new Date(), 5);
    await prisma.verificationCode.create({
      data: {
        phone,
        code,
        type,
        expiresAt,
        isUsed: false
      }
    });

    // 缓存验证码（用于快速验证）
    await this.cache.set(`sms:code:${phone}`, code, CACHE_TTL.smsCode);

    // 发送短信（测试模式下跳过）
    if (!appConfig.sms.testMode) {
      await this.sendSmsMessage(phone, code);
    }

    // 记录发送
    await recordSmsSent(phone);

    return { expireIn: 300 };
  }

  /**
   * 实际发送短信（调用阿里云SMS）
   */
  private async sendSmsMessage(phone: string, code: string): Promise<void> {
    // TODO: 实现阿里云SMS发送
    // 开发阶段先打印到控制台
    console.log(`[SMS] Sending code ${code} to ${phone}`);
  }

  /**
   * 手机号登录/注册
   */
  async phoneLogin(dto: PhoneLoginDto): Promise<LoginResponse> {
    const { phone, code, inviteCode } = dto;

    // 检查登录限制
    const loginCheck = await checkLoginAttempts(phone);
    if (!loginCheck.allowed) {
      throw new Error(`账号已被锁定，请在${loginCheck.lockUntil?.toLocaleTimeString()}后重试`);
    }

    // 验证验证码
    const isValid = await this.verifyCode(phone, code);
    if (!isValid) {
      await recordLoginFailure(phone);
      throw new Error(ERROR_CODES[11001]);
    }

    // 清除登录失败记录
    await clearLoginAttempts(phone);

    // 查找或创建用户
    let user = await prisma.user.findUnique({
      where: { phone },
      include: { birthInfo: true }
    });

    let isNewUser = false;

    if (!user) {
      isNewUser = true;

      // 生成唯一邀请码
      let userInviteCode = generateInviteCode();
      let codeExists = true;
      while (codeExists) {
        const existing = await prisma.user.findUnique({
          where: { inviteCode: userInviteCode }
        });
        if (!existing) {
          codeExists = false;
        } else {
          userInviteCode = generateInviteCode();
        }
      }

      // 处理邀请码
      let inviterId: string | undefined;
      if (inviteCode) {
        const inviter = await prisma.user.findUnique({
          where: { inviteCode }
        });
        if (inviter) {
          inviterId = inviter.id;
        }
      }

      // 创建用户
      user = await prisma.user.create({
        data: {
          phone,
          phoneVerified: true,
          inviteCode: userInviteCode,
          invitedBy: inviterId,
          status: 1
        },
        include: { birthInfo: true }
      });

      // 处理邀请奖励
      if (inviterId) {
        await this.handleInviteReward(inviterId, user.id, inviteCode!);
      }
    }

    // 更新最后登录时间
    await prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() }
    });

    // 生成Token
    const token = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    // 缓存会话
    await this.cache.set(`session:${user.id}`, {
      token,
      refreshToken,
      createdAt: Date.now()
    }, CACHE_TTL.session);

    return {
      token,
      refreshToken,
      expiresIn: 604800, // 7天
      user: {
        id: user.id,
        phone: maskPhone(user.phone!),
        nickname: user.nickname || undefined,
        avatarUrl: user.avatarUrl || undefined,
        isVip: user.isVip,
        hasBirthInfo: !!user.birthInfo
      },
      isNewUser
    };
  }

  /**
   * 微信登录
   */
  async wechatLogin(dto: WechatLoginDto): Promise<LoginResponse> {
    const { code, inviteCode } = dto;

    // 获取微信用户信息
    const wxUser = await this.getWechatUserInfo(code);

    // 查找或创建用户
    let user = await prisma.user.findUnique({
      where: { wxOpenid: wxUser.openid },
      include: { birthInfo: true }
    });

    let isNewUser = false;

    if (!user) {
      isNewUser = true;

      // 生成唯一邀请码
      let userInviteCode = generateInviteCode();
      let codeExists = true;
      while (codeExists) {
        const existing = await prisma.user.findUnique({
          where: { inviteCode: userInviteCode }
        });
        if (!existing) {
          codeExists = false;
        } else {
          userInviteCode = generateInviteCode();
        }
      }

      // 处理邀请码
      let inviterId: string | undefined;
      if (inviteCode) {
        const inviter = await prisma.user.findUnique({
          where: { inviteCode }
        });
        if (inviter) {
          inviterId = inviter.id;
        }
      }

      // 创建用户
      user = await prisma.user.create({
        data: {
          wxOpenid: wxUser.openid,
          wxUnionid: wxUser.unionid,
          nickname: wxUser.nickname,
          avatarUrl: wxUser.headimgurl,
          gender: wxUser.sex,
          inviteCode: userInviteCode,
          invitedBy: inviterId,
          status: 1
        },
        include: { birthInfo: true }
      });

      // 处理邀请奖励
      if (inviterId) {
        await this.handleInviteReward(inviterId, user.id, inviteCode!);
      }
    }

    // 更新最后登录时间
    await prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() }
    });

    // 生成Token
    const token = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    // 缓存会话
    await this.cache.set(`session:${user.id}`, {
      token,
      refreshToken,
      createdAt: Date.now()
    }, CACHE_TTL.session);

    return {
      token,
      refreshToken,
      expiresIn: 604800,
      user: {
        id: user.id,
        phone: user.phone ? maskPhone(user.phone) : undefined,
        nickname: user.nickname || undefined,
        avatarUrl: user.avatarUrl || undefined,
        isVip: user.isVip,
        hasBirthInfo: !!user.birthInfo
      },
      isNewUser,
      needBindPhone: !user.phone
    };
  }

  /**
   * 刷新Token
   */
  async refreshToken(dto: RefreshTokenDto): Promise<RefreshTokenResponse> {
    const { refreshToken } = dto;

    // 验证刷新Token
    const payload = verifyToken(refreshToken);
    if (!payload || payload.type !== 'refresh') {
      throw new Error(ERROR_CODES[11003]);
    }

    // 检查Token是否过期
    if (payload.exp * 1000 < Date.now()) {
      throw new Error(ERROR_CODES[11004]);
    }

    // 验证用户存在
    const user = await prisma.user.findUnique({
      where: { id: payload.userId }
    });

    if (!user || user.status === 0) {
      throw new Error(ERROR_CODES[11005]);
    }

    // 生成新Token
    const newToken = generateAccessToken(user.id);
    const newRefreshToken = generateRefreshToken(user.id);

    // 更新会话缓存
    await this.cache.set(`session:${user.id}`, {
      token: newToken,
      refreshToken: newRefreshToken,
      createdAt: Date.now()
    }, CACHE_TTL.session);

    return {
      token: newToken,
      refreshToken: newRefreshToken,
      expiresIn: 604800
    };
  }

  /**
   * 验证验证码
   */
  private async verifyCode(phone: string, code: string): Promise<boolean> {
    // 测试模式
    if (appConfig.sms.testMode && code === appConfig.sms.testCode) {
      return true;
    }

    // 先从缓存检查
    const cachedCode = await this.cache.get<string>(`sms:code:${phone}`);
    if (cachedCode === code) {
      await this.cache.del(`sms:code:${phone}`);
      return true;
    }

    // 从数据库检查
    const verification = await prisma.verificationCode.findFirst({
      where: {
        phone,
        code,
        isUsed: false,
        expiresAt: { gt: new Date() }
      },
      orderBy: { createdAt: 'desc' }
    });

    if (verification) {
      // 标记为已使用
      await prisma.verificationCode.update({
        where: { id: verification.id },
        data: { isUsed: true }
      });
      return true;
    }

    return false;
  }

  /**
   * 获取微信用户信息
   */
  private async getWechatUserInfo(code: string): Promise<{
    openid: string;
    unionid?: string;
    nickname?: string;
    headimgurl?: string;
    sex?: number;
  }> {
    // TODO: 实现微信OAuth获取用户信息
    // 开发阶段返回模拟数据
    return {
      openid: `wx_${code}_${Date.now()}`,
      nickname: '微信用户',
      sex: 0
    };
  }

  /**
   * 处理邀请奖励
   */
  private async handleInviteReward(
    inviterId: string,
    inviteeId: string,
    inviteCode: string
  ): Promise<void> {
    // 创建邀请记录
    await prisma.invitation.create({
      data: {
        inviterId,
        inviteCode,
        inviteeId,
        status: 'registered',
        registeredAt: new Date()
      }
    });

    // 发放双方VIP奖励
    const now = new Date();

    // 更新邀请人VIP
    const inviter = await prisma.user.findUnique({ where: { id: inviterId } });
    if (inviter) {
      const inviterExpire = inviter.vipExpireAt && inviter.vipExpireAt > now
        ? new Date(inviter.vipExpireAt)
        : new Date(now);
      inviterExpire.setDate(inviterExpire.getDate() + INVITE_REWARD_DAYS);

      await prisma.user.update({
        where: { id: inviterId },
        data: {
          isVip: true,
          vipExpireAt: inviterExpire
        }
      });
    }

    // 更新被邀请人VIP
    const invitee = await prisma.user.findUnique({ where: { id: inviteeId } });
    if (invitee) {
      const inviteeExpire = invitee.vipExpireAt && invitee.vipExpireAt > now
        ? new Date(invitee.vipExpireAt)
        : new Date(now);
      inviteeExpire.setDate(inviteeExpire.getDate() + INVITE_REWARD_DAYS);

      await prisma.user.update({
        where: { id: inviteeId },
        data: {
          isVip: true,
          vipExpireAt: inviteeExpire
        }
      });
    }

    // 更新邀请记录状态
    await prisma.invitation.updateMany({
      where: { inviterId, inviteeId },
      data: { status: 'rewarded', rewardGiven: true }
    });

    // 自动建立好友关系
    await prisma.friendship.create({
      data: {
        userId: inviterId,
        friendId: inviteeId,
        status: 1
      }
    });

    await prisma.friendship.create({
      data: {
        userId: inviteeId,
        friendId: inviterId,
        status: 1
      }
    });
  }
}

// 导出单例
export const authService = new AuthService();
