# AI星座应用 - 后端服务

基于 Node.js + TypeScript + Express + Prisma 的星座应用后端服务。

## 技术栈

- **Runtime**: Node.js 18+
- **Language**: TypeScript 5.x
- **Framework**: Express 4.x
- **ORM**: Prisma 5.x
- **Database**: PostgreSQL 15+
- **Cache**: Redis 7+
- **AI**: OpenAI GPT-4

## 项目结构

```
server/
├── prisma/
│   └── schema.prisma          # 数据库模型定义
├── src/
│   ├── config/                # 配置文件
│   │   ├── constants.ts       # 常量定义
│   │   ├── database.ts        # 数据库配置
│   │   ├── redis.ts           # Redis配置
│   │   └── index.ts           # 主配置
│   ├── middleware/            # 中间件
│   │   ├── auth.middleware.ts # 认证中间件
│   │   └── rate-limit.ts      # 限流中间件
│   ├── modules/               # 业务模块
│   │   ├── auth/              # 认证模块
│   │   ├── user/              # 用户模块
│   │   ├── chart/             # 星盘模块
│   │   ├── horoscope/         # 运势模块
│   │   ├── friendship/        # 好友模块
│   │   ├── compatibility/     # 配对模块
│   │   ├── payment/           # 支付模块
│   │   └── share/             # 分享模块
│   ├── services/              # 公共服务
│   │   ├── sms.service.ts     # 短信服务
│   │   ├── astrology.service.ts # 星盘计算
│   │   ├── ai.service.ts      # AI内容生成
│   │   └── push.service.ts    # 推送服务
│   ├── utils/                 # 工具函数
│   │   ├── filter.ts          # 敏感词过滤
│   │   ├── helpers.ts         # 通用工具
│   │   └── zodiac.ts          # 星座工具
│   └── app.ts                 # 应用入口
├── .env.example               # 环境变量示例
├── package.json
└── tsconfig.json
```

## 环境要求

- Node.js >= 18.0.0
- PostgreSQL >= 15.0
- Redis >= 7.0
- npm >= 9.0.0

## 快速开始

### 1. 安装依赖

```bash
cd server
npm install
```

### 2. 配置环境变量

```bash
cp .env.example .env
```

编辑 `.env` 文件，配置以下必要参数：

```env
# 数据库
DATABASE_URL=postgresql://user:password@localhost:5432/starapp

# Redis
REDIS_URL=redis://localhost:6379

# JWT密钥 (至少32位)
JWT_SECRET=your_jwt_secret_key_at_least_32_characters

# 加密密钥 (32位十六进制)
ENCRYPTION_KEY=your_32_char_encryption_key_here

# OpenAI API
OPENAI_API_KEY=sk-your-openai-api-key
```

### 3. 初始化数据库

```bash
# 生成Prisma客户端
npx prisma generate

# 运行数据库迁移
npx prisma migrate dev --name init

# (可选) 查看数据库
npx prisma studio
```

### 4. 启动服务

```bash
# 开发模式
npm run dev

# 生产模式
npm run build
npm start
```

服务默认运行在 `http://localhost:3000`

## API文档

### 认证接口

| 方法 | 路径 | 描述 |
|------|------|------|
| POST | /api/v1/auth/sms/send | 发送验证码 |
| POST | /api/v1/auth/login/phone | 手机号登录 |
| POST | /api/v1/auth/login/wechat | 微信登录 |
| POST | /api/v1/auth/token/refresh | 刷新Token |
| POST | /api/v1/auth/logout | 登出 |

### 用户接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/v1/user/profile | 获取用户资料 |
| PUT | /api/v1/user/profile | 更新用户资料 |
| GET | /api/v1/user/membership | 获取会员信息 |
| GET | /api/v1/user/invite/info | 获取邀请信息 |
| POST | /api/v1/user/invite/apply | 应用邀请码 |

