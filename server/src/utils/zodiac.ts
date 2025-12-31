/**
 * 星座计算工具
 * 基于天文学原理进行星盘计算
 */
import { ZODIAC_SIGNS, ASPECTS } from '../config/constants';

// 星座名称列表（按黄道顺序）
const SIGN_NAMES = [
  '白羊座', '金牛座', '双子座', '巨蟹座',
  '狮子座', '处女座', '天秤座', '天蝎座',
  '射手座', '摩羯座', '水瓶座', '双鱼座'
];

// 星座英文名
const SIGN_NAMES_EN: Record<string, string> = {
  '白羊座': 'Aries',
  '金牛座': 'Taurus',
  '双子座': 'Gemini',
  '巨蟹座': 'Cancer',
  '狮子座': 'Leo',
  '处女座': 'Virgo',
  '天秤座': 'Libra',
  '天蝎座': 'Scorpio',
  '射手座': 'Sagittarius',
  '摩羯座': 'Capricorn',
  '水瓶座': 'Aquarius',
  '双鱼座': 'Pisces'
};

// 元素分类
const SIGN_ELEMENTS: Record<string, string> = {
  '白羊座': 'fire', '狮子座': 'fire', '射手座': 'fire',
  '金牛座': 'earth', '处女座': 'earth', '摩羯座': 'earth',
  '双子座': 'air', '天秤座': 'air', '水瓶座': 'air',
  '巨蟹座': 'water', '天蝎座': 'water', '双鱼座': 'water'
};

// 模式分类
const SIGN_MODES: Record<string, string> = {
  '白羊座': 'cardinal', '巨蟹座': 'cardinal', '天秤座': 'cardinal', '摩羯座': 'cardinal',
  '金牛座': 'fixed', '狮子座': 'fixed', '天蝎座': 'fixed', '水瓶座': 'fixed',
  '双子座': 'mutable', '处女座': 'mutable', '射手座': 'mutable', '双鱼座': 'mutable'
};

/**
 * 根据黄道经度获取星座
 * @param longitude 黄道经度 (0-360)
 * @returns 星座名称
 */
export function getZodiacSign(longitude: number): string {
  // 标准化经度到 0-360 范围
  let normalizedLng = longitude % 360;
  if (normalizedLng < 0) normalizedLng += 360;

  const index = Math.floor(normalizedLng / 30);
  return SIGN_NAMES[index];
}

/**
 * 获取星座内的度数
 * @param longitude 黄道经度
 * @returns 星座内度数 (0-30)
 */
export function getSignDegree(longitude: number): number {
  let normalizedLng = longitude % 360;
  if (normalizedLng < 0) normalizedLng += 360;
  return normalizedLng % 30;
}

/**
 * 获取星座的元素
 */
export function getSignElement(sign: string): string {
  return SIGN_ELEMENTS[sign] || 'unknown';
}

/**
 * 获取星座的模式
 */
export function getSignMode(sign: string): string {
  return SIGN_MODES[sign] || 'unknown';
}

/**
 * 获取星座英文名
 */
export function getSignEnglishName(sign: string): string {
  return SIGN_NAMES_EN[sign] || sign;
}

/**
 * 根据出生日期计算太阳星座
 * 简化计算（不考虑时区和年份差异）
 */
export function getSunSignFromDate(month: number, day: number): string {
  const dates = [
    [1, 20], [2, 19], [3, 21], [4, 20], [5, 21], [6, 21],
    [7, 23], [8, 23], [9, 23], [10, 23], [11, 22], [12, 22]
  ];

  let signIndex = 0;

  for (let i = 0; i < 12; i++) {
    const [startMonth, startDay] = dates[i];
    if (month === startMonth && day >= startDay) {
      signIndex = i;
    } else if (month === startMonth + 1 && day < dates[(i + 1) % 12][1]) {
      signIndex = i;
    }
  }

  // 特殊处理摩羯座（跨年）
  if (month === 12 && day >= 22) {
    signIndex = 9; // 摩羯座
  } else if (month === 1 && day <= 19) {
    signIndex = 9; // 摩羯座
  } else if (month === 1 && day >= 20) {
    signIndex = 10; // 水瓶座
  }

  return SIGN_NAMES[signIndex];
}

/**
 * 计算儒略日
 * @param year 年
 * @param month 月
 * @param day 日
 * @param hour 小时（可选，包含分钟的小数部分）
 * @returns 儒略日
 */
export function calculateJulianDay(
  year: number,
  month: number,
  day: number,
  hour: number = 12
): number {
  // 调整月份和年份（1月和2月视为前一年的13月和14月）
  let y = year;
  let m = month;

  if (m <= 2) {
    y -= 1;
    m += 12;
  }

  // 格里高利历修正
  const A = Math.floor(y / 100);
  const B = 2 - A + Math.floor(A / 4);

  // 计算儒略日
  const JD = Math.floor(365.25 * (y + 4716)) +
             Math.floor(30.6001 * (m + 1)) +
             day + B - 1524.5 +
             hour / 24;

  return JD;
}

/**
 * 计算格林威治恒星时
 * @param jd 儒略日
 * @returns 恒星时（小时）
 */
export function calculateGST(jd: number): number {
  const T = (jd - 2451545.0) / 36525;
  let GST = 280.46061837 +
            360.98564736629 * (jd - 2451545.0) +
            0.000387933 * T * T -
            T * T * T / 38710000;

  GST = GST % 360;
  if (GST < 0) GST += 360;

  return GST / 15; // 转换为小时
}

