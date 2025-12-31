/**
 * 短信服务
 * 使用阿里云SMS
 */
import { appConfig } from '../config';
import crypto from 'crypto';

interface SmsResponse {
  success: boolean;
  message?: string;
  requestId?: string;
}

export class SmsService {
  private accessKeyId: string;
  private accessKeySecret: string;
  private signName: string;
  private templateCode: string;

  constructor() {
    this.accessKeyId = appConfig.sms.accessKeyId;
    this.accessKeySecret = appConfig.sms.accessKeySecret;
    this.signName = appConfig.sms.signName;
    this.templateCode = appConfig.sms.templateCode;
  }

  /**
   * 发送验证码短信
   */
  async sendVerificationCode(phone: string, code: string): Promise<SmsResponse> {
    // 测试模式下直接返回成功
    if (appConfig.sms.testMode) {
      console.log(`[SMS Test Mode] Sending code ${code} to ${phone}`);
      return { success: true, message: 'Test mode - SMS not sent' };
    }

    try {
      // 构建请求参数
      const params = {
        PhoneNumbers: phone,
        SignName: this.signName,
        TemplateCode: this.templateCode,
        TemplateParam: JSON.stringify({ code }),
        Action: 'SendSms',
        Version: '2017-05-25',
        Format: 'JSON',
        AccessKeyId: this.accessKeyId,
        SignatureMethod: 'HMAC-SHA1',
        SignatureNonce: this.generateNonce(),
        SignatureVersion: '1.0',
        Timestamp: new Date().toISOString().replace(/\.\d{3}Z$/, 'Z')
      };

      // 生成签名
      const signature = this.generateSignature(params);
      const queryString = this.buildQueryString({ ...params, Signature: signature });

      // 发送请求
      const response = await fetch(`https://dysmsapi.aliyuncs.com/?${queryString}`, {
        method: 'GET'
      });

      const data = await response.json();

      if (data.Code === 'OK') {
        return {
          success: true,
          requestId: data.RequestId
        };
      } else {
        console.error('SMS send failed:', data);
        return {
          success: false,
          message: data.Message || 'SMS send failed'
        };
      }
    } catch (error) {
      console.error('SMS service error:', error);
      return {
        success: false,
        message: 'SMS service error'
      };
    }
  }

  /**
   * 生成随机数
   */
  private generateNonce(): string {
    return crypto.randomBytes(16).toString('hex');
  }

  /**
   * 生成阿里云API签名
   */
  private generateSignature(params: Record<string, string>): string {
    // 按字母顺序排序参数
    const sortedKeys = Object.keys(params).sort();
    const canonicalizedQueryString = sortedKeys
      .map(key => `${this.percentEncode(key)}=${this.percentEncode(params[key])}`)
      .join('&');

    // 构建待签名字符串
    const stringToSign = `GET&${this.percentEncode('/')}&${this.percentEncode(canonicalizedQueryString)}`;

    // HMAC-SHA1签名
    const hmac = crypto.createHmac('sha1', this.accessKeySecret + '&');
    hmac.update(stringToSign);
    return hmac.digest('base64');
  }

  /**
   * URL编码
   */
  private percentEncode(str: string): string {
    return encodeURIComponent(str)
      .replace(/!/g, '%21')
      .replace(/'/g, '%27')
      .replace(/\(/g, '%28')
      .replace(/\)/g, '%29')
      .replace(/\*/g, '%2A');
  }

  /**
   * 构建查询字符串
   */
  private buildQueryString(params: Record<string, string>): string {
    return Object.keys(params)
      .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`)
      .join('&');
  }
}

// 导出单例
export const smsService = new SmsService();
