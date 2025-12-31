/**
 * AI内容生成服务
 * 使用OpenAI GPT生成星座相关内容
 */
import OpenAI from 'openai';
import { appConfig } from '../config';
import { filterContent, aiContentFilter } from '../utils/filter';
import { DISCLAIMER } from '../config/constants';

export class AIService {
  private openai: OpenAI;
  private model: string;

  constructor() {
    this.openai = new OpenAI({
      apiKey: appConfig.ai.apiKey,
    });
    this.model = appConfig.ai.model;
  }

  /**
   * 生成每日运势
   */
  async generateDailyHoroscope(params: {
    sunSign: string;
    moonSign?: string;
    risingSign?: string;
    isPersonalized: boolean;
    date: string;
  }): Promise<{
    summary: string;
    scores: {
      overall: number;
      love: number;
      career: number;
      wealth: number;
      social: number;
    };
    doList: string[];
    dontList: string[];
    lucky: {
      color: string;
      number: number;
      direction: string;
      time: string;
    };
  }> {
    const prompt = params.isPersonalized
      ? this.buildPersonalizedHoroscopePrompt(params)
      : this.buildBasicHoroscopePrompt(params.sunSign, params.date);

    try {
      const response = await this.openai.chat.completions.create({
        model: this.model,
        messages: [
          { role: 'system', content: this.HOROSCOPE_SYSTEM_PROMPT },
          { role: 'user', content: prompt }
        ],
        temperature: 0.7,
        max_tokens: 800,
        response_format: { type: 'json_object' }
      });

      const content = response.choices[0]?.message?.content || '{}';
      const parsed = JSON.parse(content);

      // 过滤敏感词
      parsed.summary = filterContent(parsed.summary || '');

      return {
        summary: parsed.summary || '今天是平稳的一天，适合稳步前进。',
        scores: {
          overall: this.clampScore(parsed.scores?.overall || 75),
          love: this.clampScore(parsed.scores?.love || 70),
          career: this.clampScore(parsed.scores?.career || 75),
          wealth: this.clampScore(parsed.scores?.wealth || 70),
          social: this.clampScore(parsed.scores?.social || 75)
        },
        doList: parsed.doList || ['保持积极心态', '注意休息'],
        dontList: parsed.dontList || ['避免冲动决策'],
        lucky: {
          color: parsed.lucky?.color || '蓝色',
          number: parsed.lucky?.number || 7,
          direction: parsed.lucky?.direction || '东方',
          time: parsed.lucky?.time || '14:00-16:00'
        }
      };
    } catch (error) {
      console.error('Generate horoscope error:', error);
      // 返回默认值
      return this.getDefaultHoroscope();
    }
  }

  /**
   * 生成星盘解读
   */
  async generateChartInterpretation(params: {
    sunSign: string;
    moonSign: string;
    risingSign: string;
    planets: Record<string, unknown>;
    type: string;
  }): Promise<{
    sun: string;
    moon: string;
    rising: string;
    full?: string;
  }> {
    const prompt = `请为以下星盘生成解读：
太阳星座：${params.sunSign}
月亮星座：${params.moonSign}
上升星座：${params.risingSign}

请分别为太阳、月亮、上升生成100-150字的解读内容。`;

    try {
      const response = await this.openai.chat.completions.create({
        model: this.model,
        messages: [
          { role: 'system', content: this.CHART_SYSTEM_PROMPT },
          { role: 'user', content: prompt }
        ],
        temperature: 0.7,
        max_tokens: 1000,
        response_format: { type: 'json_object' }
      });

      const content = response.choices[0]?.message?.content || '{}';
      const parsed = JSON.parse(content);

      return {
        sun: filterContent(parsed.sun || this.getDefaultInterpretation(params.sunSign, 'sun')),
        moon: filterContent(parsed.moon || this.getDefaultInterpretation(params.moonSign, 'moon')),
        rising: filterContent(parsed.rising || this.getDefaultInterpretation(params.risingSign, 'rising'))
      };
    } catch (error) {
      console.error('Generate interpretation error:', error);
      return {
        sun: this.getDefaultInterpretation(params.sunSign, 'sun'),
        moon: this.getDefaultInterpretation(params.moonSign, 'moon'),
        rising: this.getDefaultInterpretation(params.risingSign, 'rising')
      };
    }
  }

  /**
   * 生成配对报告
   */
  async generateCompatibilityReport(params: {
    user: { sunSign: string; moonSign: string; risingSign: string };
    friend: { sunSign: string; moonSign: string; risingSign: string };
    scores: Record<string, number>;
  }): Promise<{
    summary: string;
    dimensions: Record<string, { title: string; content: string }>;
    suggestions: string[];
  }> {
    const prompt = `请为以下两个星盘生成配对分析报告：

用户A：太阳${params.user.sunSign}，月亮${params.user.moonSign}，上升${params.user.risingSign}
用户B：太阳${params.friend.sunSign}，月亮${params.friend.moonSign}，上升${params.friend.risingSign}

配对评分：
- 整体契合度：${params.scores.overall}
- 沟通方式：${params.scores.communication}
- 情感需求：${params.scores.emotion}
- 价值观：${params.scores.values}
- 吸引力：${params.scores.attraction}
- 冲突点：${params.scores.conflict}
- 成长空间：${params.scores.growth}

请为每个维度生成100-150字的分析内容，并给出3条相处建议。`;

    try {
      const response = await this.openai.chat.completions.create({
        model: this.model,
        messages: [
          { role: 'system', content: this.COMPATIBILITY_SYSTEM_PROMPT },
          { role: 'user', content: prompt }
        ],
        temperature: 0.7,
        max_tokens: 2000,
        response_format: { type: 'json_object' }
      });

      const content = response.choices[0]?.message?.content || '{}';
      const parsed = JSON.parse(content);

      // 过滤敏感词
      const filtered = {
        summary: filterContent(parsed.summary || ''),
        dimensions: {} as Record<string, { title: string; content: string }>,
        suggestions: (parsed.suggestions || []).map((s: string) => filterContent(s))
      };

      const dimensionKeys = ['overall', 'communication', 'emotion', 'values', 'attraction', 'conflict', 'growth'];
      for (const key of dimensionKeys) {
        if (parsed.dimensions?.[key]) {
          filtered.dimensions[key] = {
            title: parsed.dimensions[key].title || key,
            content: filterContent(parsed.dimensions[key].content || '')
          };
        }
      }

      return filtered;
    } catch (error) {
      console.error('Generate compatibility report error:', error);
      return this.getDefaultCompatibilityReport();
    }
  }