/**
 * 计算本地恒星时
 * @param gst 格林威治恒星时（小时）
 * @param longitude 经度（东正西负）
 * @returns 本地恒星时（小时）
 */
export function calculateLST(gst: number, longitude: number): number {
  let lst = gst + longitude / 15;
  lst = lst % 24;
  if (lst < 0) lst += 24;
  return lst;
}

/**
 * 计算上升点（ASC）
 * @param lst 本地恒星时（度数）
 * @param latitude 纬度
 * @param obliquity 黄赤交角（默认23.4度）
 * @returns 上升点黄道经度
 */
export function calculateAscendant(
  lstDegrees: number,
  latitude: number,
  obliquity: number = 23.4
): number {
  const latRad = latitude * Math.PI / 180;
  const oblRad = obliquity * Math.PI / 180;
  const lstRad = lstDegrees * Math.PI / 180;

  // 计算上升点
  const y = -Math.cos(lstRad);
  const x = Math.sin(lstRad) * Math.cos(oblRad) +
            Math.tan(latRad) * Math.sin(oblRad);

  let asc = Math.atan2(y, x) * 180 / Math.PI;
  if (asc < 0) asc += 360;

  return asc;
}

/**
 * 计算两个行星之间的相位
 */
export function calculateAspect(
  longitude1: number,
  longitude2: number
): { aspect: string; orb: number } | null {
  let angle = Math.abs(longitude1 - longitude2);
  if (angle > 180) angle = 360 - angle;

  for (const asp of ASPECTS) {
    const diff = Math.abs(angle - asp.angle);
    if (diff <= asp.orb) {
      return {
        aspect: asp.name,
        orb: Math.round(diff * 10) / 10
      };
    }
  }

  return null;
}

/**
 * 统计星盘中的元素分布
 */
export function countElements(planets: Record<string, { sign: string }>): {
  fire: number;
  earth: number;
  air: number;
  water: number;
} {
  const counts = { fire: 0, earth: 0, air: 0, water: 0 };

  for (const planet of Object.values(planets)) {
    const element = getSignElement(planet.sign);
    if (element in counts) {
      counts[element as keyof typeof counts]++;
    }
  }

  return counts;
}

/**
 * 统计星盘中的模式分布
 */
export function countModes(planets: Record<string, { sign: string }>): {
  cardinal: number;
  fixed: number;
  mutable: number;
} {
  const counts = { cardinal: 0, fixed: 0, mutable: 0 };

  for (const planet of Object.values(planets)) {
    const mode = getSignMode(planet.sign);
    if (mode in counts) {
      counts[mode as keyof typeof counts]++;
    }
  }

  return counts;
}

/**
 * 获取星座的守护星
 */
export function getSignRuler(sign: string): string {
  const zodiac = ZODIAC_SIGNS.find(z => z.name === sign);
  return zodiac?.ruler || '未知';
}

/**
 * 获取星座信息
 */
export function getZodiacInfo(sign: string) {
  return ZODIAC_SIGNS.find(z => z.name === sign) || null;
}

/**
 * 计算两个星座之间的相位关系
 * 返回相位类型
 */
export function getSignAspect(sign1: string, sign2: string): string | null {
  const idx1 = SIGN_NAMES.indexOf(sign1);
  const idx2 = SIGN_NAMES.indexOf(sign2);

  if (idx1 === -1 || idx2 === -1) return null;

  let diff = Math.abs(idx1 - idx2);
  if (diff > 6) diff = 12 - diff;

  switch (diff) {
    case 0: return '合相';
    case 2: return '六分相';
    case 3: return '刑相';
    case 4: return '三分相';
    case 6: return '对冲';
    default: return null;
  }
}

/**
 * 简化的行星黄道经度计算（用于演示）
 * 实际项目应使用 astronomia 或 Swiss Ephemeris
 */
export function estimatePlanetLongitude(
  planetName: string,
  julianDay: number
): number {
  // 这是简化的估算，实际应使用专业天文计算库
  // 太阳平均运动约 0.9856度/天
  const J2000 = 2451545.0; // 2000年1月1日12:00 UT的儒略日
  const daysSinceJ2000 = julianDay - J2000;

  // 简化的行星周期（天）
  const periods: Record<string, number> = {
    sun: 365.25,
    moon: 27.32,
    mercury: 87.97,
    venus: 224.70,
    mars: 686.97,
    jupiter: 4332.59,
    saturn: 10759.22,
    uranus: 30688.5,
    neptune: 60182.0,
    pluto: 90560.0
  };

  // 2000年1月1日的近似位置（度）
  const startPositions: Record<string, number> = {
    sun: 280.46,
    moon: 218.32,
    mercury: 252.25,
    venus: 181.98,
    mars: 355.43,
    jupiter: 34.40,
    saturn: 49.94,
    uranus: 314.05,
    neptune: 304.88,
    pluto: 238.93
  };

  const period = periods[planetName.toLowerCase()];
  const startPos = startPositions[planetName.toLowerCase()];

  if (!period || startPos === undefined) {
    return 0;
  }

  // 计算当前位置
  const meanMotion = 360 / period;
  let longitude = startPos + meanMotion * daysSinceJ2000;
  longitude = longitude % 360;
  if (longitude < 0) longitude += 360;

  return longitude;
}
