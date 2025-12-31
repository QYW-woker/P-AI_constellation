import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/birth_info_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/main_tab_screen.dart';
import '../screens/chart/chart_screen.dart';
import '../screens/chart/chart_detail_screen.dart';
import '../screens/horoscope/horoscope_screen.dart';
import '../screens/horoscope/horoscope_detail_screen.dart';
import '../screens/friends/friends_screen.dart';
import '../screens/friends/add_friend_screen.dart';
import '../screens/compatibility/compatibility_screen.dart';
import '../screens/compatibility/compatibility_report_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/invite_screen.dart';
import '../screens/payment/membership_screen.dart';
import '../screens/payment/order_list_screen.dart';

/// 路由配置
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(BuildContext context) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final authProvider = context.read<AuthProvider>();
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login';
        final isBirthInfoRoute = state.matchedLocation == '/birth-info';

        // 未登录且不在登录页，跳转到登录页
        if (!isLoggedIn && !isLoginRoute) {
          return '/login';
        }

        // 已登录但在登录页，跳转到首页
        if (isLoggedIn && isLoginRoute) {
          // 检查是否需要填写出生信息
          if (!authProvider.hasBirthInfo) {
            return '/birth-info';
          }
          return '/';
        }

        return null;
      },
      routes: [
        // 登录
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        // 填写出生信息
        GoRoute(
          path: '/birth-info',
          name: 'birth-info',
          builder: (context, state) => const BirthInfoScreen(),
        ),

        // 主页面（带底部导航栏）
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => MainTabScreen(child: child),
          routes: [
            // 首页
            GoRoute(
              path: '/',
              name: 'home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
            ),

            // 星盘
            GoRoute(
              path: '/chart',
              name: 'chart',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ChartScreen(),
              ),
            ),

            // 好友
            GoRoute(
              path: '/friends',
              name: 'friends',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: FriendsScreen(),
              ),
            ),

            // 我的
            GoRoute(
              path: '/profile',
              name: 'profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileScreen(),
              ),
            ),
          ],
        ),

        // 星盘详情
        GoRoute(
          path: '/chart/detail',
          name: 'chart-detail',
          builder: (context, state) => const ChartDetailScreen(),
        ),

        // 运势
        GoRoute(
          path: '/horoscope',
          name: 'horoscope',
          builder: (context, state) => const HoroscopeScreen(),
        ),

        // 运势详情
        GoRoute(
          path: '/horoscope/detail',
          name: 'horoscope-detail',
          builder: (context, state) {
            final date = state.extra as DateTime?;
            return HoroscopeDetailScreen(date: date);
          },
        ),

        // 添加好友
        GoRoute(
          path: '/friends/add',
          name: 'add-friend',
          builder: (context, state) => const AddFriendScreen(),
        ),

        // 配对详情
        GoRoute(
          path: '/compatibility/:friendId',
          name: 'compatibility',
          builder: (context, state) {
            final friendId = state.pathParameters['friendId']!;
            return CompatibilityScreen(friendId: friendId);
          },
        ),

        // 配对报告
        GoRoute(
          path: '/compatibility/:friendId/report',
          name: 'compatibility-report',
          builder: (context, state) {
            final friendId = state.pathParameters['friendId']!;
            return CompatibilityReportScreen(friendId: friendId);
          },
        ),

        // 设置
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),

        // 邀请好友
        GoRoute(
          path: '/invite',
          name: 'invite',
          builder: (context, state) => const InviteScreen(),
        ),

        // 会员
        GoRoute(
          path: '/membership',
          name: 'membership',
          builder: (context, state) => const MembershipScreen(),
        ),

        // 订单列表
        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (context, state) => const OrderListScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('页面不存在: ${state.error}'),
        ),
      ),
    );
  }
}
