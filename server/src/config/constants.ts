/**
 * 应用常量定义
 * 严格按照设计说明书定义
 */

// 禁用词列表（AI生成内容必须过滤）
export const BANNED_WORDS: string[] = [
  '算命', '改命', '批命', '命中注定', '天注定',
  '预测', '预言', '必定', '一定会', '肯定会',
  '化解', '破解', '消灾', '开光', '转运',
  '法器', '符咒', '风水', '阴阳', '驱邪',
  '大师', '仙人', '通灵', '神算', '天机',
  '封建迷信', '占卜', '卜卦', '算卦'
];

// 安全替换映射
export const SAFE_REPLACEMENTS: Record<string, string> = {
  '预测': '可能的趋势',
  '命中注定': '性格倾向',
  '一定会': '有可能',
  '必定': '倾向于',
  '化解': '建议尝试',
  '改运': '调整心态',
  '肯定会': '可能会',
  '转运': '改善状态'
};

// 免责声明
export const DISCLAIMER = '本应用基于天文学数据和性格心理学原理，所有内容仅供娱乐参考。星座分析不能替代专业的心理咨询或医疗建议。请理性看待，不要将其作为重要决策的依据。';

// 12星座基础信息
export const ZODIAC_SIGNS = [
  { name: '白羊座', nameEn: 'Aries', startDate: '03-21', endDate: '04-19', element: 'fire', mode: 'cardinal', ruler: '火星' },
  { name: '金牛座', nameEn: 'Taurus', startDate: '04-20', endDate: '05-20', element: 'earth', mode: 'fixed', ruler: '金星' },
  { name: '双子座', nameEn: 'Gemini', startDate: '05-21', endDate: '06-20', element: 'air', mode: 'mutable', ruler: '水星' },
  { name: '巨蟹座', nameEn: 'Cancer', startDate: '06-21', endDate: '07-22', element: 'water', mode: 'cardinal', ruler: '月亮' },
  { name: '狮子座', nameEn: 'Leo', startDate: '07-23', endDate: '08-22', element: 'fire', mode: 'fixed', ruler: '太阳' },
  { name: '处女座', nameEn: 'Virgo', startDate: '08-23', endDate: '09-22', element: 'earth', mode: 'mutable', ruler: '水星' },
  { name: '天秤座', nameEn: 'Libra', startDate: '09-23', endDate: '10-22', element: 'air', mode: 'cardinal', ruler: '金星' },
  { name: '天蝎座', nameEn: 'Scorpio', startDate: '10-23', endDate: '11-21', element: 'water', mode: 'fixed', ruler: '冥王星' },
  { name: '射手座', nameEn: 'Sagittarius', startDate: '11-22', endDate: '12-21', element: 'fire', mode: 'mutable', ruler: '木星' },
  { name: '摩羯座', nameEn: 'Capricorn', startDate: '12-22', endDate: '01-19', element: 'earth', mode: 'cardinal', ruler: '土星' },
  { name: '水瓶座', nameEn: 'Aquarius', startDate: '01-20', endDate: '02-18', element: 'air', mode: 'fixed', ruler: '天王星' },
  { name: '双鱼座', nameEn: 'Pisces', startDate: '02-19', endDate: '03-20', element: 'water', mode: 'mutable', ruler: '海王星' }
];

// 行星列表
export const PLANETS = [
  { name: '太阳', nameEn: 'Sun', symbol: '☉', keywords: ['核心自我', '生命力', '意志'] },
  { name: '月亮', nameEn: 'Moon', symbol: '☽', keywords: ['情感', '内心', '安全感'] },
  { name: '水星', nameEn: 'Mercury', symbol: '☿', keywords: ['沟通', '思维', '学习'] },
  { name: '金星', nameEn: 'Venus', symbol: '♀', keywords: ['爱情', '美', '价值观'] },
  { name: '火星', nameEn: 'Mars', symbol: '♂', keywords: ['行动力', '欲望', '勇气'] },
  { name: '木星', nameEn: 'Jupiter', symbol: '♃', keywords: ['扩展', '幸运', '智慧'] },
  { name: '土星', nameEn: 'Saturn', symbol: '♄', keywords: ['责任', '限制', '成熟'] },
  { name: '天王星', nameEn: 'Uranus', symbol: '♅', keywords: ['变革', '独立', '创新'] },
  { name: '海王星', nameEn: 'Neptune', symbol: '♆', keywords: ['梦想', '直觉', '灵性'] },
  { name: '冥王星', nameEn: 'Pluto', symbol: '♇', keywords: ['转化', '重生', '权力'] }
];

// 相位列表
export const ASPECTS = [
  { name: '合相', nameEn: 'Conjunction', angle: 0, orb: 8, nature: 'major', effect: '融合' },
  { name: '六分相', nameEn: 'Sextile', angle: 60, orb: 6, nature: 'major', effect: '和谐' },
  { name: '刑相', nameEn: 'Square', angle: 90, orb: 8, nature: 'major', effect: '挑战' },
  { name: '三分相', nameEn: 'Trine', angle: 120, orb: 8, nature: 'major', effect: '流畅' },
  { name: '对冲', nameEn: 'Opposition', angle: 180, orb: 8, nature: 'major', effect: '对立' }
];

// 错误码定义
export const ERROR_CODES: Record<number, string> = {
  // 通用错误 10000-10999
  10000: '系统错误',
  10001: '参数错误',
  10002: '请求频率过高',

  // 认证错误 11000-11999
  11001: '验证码错误',
  11002: '验证码已过期',
  11003: 'Token无效',
  11004: 'Token已过期',
  11005: '用户不存在',
  11006: '手机号格式错误',
  11007: '验证码发送过于频繁',

  // 业务错误 12000-12999
  12001: '好友数量已达上限',
  12002: '已经是好友了',
  12003: '不能添加自己为好友',
  12004: '邀请码无效',
  12005: '用户未填写出生信息',
  12006: '星盘计算失败',

  // 支付错误 13000-13999
  13001: '订单不存在',
  13002: '支付失败',
  13003: '已购买过该商品',
  13004: '订单已过期',
  13005: '金额不匹配'
};

