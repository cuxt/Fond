import 'package:flutter/material.dart';
import 'package:fond/views/convertible_bond/utils/string_field_utils.dart';

/// 单日计算结果卡片
class SingleDayResultCard extends StatelessWidget {
  final Map<String, dynamic> calculationResult;
  final String? selectedField;
  final List<Map<String, dynamic>> tableHeaders;
  final String formattedDate;

  const SingleDayResultCard({
    super.key,
    required this.calculationResult,
    required this.selectedField,
    required this.tableHeaders,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 如果没有计算结果，显示空状态
    if (calculationResult.isEmpty) {
      return const SizedBox.shrink();
    }

    // 获取字段显示名称
    String fieldDisplayName =
        selectedField != null
            ? StringFieldUtils.getFieldDisplayName(selectedField!, tableHeaders)
            : '未选择字段';

    // 获取结果数值和计算类型
    final result = calculationResult['result'];
    final count = calculationResult['count'] ?? 0;
    final calculationType = calculationResult['type'] ?? '';
    final min = calculationResult['min'];
    final max = calculationResult['max'];
    final hasError = calculationResult['error'] != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '计算结果',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '日期: ${formattedDate.substring(0, 4)}-${formattedDate.substring(4, 6)}-${formattedDate.substring(6, 8)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 字段和计算类型信息
            Text('字段: $fieldDisplayName', style: theme.textTheme.bodyLarge),
            Text('计算类型: $calculationType', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),

            // 计算结果
            hasError
                ? _buildErrorResult(theme, calculationResult['error'])
                : _buildSuccessResult(theme, result, count, min, max),
          ],
        ),
      ),
    );
  }

  // 构建成功结果的展示
  Widget _buildSuccessResult(
    ThemeData theme,
    double? result,
    int count,
    double? min,
    double? max,
  ) {
    final hasResult = result != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 计算结果
        Row(
          children: [
            Text('计算结果: ', style: theme.textTheme.titleMedium),
            hasResult
                ? Text(
                  result.toStringAsFixed(4),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                )
                : Text(
                  '无数据',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.error,
                  ),
                ),
          ],
        ),

        // 统计信息
        const SizedBox(height: 8),
        Text('数据量: $count 条', style: theme.textTheme.bodyMedium),
        if (min != null && max != null) ...[
          const SizedBox(height: 4),
          Text(
            '最小值: ${min.toStringAsFixed(4)}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '最大值: ${max.toStringAsFixed(4)}',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  // 构建错误结果的展示
  Widget _buildErrorResult(ThemeData theme, String? errorMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Text(
              '计算出错',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          errorMessage ?? '未知错误',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      ],
    );
  }
}
