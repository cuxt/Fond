import 'package:flutter/material.dart';
import 'package:fond/widgets/fond_button.dart';

/// 可转债分页组件
class BondPaginationWidget extends StatelessWidget {
  final int currentPage;
  final int pageSize;
  final int itemCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const BondPaginationWidget({
    super.key,
    required this.currentPage,
    required this.pageSize,
    required this.itemCount,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FondButton(
            onTap: currentPage > 1 ? onPrevious : null,
            buttonText: '上一页',
          ),
          const SizedBox(width: 16),
          Text('第 $currentPage 页'),
          const SizedBox(width: 16),
          FondButton(
            onTap: itemCount >= pageSize ? onNext : null,
            buttonText: '下一页',
          ),
        ],
      ),
    );
  }
}
