import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/theme.dart';
import '../../models/city.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chart_provider.dart';
import '../../services/city_service.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/loading_overlay.dart';

class BirthInfoScreen extends StatefulWidget {
  const BirthInfoScreen({super.key});

  @override
  State<BirthInfoScreen> createState() => _BirthInfoScreenState();
}

class _BirthInfoScreenState extends State<BirthInfoScreen> {
  final CityService _cityService = CityService();
  final _searchController = TextEditingController();

  DateTime _birthDate = DateTime(2000, 1, 1);
  TimeOfDay _birthTime = const TimeOfDay(hour: 12, minute: 0);
  City? _selectedCity;
  List<City> _hotCities = [];
  List<City> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadHotCities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHotCities() async {
    setState(() => _isLoading = true);

    final response = await _cityService.getHotCities();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _hotCities = response.data!;
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _searchCities(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final response = await _cityService.searchCities(keyword);
    if (response.isSuccess && response.data != null) {
      setState(() {
        _searchResults = response.data!;
      });
    }

    setState(() => _isSearching = false);
  }

  Future<void> _selectDate() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: AppTheme.surfaceColor,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('取消'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('确定'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _birthDate,
                  minimumDate: DateTime(1900),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (date) {
                    setState(() => _birthDate = date);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectTime() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: AppTheme.surfaceColor,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('取消'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('确定'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: DateTime(
                    2000,
                    1,
                    1,
                    _birthTime.hour,
                    _birthTime.minute,
                  ),
                  onDateTimeChanged: (date) {
                    setState(() {
                      _birthTime = TimeOfDay(
                        hour: date.hour,
                        minute: date.minute,
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    // 拖动条
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textHint,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // 搜索框
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: '搜索城市',
                          prefixIcon: Icon(Icons.search, color: AppTheme.textHint),
                        ),
                        onChanged: (value) {
                          _searchCities(value);
                          setModalState(() {});
                        },
                      ),
                    ),

                    // 城市列表
                    Expanded(
                      child: _isSearching
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingM,
                              ),
                              itemCount: _searchController.text.isNotEmpty
                                  ? _searchResults.length
                                  : _hotCities.length,
                              itemBuilder: (context, index) {
                                final city = _searchController.text.isNotEmpty
                                    ? _searchResults[index]
                                    : _hotCities[index];

                                return ListTile(
                                  title: Text(
                                    city.name,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    city.province,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: AppTheme.fontSizeS,
                                    ),
                                  ),
                                  trailing: _selectedCity?.id == city.id
                                      ? const Icon(
                                          Icons.check,
                                          color: AppTheme.primaryColor,
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() => _selectedCity = city);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _save() async {
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择出生城市')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final authProvider = context.read<AuthProvider>();
    final chartProvider = context.read<ChartProvider>();

    final timeString =
        '${_birthTime.hour.toString().padLeft(2, '0')}:${_birthTime.minute.toString().padLeft(2, '0')}';

    final success = await authProvider.updateBirthInfo(
      birthDate: _birthDate,
      birthTime: timeString,
      birthCity: _selectedCity!.name,
      latitude: _selectedCity!.latitude,
      longitude: _selectedCity!.longitude,
      timezone: _selectedCity!.timezone,
    );

    if (success) {
      // 生成星盘
      await chartProvider.generateChart();
      if (mounted) {
        context.go('/');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? '保存失败')),
        );
      }
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy年MM月dd日');

    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isSaving,
        message: '正在生成星盘...',
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // 标题
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            size: 40,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '填写出生信息',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '精准的出生信息是星盘计算的基础',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // 出生日期
                  _buildSectionTitle('出生日期'),
                  const SizedBox(height: 8),
                  _buildSelectItem(
                    icon: Icons.calendar_today,
                    title: dateFormat.format(_birthDate),
                    onTap: _selectDate,
                  ),

                  const SizedBox(height: 24),

                  // 出生时间
                  _buildSectionTitle('出生时间'),
                  const SizedBox(height: 8),
                  _buildSelectItem(
                    icon: Icons.access_time,
                    title:
                        '${_birthTime.hour.toString().padLeft(2, '0')}:${_birthTime.minute.toString().padLeft(2, '0')}',
                    subtitle: '尽量精确，影响上升星座计算',
                    onTap: _selectTime,
                  ),

                  const SizedBox(height: 24),

                  // 出生城市
                  _buildSectionTitle('出生城市'),
                  const SizedBox(height: 8),
                  _buildSelectItem(
                    icon: Icons.location_on,
                    title: _selectedCity?.name ?? '请选择',
                    subtitle: _selectedCity?.province,
                    onTap: _showCityPicker,
                  ),

                  const SizedBox(height: 48),

                  // 保存按钮
                  GradientButton(
                    text: '生成我的星盘',
                    onPressed: _save,
                    isLoading: _isSaving,
                  ),

                  const SizedBox(height: 16),

                  // 提示
                  Center(
                    child: Text(
                      '出生信息仅用于星盘计算，我们将严格保护您的隐私',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: AppTheme.fontSizeM,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSelectItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.fontSizeL,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textHint,
                        fontSize: AppTheme.fontSizeS,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
