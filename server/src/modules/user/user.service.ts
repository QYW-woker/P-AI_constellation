/**
 * 用户服务
 */
import prisma from '../../config/database';
import { getCacheService } from '../../config/redis';
import { maskPhone } from '../../utils/filter';
import { CACHE_TTL, MAJOR_CITIES, ERROR_CODES } from '../../config/constants';
import {
  UpdateUserDto,
  SubmitBirthInfoDto,
  UserProfileResponse,
  BirthInfoResponse
} from './user.dto';
import { astrologyService } from '../../services/astrology.service';

export class UserService {
  private cache = getCacheService();

  /**
   * 获取当前用户信息
   */
  async getCurrentUser(userId: string): Promise<UserProfileResponse> {
    // 先从缓存获取
    const cached = await this.cache.get<UserProfileResponse>(`user:profile:${userId}`);
    if (cached) {
      return cached;
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        birthInfo: true,
        natalChart: true,
        friendshipsAsUser: {
          where: { status: 1 }
        }
      }
    });

    if (!user) {
      throw new Error(ERROR_CODES[11005]);
    }

    const profile: UserProfileResponse = {
      id: user.id,
      phone: user.phone ? maskPhone(user.phone) : undefined,
      nickname: user.nickname || undefined,
      avatarUrl: user.avatarUrl || undefined,
      gender: user.gender || undefined,
      isVip: user.isVip,
      vipExpireAt: user.vipExpireAt?.toISOString(),
      inviteCode: user.inviteCode,
      friendCount: user.friendshipsAsUser.length,
      birthInfo: user.birthInfo ? {
        birthDate: user.birthInfo.birthDate.toISOString().split('T')[0],
        birthTime: user.birthInfo.birthTime.toISOString().split('T')[1].substring(0, 5),
        birthCity: user.birthInfo.birthCity
      } : undefined,
      chart: user.natalChart ? {
        sunSign: user.natalChart.sunSign,
        moonSign: user.natalChart.moonSign,
        risingSign: user.natalChart.risingSign
      } : undefined
    };

    // 缓存1小时
    await this.cache.set(`user:profile:${userId}`, profile, CACHE_TTL.user);

    return profile;
  }

  /**
   * 更新用户信息
   */
  async updateUser(userId: string, dto: UpdateUserDto): Promise<UserProfileResponse> {
    const updateData: Record<string, unknown> = {};

    if (dto.nickname !== undefined) {
      updateData.nickname = dto.nickname;
    }
    if (dto.avatarUrl !== undefined) {
      updateData.avatarUrl = dto.avatarUrl;
    }
    if (dto.gender !== undefined) {
      updateData.gender = dto.gender;
    }

    await prisma.user.update({
      where: { id: userId },
      data: updateData
    });

    // 清除缓存
    await this.cache.del(`user:profile:${userId}`);

    return this.getCurrentUser(userId);
  }

  /**
   * 提交出生信息并计算星盘
   */
  async submitBirthInfo(userId: string, dto: SubmitBirthInfoDto): Promise<BirthInfoResponse> {
    // 查找城市经纬度
    const cityData = await this.findCityCoordinates(dto.birthCity);

    // 解析日期和时间
    const birthDate = new Date(dto.birthDate);
    const [hours, minutes] = dto.birthTime.split(':').map(Number);
    const birthTimeDate = new Date(1970, 0, 1, hours, minutes);

    // 创建或更新出生信息
    const birthInfo = await prisma.birthInfo.upsert({
      where: { userId },
      create: {
        userId,
        birthDate,
        birthTime: birthTimeDate,
        birthCity: dto.birthCity,
        birthProvince: dto.birthProvince || cityData.province,
        birthCountry: dto.birthCountry || '中国',
        latitude: cityData.latitude,
        longitude: cityData.longitude,
        timezone: 'Asia/Shanghai'
      },
      update: {
        birthDate,
        birthTime: birthTimeDate,
        birthCity: dto.birthCity,
        birthProvince: dto.birthProvince || cityData.province,
        birthCountry: dto.birthCountry || '中国',
        latitude: cityData.latitude,
        longitude: cityData.longitude
      }
    });

    // 计算星盘
    const chart = await astrologyService.calculateChart({
      birthDate: dto.birthDate,
      birthTime: dto.birthTime,
      latitude: Number(cityData.latitude),
      longitude: Number(cityData.longitude),
      timezone: 'Asia/Shanghai'
    });

    // 保存星盘数据
    await prisma.natalChart.upsert({
      where: { userId },
      create: {
        userId,
        sunSign: chart.sunSign,
        sunDegree: chart.sunDegree,
        moonSign: chart.moonSign,
        moonDegree: chart.moonDegree,
        risingSign: chart.risingSign,
        risingDegree: chart.risingDegree,
        planets: chart.planets,
        houses: chart.houses,
        aspects: chart.aspects,
        elementFire: chart.elements.fire,
        elementEarth: chart.elements.earth,
        elementAir: chart.elements.air,
        elementWater: chart.elements.water,
        modeCardinal: chart.modes.cardinal,
        modeFixed: chart.modes.fixed,
        modeMutable: chart.modes.mutable
      },
      update: {
        sunSign: chart.sunSign,
        sunDegree: chart.sunDegree,
        moonSign: chart.moonSign,
        moonDegree: chart.moonDegree,
        risingSign: chart.risingSign,
        risingDegree: chart.risingDegree,
        planets: chart.planets,
        houses: chart.houses,
        aspects: chart.aspects,
        elementFire: chart.elements.fire,
        elementEarth: chart.elements.earth,
        elementAir: chart.elements.air,
        elementWater: chart.elements.water,
        modeCardinal: chart.modes.cardinal,
        modeFixed: chart.modes.fixed,
        modeMutable: chart.modes.mutable
      }
    });

    // 清除缓存
    await this.cache.del(`user:profile:${userId}`);

    return {
      birthInfo: {
        birthDate: dto.birthDate,
        birthTime: dto.birthTime,
        birthCity: dto.birthCity,
        birthProvince: dto.birthProvince,
        birthCountry: dto.birthCountry || '中国'
      },
      chart: {
        sunSign: chart.sunSign,
        sunDegree: chart.sunDegree,
        moonSign: chart.moonSign,
        moonDegree: chart.moonDegree,
        risingSign: chart.risingSign,
        risingDegree: chart.risingDegree,
        planets: chart.planets,
        houses: chart.houses,
        elements: chart.elements
      }
    };
  }

  /**
   * 查找城市经纬度
   */
  private async findCityCoordinates(cityName: string): Promise<{
    latitude: number;
    longitude: number;
    province?: string;
  }> {
    // 先从数据库查找
    const city = await prisma.city.findFirst({
      where: {
        OR: [
          { name: cityName },
          { name: { contains: cityName } }
        ]
      }
    });

    if (city) {
      return {
        latitude: Number(city.latitude),
        longitude: Number(city.longitude),
        province: city.province || undefined
      };
    }

    // 从常量中查找
    const majorCity = MAJOR_CITIES.find(c => c.name === cityName);
    if (majorCity) {
      return {
        latitude: majorCity.lat,
        longitude: majorCity.lng,
        province: majorCity.province
      };
    }

    // 默认使用北京经纬度
    console.warn(`City not found: ${cityName}, using Beijing coordinates`);
    return {
      latitude: 39.9042,
      longitude: 116.4074,
      province: undefined
    };
  }
}

// 导出单例
export const userService = new UserService();
