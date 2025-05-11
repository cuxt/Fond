import 'package:flutter/material.dart';
import 'package:fond/views/convertible_bond/utils/export_utils.dart';
import 'package:fond/views/convertible_bond/utils/string_field_utils.dart';

/// 批量计算结果表格
class BatchResultTable extends StatelessWidget {
  final List<Map<String, dynamic>> batchResults;
  final String? selectedField;
  final String selectedCalculation;
  final List<Map<String, dynamic>> tableHeaders;

  const BatchResultTable({
    super.key,
    required this.batchResults,
    required this.selectedField,
    required this.selectedCalculation,
    required this.tableHeaders,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 如果没有计算结果，显示空状态
    if (batchResults.isEmpty) {
      return const SizedBox.shrink();
    }

    // 获取字段显示名称
    String fieldDisplayName =
        selectedField != null
            ? StringFieldUtils.getFieldDisplayName(selectedField!, tableHeaders)
            : '未选择字段';

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
            // 标题和导出按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '批量计算结果',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_download),
                  label: const Text('导出CSV'),
                  onPressed: () => _exportToCSV(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 计算信息
            Text('字段: $fieldDisplayName', style: theme.textTheme.bodyLarge),
            Text(
              '计算类型: $selectedCalculation',
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              '数据条数: ${batchResults.length}',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // 结果表格
            _buildResultsTable(theme),
          ],
        ),
      ),
    );
  }

  // 构建结果表格
  Widget _buildResultsTable(ThemeData theme) {
    return Column(
      children: [
        // 表头
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '日期',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '结果值',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '数据量',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 表格内容 - 使用ListView构建可滚动的表格内容
        Container(
          constraints: const BoxConstraints(maxHeight: 350),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: batchResults.length,
            itemBuilder: (context, index) {
              final result = batchResults[index];
              final date = result['display_date'] ?? '';
              final value = result['result'];
              final count = result['count'] ?? 0;
              final hasError = result['error'] != null;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color:
                      index % 2 == 0
                          ? theme.colorScheme.surface
                          : theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                  border: Border(
                    bottom:
                        index < batchResults.length - 1
                            ? BorderSide(color: theme.dividerColor)
                            : BorderSide.none,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(date, style: theme.textTheme.bodyMedium),
                    ),
                    Expanded(
                      flex: 3,
                      child:
                          hasError
                              ? Text(
                                '计算错误',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: theme.colorScheme.error,
                                ),
                              )
                              : value != null
                              ? Text(
                                value.toStringAsFixed(4),
                                style: theme.textTheme.bodyMedium,
                              )
                              : Text(
                                '无数据',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        count.toString(),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 导出CSV
  void _exportToCSV(BuildContext context) {
    if (selectedField == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择字段')));
      return;
    }

    ExportUtils.exportToCSV(
      context: context,
      batchResults: batchResults,
      selectedField: selectedField!,
      selectedCalculation: selectedCalculation,
      tableHeaders: tableHeaders,
    );
  }
}