  // 系统提示词
  private HOROSCOPE_SYSTEM_PROMPT = `你是一位温暖且有洞察力的性格分析师，基于天文学和心理学为用户提供每日运势参考。

输出要求：请严格按照以下JSON格式输出：
{
  "summary": "100-150字的运势摘要，语气温暖积极",
  "scores": { "overall": 0-100, "love": 0-100, "career": 0-100, "wealth": 0-100, "social": 0-100 },
  "doList": ["宜做的事1", "宜做的事2", "宜做的事3"],
  "dontList": ["不宜做的事1", "不宜做的事2"],
  "lucky": { "color": "颜色", "number": 数字, "direction": "方位", "time": "时段" }
}

文案风格：温暖积极、具体可行、避免绝对。
禁止词汇：算命、改命、预测、预言、必定、一定会、化解、破解、消灾、开光、转运、法器、符咒、风水、阴阳`;

  private CHART_SYSTEM_PROMPT = `你是一位专业的性格分析师，基于星座心理学帮助用户了解自己的性格特点。

输出格式：JSON
{
  "sun": "太阳星座解读，150字左右",
  "moon": "月亮星座解读，150字左右",
  "rising": "上升星座解读，150字左右"
}

禁止使用：算命、预测、命中注定等词汇。`;

  private COMPATIBILITY_SYSTEM_PROMPT = `你是一位专业的关系分析师，基于星座心理学帮助用户了解人际关系的特点。

输出格式：JSON
{
  "summary": "200字总结",
  "dimensions": {
    "overall": { "title": "整体契合度", "content": "100-150字分析" },
    "communication": { "title": "沟通方式", "content": "..." },
    "emotion": { "title": "情感需求", "content": "..." },
    "values": { "title": "价值观", "content": "..." },
    "attraction": { "title": "吸引力", "content": "..." },
    "conflict": { "title": "潜在冲突", "content": "..." },
    "growth": { "title": "成长空间", "content": "..." }
  },
  "suggestions": ["建议1", "建议2", "建议3"]
}

禁止预测关系结果，避免绝对判断。`;

  private clampScore(score: number): number {
    return Math.min(100, Math.max(0, Math.round(score)));
  }

  private buildBasicHoroscopePrompt(sunSign: string, date: string): string {
    return `请为${sunSign}生成${date}的每日运势参考。`;
  }

  private buildPersonalizedHoroscopePrompt(params: {
    sunSign: string;
    moonSign?: string;
    risingSign?: string;
    date: string;
  }): string {
    return `请为以下星盘的用户生成${params.date}的个性化运势参考：
- 太阳星座：${params.sunSign}
- 月亮星座：${params.moonSign || '未知'}
- 上升星座：${params.risingSign || '未知'}`;
  }

  private getDefaultHoroscope() {
    return {
      summary: '今天是平稳的一天，适合稳步前进。保持积极的心态，关注身边的小确幸。',
      scores: { overall: 75, love: 70, career: 75, wealth: 70, social: 75 },
      doList: ['保持积极心态', '关注健康', '与朋友交流'],
      dontList: ['避免冲动决策', '不宜熬夜'],
      lucky: { color: '蓝色', number: 7, direction: '东方', time: '14:00-16:00' }
    };
  }

  private getDefaultInterpretation(sign: string, type: string): string {
    const defaults: Record<string, string> = {
      sun: `作为${sign}，你有着独特的个性和魅力。你的核心能量体现在日常生活中的方方面面。`,
      moon: `月亮${sign}赋予了你独特的情感表达方式。你的内心世界丰富而深邃。`,
      rising: `上升${sign}让你给他人的第一印象充满特色。这也是你面对世界的方式。`
    };
    return defaults[type] || `${sign}的特质在你身上有着独特的体现。`;
  }

  private getDefaultCompatibilityReport() {
    return {
      summary: '你们之间有着独特的互动方式，既有共鸣的地方，也有需要磨合的方面。',
      dimensions: {
        overall: { title: '整体契合度', content: '你们之间的关系有着独特的化学反应。' },
        communication: { title: '沟通方式', content: '在沟通上需要相互理解和包容。' },
        emotion: { title: '情感需求', content: '情感上需要找到平衡点。' },
        values: { title: '价值观', content: '在价值观上有一定的共识。' },
        attraction: { title: '吸引力', content: '彼此之间存在着吸引力。' },
        conflict: { title: '潜在冲突', content: '可能在某些方面存在分歧。' },
        growth: { title: '成长空间', content: '这段关系有助于双方成长。' }
      },
      suggestions: ['给彼此足够的空间', '定期进行深度沟通', '尊重对方的差异']
    };
  }
}

// 导出单例
export const aiService = new AIService();
