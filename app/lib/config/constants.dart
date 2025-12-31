/// 应用常量
class AppConstants {
  // 存储键
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserInfo = 'user_info';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyPushToken = 'push_token';

  // 星座列表
  static const List<String> zodiacSigns = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];

  // 星座中文名
  static const Map<String, String> zodiacChineseNames = {
    'Aries': '白羊座',
    'Taurus': '金牛座',
    'Gemini': '双子座',
    'Cancer': '巨蟹座',
    'Leo': '狮子座',
    'Virgo': '处女座',
    'Libra': '天秤座',
    'Scorpio': '天蝎座',
    'Sagittarius': '射手座',
    'Capricorn': '摩羯座',
    'Aquarius': '水瓶座',
    'Pisces': '双鱼座',
  };

  // 行星列表
  static const List<String> planets = [
    'Sun',
    'Moon',
    'Mercury',
    'Venus',
    'Mars',
    'Jupiter',
    'Saturn',
    'Uranus',
    'Neptune',
    'Pluto',
  ];

  // 行星中文名
  static const Map<String, String> planetChineseNames = {
    'Sun': '太阳',
    'Moon': '月亮',
    'Mercury': '水星',
    'Venus': '金星',
    'Mars': '火星',
    'Jupiter': '木星',
    'Saturn': '土星',
    'Uranus': '天王星',
    'Neptune': '海王星',
    'Pluto': '冥王星',
  };

  // 相位类型
  static const Map<String, String> aspectTypes = {
    'conjunction': '合相 0°',
    'opposition': '对冲 180°',
    'trine': '三合 120°',
    'square': '四分 90°',
    'sextile': '六合 60°',
  };

  // 元素类型
  static const Map<String, String> elements = {
    'fire': '火象',
    'earth': '土象',
    'air': '风象',
    'water': '水象',
  };

  // 模式类型
  static const Map<String, String> modes = {
    'cardinal': '本位',
    'fixed': '固定',
    'mutable': '变动',
  };

  // 运势维度
  static const List<String> horoscopeDimensions = [
    'overall',
    'love',
    'career',
    'wealth',
    'health',
  ];

  // 运势维度中文名
  static const Map<String, String> horoscopeDimensionNames = {
    'overall': '综合运势',
    'love': '爱情运势',
    'career': '事业运势',
    'wealth': '财富运势',
    'health': '健康运势',
  };

  // 配对维度
  static const List<String> compatibilityDimensions = [
    'overall',
    'emotional',
    'communication',
    'values',
    'lifestyle',
    'intimacy',
    'growth',
  ];

  // 配对维度中文名
  static const Map<String, String> compatibilityDimensionNames = {
    'overall': '综合契合度',
    'emotional': '情感契合',
    'communication': '沟通契合',
    'values': '价值观契合',
    'lifestyle': '生活方式',
    'intimacy': '亲密关系',
    'growth': '共同成长',
  };

  // 会员套餐
  static const Map<String, Map<String, dynamic>> membershipPlans = {
    'monthly': {
      'name': '月度会员',
      'price': 18.0,
      'days': 30,
      'originalPrice': 28.0,
    },
    'quarterly': {
      'name': '季度会员',
      'price': 48.0,
      'days': 90,
      'originalPrice': 84.0,
    },
    'yearly': {
      'name': '年度会员',
      'price': 168.0,
      'days': 365,
      'originalPrice': 336.0,
    },
  };

  // 商品价格
  static const Map<String, double> productPrices = {
    'membership_monthly': 18.0,
    'membership_quarterly': 48.0,
    'membership_yearly': 168.0,
    'compatibility_report': 12.0,
    'deep_chart_report': 28.0,
  };

  // 邀请奖励
  static const int inviteRewardDays = 3;

  // 错误消息
  static const Map<int, String> errorMessages = {
    10000: '系统错误，请稍后重试',
    10001: '参数错误',
    11001: '请先登录',
    11002: '登录已过期，请重新登录',
    11003: '无权限访问',
    12001: '验证码发送失败',
    12002: '验证码错误',
    12003: '验证码已过期',
    12004: '邀请码无效',
    12005: '请先填写出生信息',
    13001: '支付创建失败',
    13002: '支付验证失败',
    13003: '订单不存在',
    13004: '商品不存在',
  };

  // 分享模板
  static const Map<String, String> shareTemplates = {
    'horoscope': '我今日的星座运势是{score}分！快来看看你的运势吧~',
    'compatibility': '我和TA的配对分数是{score}分！你也来测测看？',
    'profile': '我是{sign}，来看看我的星座性格分析吧~',
  };
}
