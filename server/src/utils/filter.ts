/**
 * 敏感词过滤工具
 * 严格按照设计说明书实现
 */
import { BANNED_WORDS, SAFE_REPLACEMENTS } from '../config/constants';

/**
 * 过滤敏感词
 * @param content 原始内容
 * @returns 过滤后的内容
 */
export function filterContent(content: string): string {
  if (!content) return content;

  let filtered = content;

  // 1. 首先进行安全替换
  for (const [banned, safe] of Object.entries(SAFE_REPLACEMENTS)) {
    const regex = new RegExp(banned, 'g');
    filtered = filtered.replace(regex, safe);
  }

  // 2. 删除无法替换的敏感词
  for (const word of BANNED_WORDS) {
    const regex = new RegExp(word, 'g');
    filtered = filtered.replace(regex, '');
  }

  // 3. 清理多余空格
  filtered = filtered.replace(/\s+/g, ' ').trim();

  return filtered;
}

/**
 * 检查内容是否包含敏感词
 * @param content 要检查的内容
 * @returns 是否包含敏感词
 */
export function containsSensitiveWords(content: string): boolean {
  if (!content) return false;

  for (const word of BANNED_WORDS) {
    if (content.includes(word)) {
      return true;
    }
  }

  return false;
}

/**
 * 获取内容中包含的所有敏感词
 * @param content 要检查的内容
 * @returns 敏感词列表
 */
export function findSensitiveWords(content: string): string[] {
  if (!content) return [];

  const found: string[] = [];
  for (const word of BANNED_WORDS) {
    if (content.includes(word)) {
      found.push(word);
    }
  }

  return found;
}

/**
 * AI内容安全过滤器
 * 对AI生成的内容进行双重校验
 */
export function aiContentFilter(content: string): {
  filtered: string;
  hadSensitiveWords: boolean;
  removedWords: string[];
} {
  const removedWords = findSensitiveWords(content);
  const filtered = filterContent(content);

  return {
    filtered,
    hadSensitiveWords: removedWords.length > 0,
    removedWords
  };
}

/**
 * 添加免责声明
 */
export function appendDisclaimer(content: string, disclaimer: string): string {
  if (!content) return content;
  return `${content}\n\n${disclaimer}`;
}

/**
 * XSS防护 - HTML转义
 */
export function escapeHtml(input: string): string {
  if (!input) return input;

  return input
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;')
    .replace(/\//g, '&#x2F;');
}

/**
 * 手机号脱敏
 */
export function maskPhone(phone: string): string {
  if (!phone || phone.length !== 11) return phone;
  return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
}

/**
 * 验证手机号格式
 */
export function validatePhone(phone: string): boolean {
  return /^1[3-9]\d{9}$/.test(phone);
}

/**
 * 验证昵称格式
 * 2-20字符，允许中文、英文、数字、下划线
 */
export function validateNickname(nickname: string): boolean {
  return /^[\u4e00-\u9fa5a-zA-Z0-9_]{2,20}$/.test(nickname);
}

/**
 * 验证出生日期
 */
export function validateBirthDate(dateStr: string): boolean {
  const birthDate = new Date(dateStr);
  const minDate = new Date('1900-01-01');
  const maxDate = new Date();

  return !isNaN(birthDate.getTime()) &&
         birthDate >= minDate &&
         birthDate <= maxDate;
}

/**
 * 验证出生时间格式 HH:mm
 */
export function validateBirthTime(timeStr: string): boolean {
  return /^([01]\d|2[0-3]):([0-5]\d)$/.test(timeStr);
}
