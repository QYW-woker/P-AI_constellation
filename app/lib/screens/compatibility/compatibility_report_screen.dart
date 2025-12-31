import 'package:flutter/material.dart';
import '../../config/theme.dart';

class CompatibilityReportScreen extends StatelessWidget {
  final String friendId;

  const CompatibilityReportScreen({super.key, required this.friendId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配对报告'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: const Center(
          child: Text(
            '配对报告详情',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
        ),
      ),
    );
  }
}