// 会员套餐定义
export const MEMBERSHIP_PLANS = [
  {
    id: 'monthly',
    name: '月度会员',
    price: 1200, // 单位：分
    originalPrice: 1200,
    duration: 30,
    appleProductId: 'com.app.membership.monthly',
    features: ['个性化运势', '无限好友', '历史运势', '专属卡片', '去广告']
  },
  {
    id: 'quarterly',
    name: '季度会员',
    price: 2800,
    originalPrice: 3600,
    duration: 90,
    appleProductId: 'com.app.membership.quarterly',
    badge: '省22%'
  },
  {
    id: 'yearly',
    name: '年度会员',
    price: 6800,
    originalPrice: 14400,
    duration: 365,
    appleProductId: 'com.app.membership.yearly',
    badge: '省53%',
    recommended: true
  }
];

// 商品价格（服务端定义，不接受客户端传入）
export const PRODUCT_PRICES: Record<string, number> = {
  'membership_monthly': 1200,    // 12元（单位：分）
  'membership_quarterly': 2800,  // 28元
  'membership_yearly': 6800,     // 68元
  'compatibility_report': 990,   // 9.9元
  'deep_chart_report': 1800,     // 18元
  'yearly_report': 2800,         // 28元
};

// 限流配置
export const RATE_LIMIT_CONFIG = {
  // 全局限流
  global: { windowMs: 60 * 1000, max: 100 },
  // 登录接口
  auth: { windowMs: 60 * 1000, max: 10 },
  // 短信接口
  sms: { windowMs: 60 * 1000, max: 1 },
  // AI生成接口
  ai: { windowMs: 60 * 1000, max: 5 },
  // 支付接口
  payment: { windowMs: 60 * 1000, max: 5 }
};

// 缓存TTL配置（秒）
export const CACHE_TTL = {
  user: 3600,                    // 用户信息 1小时
  horoscope: 86400,              // 每日运势 24小时
  horoscopeBase: 86400,          // 基础运势 24小时
  compatibility: -1,             // 配对分数 永久（星盘不变）
  citiesHot: 86400,              // 热门城市 24小时
  smsLimit: 3600,                // 短信限制 1小时
  smsCode: 300,                  // 验证码 5分钟
  session: 604800,               // 会话 7天
  nonce: 300                     // 请求随机数 5分钟
};

// 免费用户好友数量上限
export const FREE_USER_FRIEND_LIMIT = 3;

// 邀请奖励天数
export const INVITE_REWARD_DAYS = 3;

// 中国主要城市经纬度（热门城市）
export const MAJOR_CITIES = [
  { name: '北京', province: '北京', lat: 39.9042, lng: 116.4074, isHot: true },
  { name: '上海', province: '上海', lat: 31.2304, lng: 121.4737, isHot: true },
  { name: '广州', province: '广东', lat: 23.1291, lng: 113.2644, isHot: true },
  { name: '深圳', province: '广东', lat: 22.5431, lng: 114.0579, isHot: true },
  { name: '杭州', province: '浙江', lat: 30.2741, lng: 120.1551, isHot: true },
  { name: '成都', province: '四川', lat: 30.5728, lng: 104.0668, isHot: true },
  { name: '武汉', province: '湖北', lat: 30.5928, lng: 114.3055, isHot: true },
  { name: '西安', province: '陕西', lat: 34.3416, lng: 108.9398, isHot: true },
  { name: '南京', province: '江苏', lat: 32.0603, lng: 118.7969, isHot: true },
  { name: '重庆', province: '重庆', lat: 29.4316, lng: 106.9123, isHot: true },
  { name: '天津', province: '天津', lat: 39.1252, lng: 117.1993, isHot: true },
  { name: '苏州', province: '江苏', lat: 31.2990, lng: 120.5853, isHot: true },
  { name: '长沙', province: '湖南', lat: 28.2280, lng: 112.9388, isHot: true },
  { name: '郑州', province: '河南', lat: 34.7473, lng: 113.6250, isHot: true },
  { name: '青岛', province: '山东', lat: 36.0671, lng: 120.3826, isHot: true },
  { name: '大连', province: '辽宁', lat: 38.9140, lng: 121.6147, isHot: true },
  { name: '厦门', province: '福建', lat: 24.4798, lng: 118.0894, isHot: true },
  { name: '沈阳', province: '辽宁', lat: 41.8057, lng: 123.4315, isHot: true },
  { name: '哈尔滨', province: '黑龙江', lat: 45.8038, lng: 126.5350, isHot: true },
  { name: '昆明', province: '云南', lat: 25.0406, lng: 102.7123, isHot: true }
];

// 星座元素配对表
export const ELEMENT_COMPATIBILITY: Record<string, number> = {
  'fire-fire': 85,    // 火-火：热情但可能冲突
  'fire-air': 90,     // 火-风：相互促进
  'fire-earth': 60,   // 火-土：需要磨合
  'fire-water': 50,   // 火-水：挑战较大
  'earth-earth': 80,  // 土-土：稳定但可能无聊
  'earth-water': 85,  // 土-水：互补
  'earth-air': 55,    // 土-风：差异较大
  'air-air': 80,      // 风-风：理解但可能飘忽
  'air-water': 60,    // 风-水：需要理解
  'water-water': 85   // 水-水：深度连接
};