### 星盘接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/v1/chart | 获取星盘 |
| POST | /api/v1/chart | 生成星盘 |
| GET | /api/v1/chart/interpretation | 获取星盘解读 |

### 运势接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/v1/horoscope/daily | 获取每日运势 |
| GET | /api/v1/horoscope/weekly | 获取每周运势 |

### 好友接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/v1/friends | 获取好友列表 |
| POST | /api/v1/friends | 添加好友 |
| DELETE | /api/v1/friends/:friendId | 删除好友 |

### 配对接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/v1/compatibility/:friendId | 获取配对概览 |
| GET | /api/v1/compatibility/:friendId/report | 获取配对报告 |
| POST | /api/v1/compatibility/:friendId/report | 购买配对报告 |

### 支付接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/v1/payment/products | 获取商品列表 |
| POST | /api/v1/payment/order | 创建订单 |
| POST | /api/v1/payment/wechat/callback | 微信支付回调 |
| POST | /api/v1/payment/apple/verify | 苹果支付验证 |
| GET | /api/v1/payment/orders | 获取订单列表 |

### 分享接口

| 方法 | 路径 | 描述 |
|------|------|------|
| POST | /api/v1/share/horoscope | 生成运势分享卡片 |
| POST | /api/v1/share/compatibility | 生成配对分享卡片 |
| POST | /api/v1/share/profile | 生成性格卡片 |

### 城市接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/v1/cities/hot | 获取热门城市 |
| GET | /api/v1/cities/search | 搜索城市 |

## 响应格式

### 成功响应

```json
{
  "code": 0,
  "message": "success",
  "data": { ... }
}
```

### 错误响应

```json
{
  "code": 10001,
  "message": "错误描述",
  "data": null
}
```

### 错误码说明

| 错误码 | 描述 |
|--------|------|
| 0 | 成功 |
| 10000 | 系统错误 |
| 10001 | 参数错误 |
| 11001 | 未登录 |
| 11002 | Token过期 |
| 11003 | 无权限 |
| 12001 | 验证码发送失败 |
| 12002 | 验证码错误 |
| 12003 | 验证码过期 |
| 12004 | 邀请码无效 |
| 12005 | 出生信息未填写 |
| 13001 | 支付创建失败 |
| 13002 | 支付验证失败 |
| 13003 | 订单不存在 |
| 13004 | 商品不存在 |

## 数据库模型

主要数据表：

- **User** - 用户基本信息
- **BirthInfo** - 出生信息
- **NatalChart** - 本命星盘
- **DailyHoroscope** - 每日运势
- **Friendship** - 好友关系
- **CompatibilityReport** - 配对报告
- **Membership** - 会员信息
- **Purchase** - 购买记录
- **Order** - 订单记录
- **Invitation** - 邀请记录
- **City** - 城市数据
- **PushToken** - 推送Token
- **PushSettings** - 推送设置

## 开发命令

```bash
# 开发模式 (热重载)
npm run dev

# 构建
npm run build

# 生产模式
npm start

# 类型检查
npm run type-check

# 代码格式化
npm run format

# 数据库迁移
npm run db:migrate

# 数据库重置
npm run db:reset

# Prisma Studio
npm run db:studio
```

## 部署

### Docker部署

```bash
# 构建镜像
docker build -t starapp-server .

# 运行容器
docker run -d \
  --name starapp-server \
  -p 3000:3000 \
  -e DATABASE_URL=postgresql://... \
  -e REDIS_URL=redis://... \
  starapp-server
```

### PM2部署

```bash
# 安装PM2
npm install -g pm2

# 构建
npm run build

# 启动
pm2 start dist/app.js --name starapp-server

# 查看日志
pm2 logs starapp-server
```

## 注意事项

1. **安全配置**: 生产环境必须配置强密码和密钥
2. **敏感词过滤**: AI生成内容会自动过滤敏感词
3. **限流保护**: 接口已配置限流，防止恶意请求
4. **日志记录**: 安全相关操作会记录到SecurityLog表

## License

MIT
