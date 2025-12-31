/**
 * 推送服务
 * 使用极光推送JPush
 */
import { appConfig } from '../config';
import prisma from '../config/database';

export class PushService {
  private appKey: string;
  private masterSecret: string;
  private baseUrl = 'https://api.jpush.cn/v3';

  constructor() {
    this.appKey = appConfig.push.appKey;
    this.masterSecret = appConfig.push.masterSecret;
  }

  /**
   * 注册推送Token
   */
  async registerToken(userId: string, token: string, platform: string): Promise<void> {
    await prisma.pushToken.upsert({
      where: { userId },
      create: { userId, token, platform },
      update: { token, platform }
    });
  }

  /**
   * 发送推送给单个用户
   */
  async sendToUser(userId: string, title: string, content: string, extras?: Record<string, unknown>): Promise<boolean> {
    try {
      const pushToken = await prisma.pushToken.findUnique({
        where: { userId }
      });

      if (!pushToken) {
        console.log(`No push token found for user ${userId}`);
        return false;
      }

      // 检查用户推送设置
      const settings = await prisma.pushSettings.findUnique({
        where: { userId }
      });

      // 如果用户关闭了推送，不发送
      if (settings && !settings.dailyHoroscope && extras?.type === 'horoscope') {
        return false;
      }

      return await this.send({
        platform: [pushToken.platform],
        audience: {
          registration_id: [pushToken.token]
        },
        notification: {
          alert: content,
          android: {
            alert: content,
            title
          },
          ios: {
            alert: {
              title,
              body: content
            },
            sound: 'default'
          }
        },
        message: {
          msg_content: content,
          title,
          extras
        }
      });
    } catch (error) {
      console.error('Send push error:', error);
      return false;
    }
  }

  /**
   * 发送每日运势推送
   */
  async sendDailyHoroscope(userId: string, sunSign: string, summary: string): Promise<boolean> {
    return this.sendToUser(
      userId,
      `今日运势 - ${sunSign}`,
      summary.substring(0, 50) + '...',
      { type: 'horoscope', date: new Date().toISOString() }
    );
  }

  /**
   * 发送购买成功通知
   */
  async sendPurchaseSuccess(userId: string, productType: string): Promise<boolean> {
    const titles: Record<string, string> = {
      'membership_monthly': '月度会员开通成功',
      'membership_quarterly': '季度会员开通成功',
      'membership_yearly': '年度会员开通成功',
      'compatibility_report': '配对报告购买成功',
      'deep_chart_report': '深度星盘报告购买成功'
    };

    return this.sendToUser(
      userId,
      titles[productType] || '购买成功',
      '感谢您的支持，快去体验吧！',
      { type: 'purchase', productType }
    );
  }

  /**
   * 发送好友添加通知
   */
  async sendFriendAdded(userId: string, friendName: string): Promise<boolean> {
    return this.sendToUser(
      userId,
      '新好友添加',
      `${friendName}已添加您为好友，快去看看配对分数吧！`,
      { type: 'friend' }
    );
  }

  /**
   * 批量发送推送
   */
  async sendToUsers(userIds: string[], title: string, content: string, extras?: Record<string, unknown>): Promise<void> {
    for (const userId of userIds) {
      await this.sendToUser(userId, title, content, extras);
    }
  }

  /**
   * 发送推送请求
   */
  private async send(payload: Record<string, unknown>): Promise<boolean> {
    if (!this.appKey || !this.masterSecret) {
      console.log('[Push] No credentials configured, skipping push');
      return false;
    }

    try {
      const auth = Buffer.from(`${this.appKey}:${this.masterSecret}`).toString('base64');

      const response = await fetch(`${this.baseUrl}/push`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Basic ${auth}`
        },
        body: JSON.stringify(payload)
      });

      const result = await response.json();

      if (response.ok) {
        console.log('[Push] Sent successfully:', result);
        return true;
      } else {
        console.error('[Push] Failed:', result);
        return false;
      }
    } catch (error) {
      console.error('[Push] Error:', error);
      return false;
    }
  }

  /**
   * 注销推送
   */
  async unregister(userId: string): Promise<void> {
    await prisma.pushToken.deleteMany({
      where: { userId }
    });
    await prisma.pushSettings.deleteMany({
      where: { userId }
    });
  }
}

// 导出单例
export const pushService = new PushService();
