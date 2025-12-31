import 'package:flutter/material.dart';
import '../../config/theme.dart';

class HoroscopeDetailScreen extends StatelessWidget {
  final DateTime? date;

  const HoroscopeDetailScreen({super.key, this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('运势详情'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: const Center(
          child: Text(
            '运势详情页面',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
        ),
      ),
    );
  }
}
