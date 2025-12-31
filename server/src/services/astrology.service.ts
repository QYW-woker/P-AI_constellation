/**
 * 星盘计算服务
 * 基于天文学原理进行星盘计算
 */
import {
  getZodiacSign,
  getSignDegree,
  getSignElement,
  getSignMode,
  calculateJulianDay,
  calculateGST,
  calculateLST,
  calculateAscendant,
  calculateAspect,
  estimatePlanetLongitude,
  countElements,
  countModes
} from '../utils/zodiac';

// 星盘计算输入
interface BirthInfo {
  birthDate: string;  // YYYY-MM-DD
  birthTime: string;  // HH:mm
  latitude: number;
  longitude: number;
  timezone: string;
}

// 行星位置
interface PlanetPosition {
  sign: string;
  degree: number;
  house?: number;
}

// 相位
interface Aspect {
  planet1: string;
  planet2: string;
  aspect: string;
  orb: number;
}

// 宫位
interface House {
  sign: string;
  degree: number;
}

// 星盘数据
interface NatalChartData {
  sunSign: string;
  sunDegree: number;
  moonSign: string;
  moonDegree: number;
  risingSign: string;
  risingDegree: number;
  planets: Record<string, PlanetPosition>;
  houses: Record<string, House>;
  aspects: Aspect[];
  elements: {
    fire: number;
    earth: number;
    air: number;
    water: number;
  };
  modes: {
    cardinal: number;
    fixed: number;
    mutable: number;
  };
}

export class AstrologyService {

  /**
   * 计算完整星盘
   */
  async calculateChart(birthInfo: BirthInfo): Promise<NatalChartData> {
    const { birthDate, birthTime, latitude, longitude } = birthInfo;

    // 解析日期时间
    const [year, month, day] = birthDate.split('-').map(Number);
    const [hours, minutes] = birthTime.split(':').map(Number);
    const hour = hours + minutes / 60;

    // 计算儒略日
    const jd = calculateJulianDay(year, month, day, hour);

    // 计算行星位置
    const planetNames = ['sun', 'moon', 'mercury', 'venus', 'mars', 'jupiter', 'saturn', 'uranus', 'neptune', 'pluto'];
    const planets: Record<string, PlanetPosition> = {};
    const planetLongitudes: Record<string, number> = {};

    for (const name of planetNames) {
      const longitude = estimatePlanetLongitude(name, jd);
      planetLongitudes[name] = longitude;
      planets[name] = {
        sign: getZodiacSign(longitude),
        degree: Math.round(getSignDegree(longitude) * 100) / 100
      };
    }

    // 计算上升点
    const gst = calculateGST(jd);
    const lst = calculateLST(gst, longitude);
    const ascLongitude = calculateAscendant(lst * 15, latitude);

    // 计算12宫位（简化版本：等宫制）
    const houses: Record<string, House> = {};
    for (let i = 1; i <= 12; i++) {
      const houseLongitude = (ascLongitude + (i - 1) * 30) % 360;
      houses[i.toString()] = {
        sign: getZodiacSign(houseLongitude),
        degree: Math.round(getSignDegree(houseLongitude) * 100) / 100
      };
    }

    // 分配行星到宫位
    for (const [name, pos] of Object.entries(planets)) {
      const planetLng = planetLongitudes[name];
      let house = 1;

      for (let i = 1; i <= 12; i++) {
        const houseLng = (ascLongitude + (i - 1) * 30) % 360;
        const nextHouseLng = (ascLongitude + i * 30) % 360;

        if (houseLng <= nextHouseLng) {
          if (planetLng >= houseLng && planetLng < nextHouseLng) {
            house = i;
            break;
          }
        } else {
          // 跨0度情况
          if (planetLng >= houseLng || planetLng < nextHouseLng) {
            house = i;
            break;
          }
        }
      }

      pos.house = house;
    }

    // 计算相位
    const aspects: Aspect[] = [];
    const planetList = Object.entries(planetLongitudes);

    for (let i = 0; i < planetList.length; i++) {
      for (let j = i + 1; j < planetList.length; j++) {
        const [name1, lng1] = planetList[i];
        const [name2, lng2] = planetList[j];

        const aspect = calculateAspect(lng1, lng2);
        if (aspect) {
          aspects.push({
            planet1: name1,
            planet2: name2,
            aspect: aspect.aspect,
            orb: aspect.orb
          });
        }
      }
    }

    // 统计元素和模式
    const elements = countElements(planets);
    const modes = countModes(planets);

    return {
      sunSign: planets.sun.sign,
      sunDegree: planets.sun.degree,
      moonSign: planets.moon.sign,
      moonDegree: planets.moon.degree,
      risingSign: getZodiacSign(ascLongitude),
      risingDegree: Math.round(getSignDegree(ascLongitude) * 100) / 100,
      planets,
      houses,
      aspects,
      elements,
      modes
    };
  }

