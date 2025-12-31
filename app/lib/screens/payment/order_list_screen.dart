import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../widgets/common/loading_overlay.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订单记录'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: const EmptyPlaceholder(
          icon: Icons.receipt_long,
          message: '暂无订单记录',
        ),
      ),
    );
  }
}
