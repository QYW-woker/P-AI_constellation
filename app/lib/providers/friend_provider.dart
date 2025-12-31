import 'package:flutter/foundation.dart';
import '../models/friend.dart';
import '../models/compatibility.dart';
import '../services/friend_service.dart';
import '../services/compatibility_service.dart';

/// 好友状态管理
class FriendProvider extends ChangeNotifier {
  final FriendService _friendService = FriendService();
  final CompatibilityService _compatibilityService = CompatibilityService();

  List<Friend> _friends = [];
  Map<String, CompatibilityOverview> _compatibilityCache = {};
  Map<String, CompatibilityReport> _reportCache = {};
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;

  // Getters
  List<Friend> get friends => _friends;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  int get friendCount => _friends.length;
  bool get hasFriends => _friends.isNotEmpty;

  /// 获取好友列表
  Future<void> fetchFriends({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await _friendService.getFriends(
        page: _currentPage,
        pageSize: 20,
      );

      if (response.isSuccess && response.data != null) {
        if (refresh) {
          _friends = response.data!;
        } else {
          _friends.addAll(response.data!);
        }
        _hasMore = response.data!.length >= 20;
        _currentPage++;
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('获取好友列表失败');
      debugPrint('Fetch friends error: $e');
    }

    _setLoading(false);
  }

  /// 添加好友（通过用户ID）
  Future<bool> addFriendById(String friendId) async {
    _clearError();

    try {
      final response = await _friendService.addFriendById(friendId);

      if (response.isSuccess && response.data != null) {
        _friends.insert(0, response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('添加好友失败');
      debugPrint('Add friend error: $e');
      return false;
    }
  }

  /// 添加好友（通过邀请码）
  Future<bool> addFriendByCode(String inviteCode) async {
    _clearError();

    try {
      final response = await _friendService.addFriendByCode(inviteCode);

      if (response.isSuccess && response.data != null) {
        _friends.insert(0, response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('添加好友失败');
      debugPrint('Add friend by code error: $e');
      return false;
    }
  }

  /// 删除好友
  Future<bool> removeFriend(String friendId) async {
    _clearError();

    try {
      final response = await _friendService.removeFriend(friendId);

      if (response.isSuccess) {
        _friends.removeWhere((f) => f.friendId == friendId);
        _compatibilityCache.remove(friendId);
        _reportCache.remove(friendId);
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('删除好友失败');
      debugPrint('Remove friend error: $e');
      return false;
    }
  }

  /// 获取配对概览
  Future<CompatibilityOverview?> getCompatibilityOverview(String friendId) async {
    // 检查缓存
    if (_compatibilityCache.containsKey(friendId)) {
      return _compatibilityCache[friendId];
    }

    try {
      final response = await _compatibilityService.getOverview(friendId);

      if (response.isSuccess && response.data != null) {
        _compatibilityCache[friendId] = response.data!;
        return response.data;
      }
    } catch (e) {
      debugPrint('Get compatibility overview error: $e');
    }

    return null;
  }

  /// 获取配对报告
  Future<CompatibilityReport?> getCompatibilityReport(String friendId) async {
    // 检查缓存
    if (_reportCache.containsKey(friendId)) {
      return _reportCache[friendId];
    }

    try {
      final response = await _compatibilityService.getReport(friendId);

      if (response.isSuccess && response.data != null) {
        _reportCache[friendId] = response.data!;
        return response.data;
      }
    } catch (e) {
      debugPrint('Get compatibility report error: $e');
    }

    return null;
  }

  /// 购买配对报告
  Future<CompatibilityReport?> purchaseReport(String friendId) async {
    try {
      final response = await _compatibilityService.purchaseReport(friendId);

      if (response.isSuccess && response.data != null) {
        _reportCache[friendId] = response.data!;
        return response.data;
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('购买报告失败');
      debugPrint('Purchase report error: $e');
    }

    return null;
  }

  /// 根据ID获取好友
  Friend? getFriendById(String friendId) {
    try {
      return _friends.firstWhere((f) => f.friendId == friendId);
    } catch (e) {
      return null;
    }
  }

  /// 清空缓存
  void clearCache() {
    _compatibilityCache.clear();
    _reportCache.clear();
  }

  /// 清空数据
  void clear() {
    _friends = [];
    _compatibilityCache = {};
    _reportCache = {};
    _currentPage = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
