import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/chart_service.dart';

/// 星盘状态管理
class ChartProvider extends ChangeNotifier {
  final ChartService _chartService = ChartService();

  NatalChart? _chart;
  ChartInterpretation? _interpretation;
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _error;

  // Getters
  NatalChart? get chart => _chart;
  ChartInterpretation? get interpretation => _interpretation;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get error => _error;
  bool get hasChart => _chart != null;
  bool get hasInterpretation => _interpretation != null;

  // 星盘数据快捷访问
  String? get sunSign => _chart?.sunSign;
  String? get moonSign => _chart?.moonSign;
  String? get risingSign => _chart?.risingSign;
  List<PlanetPosition>? get planets => _chart?.planets;
  List<HouseInfo>? get houses => _chart?.houses;
  List<AspectInfo>? get aspects => _chart?.aspects;
  Map<String, int>? get elementCounts => _chart?.elementCounts;
  Map<String, int>? get modeCounts => _chart?.modeCounts;

  /// 获取星盘
  Future<void> fetchChart() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await _chartService.getChart();

      if (response.isSuccess && response.data != null) {
        _chart = response.data;
      } else if (response.code == 12005) {
        // 出生信息未填写
        _chart = null;
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('获取星盘失败');
      debugPrint('Fetch chart error: $e');
    }

    _setLoading(false);
  }

  /// 生成星盘
  Future<bool> generateChart() async {
    if (_isGenerating) return false;

    _isGenerating = true;
    _clearError();
    notifyListeners();

    try {
      final response = await _chartService.generateChart();

      _isGenerating = false;

      if (response.isSuccess && response.data != null) {
        _chart = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isGenerating = false;
      _setError('生成星盘失败');
      notifyListeners();
      debugPrint('Generate chart error: $e');
      return false;
    }
  }

  /// 获取星盘解读
  Future<void> fetchInterpretation() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await _chartService.getInterpretation();

      if (response.isSuccess && response.data != null) {
        _interpretation = response.data;
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('获取解读失败');
      debugPrint('Fetch interpretation error: $e');
    }

    _setLoading(false);
  }

  /// 刷新全部数据
  Future<void> refresh() async {
    await Future.wait([
      fetchChart(),
      fetchInterpretation(),
    ]);
  }

  /// 清空数据
  void clear() {
    _chart = null;
    _interpretation = null;
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