  /**
   * 计算两个星盘的配对分数
   */
  calculateCompatibility(chart1: NatalChartData, chart2: NatalChartData): {
    totalScore: number;
    dimensions: Record<string, number>;
  } {
    // 各维度权重
    const weights = {
      sunMoon: 0.20,      // 太阳-月亮
      moonMoon: 0.15,     // 月亮-月亮
      venus: 0.20,        // 金星相关
      mars: 0.10,         // 火星相关
      elements: 0.15,     // 元素平衡
      aspects: 0.20       // 跨盘相位
    };

    // 计算太阳-月亮配对
    const sunMoonScore = this.calcSunMoonCompatibility(chart1, chart2);

    // 计算月亮-月亮配对
    const moonMoonScore = this.calcElementCompatibility(
      chart1.planets.moon.sign,
      chart2.planets.moon.sign
    );

    // 计算金星配对
    const venusScore = this.calcElementCompatibility(
      chart1.planets.venus.sign,
      chart2.planets.venus.sign
    );

    // 计算火星配对
    const marsScore = this.calcElementCompatibility(
      chart1.planets.mars.sign,
      chart2.planets.mars.sign
    );

    // 计算元素平衡
    const elementsScore = this.calcElementsBalance(chart1.elements, chart2.elements);

    // 计算跨盘相位
    const aspectsScore = this.calcCrossAspects(chart1, chart2);

    // 加权计算总分
    const totalScore = Math.round(
      sunMoonScore * weights.sunMoon +
      moonMoonScore * weights.moonMoon +
      venusScore * weights.venus +
      marsScore * weights.mars +
      elementsScore * weights.elements +
      aspectsScore * weights.aspects
    );

    return {
      totalScore: Math.min(100, Math.max(0, totalScore)),
      dimensions: {
        overall: totalScore,
        communication: this.calcCommunicationScore(chart1, chart2),
        emotion: moonMoonScore,
        values: venusScore,
        attraction: Math.round((venusScore + marsScore) / 2),
        conflict: this.calcConflictScore(chart1, chart2),
        growth: this.calcGrowthScore(chart1, chart2)
      }
    };
  }

  /**
   * 太阳-月亮配对计算
   */
  private calcSunMoonCompatibility(chart1: NatalChartData, chart2: NatalChartData): number {
    // 计算A的太阳与B的月亮的配对
    const score1 = this.calcElementCompatibility(
      chart1.sunSign,
      chart2.moonSign
    );

    // 计算B的太阳与A的月亮的配对
    const score2 = this.calcElementCompatibility(
      chart2.sunSign,
      chart1.moonSign
    );

    return Math.round((score1 + score2) / 2);
  }

