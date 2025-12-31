import 'package:flutter/foundation.dart';
import '../models/horoscope.dart';
import '../services/horoscope_service.dart';

/// 运势状态管理
class HoroscopeProvider extends ChangeNotifier {
  final HoroscopeService _horoscopeService = HoroscopeService();

  DailyHoroscope? _todayHoroscope;
  WeeklyHoroscope? _weeklyHoroscope;
  List<DailyHoroscope> _history = [];
  bool _isLoading = false;
  bool _isLoadingWeekly = false;
  String? _error;
  DateTime? _lastFetchDate;

  // Getters
  DailyHoroscope? get todayHoroscope => _todayHoroscope;
  WeeklyHoroscope? get weeklyHoroscope => _weeklyHoroscope;
  List<DailyHoroscope> get history => _history;
  bool get isLoading => _isLoading;
  bool get isLoadingWeekly => _isLoadingWeekly;
  String? get error => _error;
  bool get hasTodayHoroscope => _todayHoroscope != null;
  bool get hasWeeklyHoroscope => _weeklyHoroscope != null;

  // 今日运势快捷访问
  int? get overallScore => _todayHoroscope?.scores.overall;
  int? get loveScore => _todayHoroscope?.scores.love;
  int? get careerScore => _todayHoroscope?.scores.career;
  int? get wealthScore => _todayHoroscope?.scores.wealth;
  int? get healthScore => _todayHoroscope?.scores.health;
  String? get summary => _todayHoroscope?.summary;
  List<String>? get doList => _todayHoroscope?.doList;
  List<String>? get dontList => _todayHoroscope?.dontList;
  String? get luckyColor => _todayHoroscope?.luckyColor;
  int? get luckyNumber => _todayHoroscope?.luckyNumber;

  /// 获取今日运势
  Future<void> fetchTodayHoroscope({bool forceRefresh = false}) async {
    // 检查是否需要刷新
    if (!forceRefresh && _todayHoroscope != null) {
      final now = DateTime.now();
      if (_lastFetchDate != null &&
          _lastFetchDate!.year == now.year &&
          _lastFetchDate!.month == now.month &&
          _lastFetchDate!.day == now.day) {
        return;
      }
    }

    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await _horoscopeService.getDailyHoroscope();

      if (response.isSuccess && response.data != null) {
        _todayHoroscope = response.data;
        _lastFetchDate = DateTime.now();
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('获取运势失败');
      debugPrint('Fetch horoscope error: $e');
    }

    _setLoading(false);
  }

  /// 获取指定日期运势
  Future<DailyHoroscope?> fetchHoroscopeByDate(DateTime date) async {
    try {
      final response = await _horoscopeService.getDailyHoroscope(date: date);

      if (response.isSuccess && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('Fetch horoscope by date error: $e');
    }
    return null;
  }

  /// 获取每周运势
  Future<void> fetchWeeklyHoroscope() async {
    if (_isLoadingWeekly) return;

    _isLoadingWeekly = true;
    _clearError();
    notifyListeners();

    try {
      final response = await _horoscopeService.getWeeklyHoroscope();

      if (response.isSuccess && response.data != null) {
        _weeklyHoroscope = response.data;
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('获取周运势失败');
      debugPrint('Fetch weekly horoscope error: $e');
    }

    _isLoadingWeekly = false;
    notifyListeners();
  }

  /// 获取历史运势
  Future<void> fetchHistory({int page = 1, int pageSize = 7}) async {
    try {
      final response = await _horoscopeService.getHoroscopeHistory(
        page: page,
        pageSize: pageSize,
      );

      if (response.isSuccess && response.data != null) {
        if (page == 1) {
          _history = response.data!;
        } else {
          _history.addAll(response.data!);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch history error: $e');
    }
  }

  /// 刷新全部数据
  Future<void> refresh() async {
    await Future.wait([
      fetchTodayHoroscope(forceRefresh: true),
      fetchWeeklyHoroscope(),
    ]);
  }

  /// 清空数据
  void clear() {
    _todayHoroscope = null;
    _weeklyHoroscope = null;
    _history = [];
    _lastFetchDate = null;
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
