/**
 * 认证模块DTO定义
 */
import Joi from 'joi';

// 发送验证码请求
export interface SendSmsDto {
  phone: string;
  type: 'login' | 'register';
}

export const sendSmsSchema = Joi.object({
  phone: Joi.string()
    .pattern(/^1[3-9]\d{9}$/)
    .required()
    .messages({
      'string.pattern.base': '手机号格式错误',
      'any.required': '手机号不能为空'
    }),
  type: Joi.string()
    .valid('login', 'register')
    .required()
    .messages({
      'any.only': '类型必须是login或register',
      'any.required': '类型不能为空'
    })
});

// 手机号登录请求
export interface PhoneLoginDto {
  phone: string;
  code: string;
  inviteCode?: string;
}

export const phoneLoginSchema = Joi.object({
  phone: Joi.string()
    .pattern(/^1[3-9]\d{9}$/)
    .required()
    .messages({
      'string.pattern.base': '手机号格式错误',
      'any.required': '手机号不能为空'
    }),
  code: Joi.string()
    .pattern(/^\d{6}$/)
    .required()
    .messages({
      'string.pattern.base': '验证码必须是6位数字',
      'any.required': '验证码不能为空'
    }),
  inviteCode: Joi.string()
    .length(6)
    .optional()
    .messages({
      'string.length': '邀请码必须是6位'
    })
});

// 微信登录请求
export interface WechatLoginDto {
  code: string;
  inviteCode?: string;
}

export const wechatLoginSchema = Joi.object({
  code: Joi.string()
    .required()
    .messages({
      'any.required': '微信授权code不能为空'
    }),
  inviteCode: Joi.string()
    .length(6)
    .optional()
});

// 刷新Token请求
export interface RefreshTokenDto {
  refreshToken: string;
}

export const refreshTokenSchema = Joi.object({
  refreshToken: Joi.string()
    .required()
    .messages({
      'any.required': 'refreshToken不能为空'
    })
});

// 登录响应
export interface LoginResponse {
  token: string;
  refreshToken: string;
  expiresIn: number;
  user: {
    id: string;
    phone?: string;
    nickname?: string;
    avatarUrl?: string;
    isVip: boolean;
    hasBirthInfo: boolean;
  };
  isNewUser: boolean;
  needBindPhone?: boolean;
}

// 发送验证码响应
export interface SendSmsResponse {
  expireIn: number;
}

// Token刷新响应
export interface RefreshTokenResponse {
  token: string;
  refreshToken: string;
  expiresIn: number;
}