  /**
   * 基于元素的配对分数
   */
  private calcElementCompatibility(sign1: string, sign2: string): number {
    const element1 = getSignElement(sign1);
    const element2 = getSignElement(sign2);

    // 元素配对表
    const compatibility: Record<string, number> = {
      'fire-fire': 85,
      'fire-air': 90,
      'fire-earth': 60,
      'fire-water': 50,
      'air-fire': 90,
      'air-air': 80,
      'air-earth': 55,
      'air-water': 60,
      'earth-fire': 60,
      'earth-air': 55,
      'earth-earth': 80,
      'earth-water': 85,
      'water-fire': 50,
      'water-air': 60,
      'water-earth': 85,
      'water-water': 85
    };

    const key = `${element1}-${element2}`;
    return compatibility[key] || 70;
  }

  /**
   * 元素平衡计算
   */
  private calcElementsBalance(
    elements1: Record<string, number>,
    elements2: Record<string, number>
  ): number {
    // 计算互补性
    let complementScore = 0;

    // 如果一方某元素弱，另一方强，则互补加分
    const elementKeys = ['fire', 'earth', 'air', 'water'];
    for (const key of elementKeys) {
      const e1 = elements1[key] || 0;
      const e2 = elements2[key] || 0;

      if ((e1 <= 1 && e2 >= 3) || (e2 <= 1 && e1 >= 3)) {
        complementScore += 10;
      } else if (Math.abs(e1 - e2) <= 1) {
        complementScore += 5;
      }
    }

    return Math.min(100, 60 + complementScore);
  }

  /**
   * 跨盘相位计算
   */
  private calcCrossAspects(chart1: NatalChartData, chart2: NatalChartData): number {
    let score = 70; // 基础分

    // 检查主要行星的跨盘相位
    const majorPlanets = ['sun', 'moon', 'venus', 'mars'];

    for (const p1 of majorPlanets) {
      for (const p2 of majorPlanets) {
        const lng1 = this.signToDegree(chart1.planets[p1]?.sign) + (chart1.planets[p1]?.degree || 0);
        const lng2 = this.signToDegree(chart2.planets[p2]?.sign) + (chart2.planets[p2]?.degree || 0);

        const aspect = calculateAspect(lng1, lng2);
        if (aspect) {
          switch (aspect.aspect) {
            case '合相':
              score += 5;
              break;
            case '三分相':
              score += 4;
              break;
            case '六分相':
              score += 3;
              break;
            case '对冲':
              score += 2; // 对冲有吸引力但有挑战
              break;
            case '刑相':
              score -= 2; // 刑相有挑战
              break;
          }
        }
      }
    }

    return Math.min(100, Math.max(0, score));
  }

  /**
   * 沟通能力评分
   */
  private calcCommunicationScore(chart1: NatalChartData, chart2: NatalChartData): number {
    // 水星配对
    return this.calcElementCompatibility(
      chart1.planets.mercury?.sign || chart1.sunSign,
      chart2.planets.mercury?.sign || chart2.sunSign
    );
  }

  /**
   * 冲突评分
   */
  private calcConflictScore(chart1: NatalChartData, chart2: NatalChartData): number {
    // 火星配对 - 分数越低冲突越多
    const marsScore = this.calcElementCompatibility(
      chart1.planets.mars?.sign || chart1.sunSign,
      chart2.planets.mars?.sign || chart2.sunSign
    );

    // 反转分数表示冲突程度
    return 100 - marsScore;
  }

  /**
   * 成长空间评分
   */
  private calcGrowthScore(chart1: NatalChartData, chart2: NatalChartData): number {
    // 木星配对
    return this.calcElementCompatibility(
      chart1.planets.jupiter?.sign || chart1.sunSign,
      chart2.planets.jupiter?.sign || chart2.sunSign
    );
  }

  /**
   * 星座转换为度数
   */
  private signToDegree(sign: string): number {
    const signs = [
      '白羊座', '金牛座', '双子座', '巨蟹座',
      '狮子座', '处女座', '天秤座', '天蝎座',
      '射手座', '摩羯座', '水瓶座', '双鱼座'
    ];
    const index = signs.indexOf(sign);
    return index >= 0 ? index * 30 : 0;
  }
}

// 导出单例
export const astrologyService = new AstrologyService();
