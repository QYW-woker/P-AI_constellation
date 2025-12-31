/**
 * 用户模块DTO定义
 */
import Joi from 'joi';

// 更新用户信息请求
export interface UpdateUserDto {
  nickname?: string;
  avatarUrl?: string;
  gender?: number;
}

export const updateUserSchema = Joi.object({
  nickname: Joi.string()
    .min(2)
    .max(20)
    .pattern(/^[\u4e00-\u9fa5a-zA-Z0-9_]+$/)
    .optional()
    .messages({
      'string.min': '昵称至少2个字符',
      'string.max': '昵称最多20个字符',
      'string.pattern.base': '昵称只能包含中文、英文、数字和下划线'
    }),
  avatarUrl: Joi.string()
    .uri()
    .max(500)
    .optional()
    .messages({
      'string.uri': '头像URL格式错误',
      'string.max': '头像URL过长'
    }),
  gender: Joi.number()
    .valid(0, 1, 2)
    .optional()
    .messages({
      'any.only': '性别值无效'
    })
});

// 提交出生信息请求
export interface SubmitBirthInfoDto {
  birthDate: string;  // YYYY-MM-DD
  birthTime: string;  // HH:mm
  birthCity: string;
  birthProvince?: string;
  birthCountry?: string;
}

export const submitBirthInfoSchema = Joi.object({
  birthDate: Joi.string()
    .pattern(/^\d{4}-\d{2}-\d{2}$/)
    .required()
    .messages({
      'string.pattern.base': '出生日期格式错误，应为YYYY-MM-DD',
      'any.required': '出生日期不能为空'
    }),
  birthTime: Joi.string()
    .pattern(/^([01]\d|2[0-3]):([0-5]\d)$/)
    .required()
    .messages({
      'string.pattern.base': '出生时间格式错误，应为HH:mm',
      'any.required': '出生时间不能为空'
    }),
  birthCity: Joi.string()
    .max(100)
    .required()
    .messages({
      'string.max': '城市名过长',
      'any.required': '出生城市不能为空'
    }),
  birthProvince: Joi.string()
    .max(50)
    .optional(),
  birthCountry: Joi.string()
    .max(50)
    .default('中国')
});

// 用户信息响应
export interface UserProfileResponse {
  id: string;
  phone?: string;
  nickname?: string;
  avatarUrl?: string;
  gender?: number;
  isVip: boolean;
  vipExpireAt?: string;
  inviteCode: string;
  friendCount: number;
  birthInfo?: {
    birthDate: string;
    birthTime: string;
    birthCity: string;
  };
  chart?: {
    sunSign: string;
    moonSign: string;
    risingSign: string;
  };
}

// 出生信息提交响应
export interface BirthInfoResponse {
  birthInfo: {
    birthDate: string;
    birthTime: string;
    birthCity: string;
    birthProvince?: string;
    birthCountry: string;
  };
  chart: {
    sunSign: string;
    sunDegree: number;
    moonSign: string;
    moonDegree: number;
    risingSign: string;
    risingDegree: number;
    planets: Record<string, { sign: string; degree: number; house?: number }>;
    houses: Record<string, { sign: string; degree: number }>;
    elements: {
      fire: number;
      earth: number;
      air: number;
      water: number;
    };
  };
}
