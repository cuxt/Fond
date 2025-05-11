import 'package:flutter/material.dart';
import 'package:fond/views/convertible_bond/models/filter_condition.dart';
import 'package:fond/views/convertible_bond/widgets/filter_condition_widget.dart';
import 'package:fond/widgets/fond_button.dart';

/// 计算配置卡片
class CalculationConfigCard extends StatelessWidget {
  final String? selectedField;
  final String selectedCalculation;
  final List<String> calculationTypes;
  final List<Map<String, dynamic>> tableHeaders;
  final List<FilterCondition> filterConditions;
  final Function(String?) onFieldChanged;
  final Function(String) onCalculationTypeChanged;
  final VoidCallback onAddFilterCondition;
  final Function(int, FilterCondition) onUpdateFilterCondition;
  final Function(int) onRemoveFilterCondition;
  final VoidCallback onCalculate;
  final bool isBatchMode;

  const CalculationConfigCard({
    super.key,
    required this.selectedField,
    required this.selectedCalculation,
    required this.calculationTypes,
    required this.tableHeaders,
    required this.filterConditions,
    required this.onFieldChanged,
    required this.onCalculationTypeChanged,
    required this.onAddFilterCondition,
    required this.onUpdateFilterCondition,
    required this.onRemoveFilterCondition,
    required this.onCalculate,
    required this.isBatchMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '计算配置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // 字段选择
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '选择字段',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedField,
                    items:
                        tableHeaders.map((header) {
                          return DropdownMenuItem<String>(
                            value: header['name'].toString(),
                            child: Text(
                              header['title'].toString().replaceFirst('2_', ''),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                    onChanged: onFieldChanged,
                  ),
                ),
                const SizedBox(width: 16),

                // 计算类型选择
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '计算类型',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedCalculation,
                    items:
                        calculationTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onCalculationTypeChanged(value);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 过滤条件
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '过滤条件',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),

                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('添加条件'),
                  onPressed: onAddFilterCondition,
                ),
              ],
            ),

            const SizedBox(height: 8),

            ...filterConditions.asMap().entries.map((entry) {
              int index = entry.key;
              FilterCondition condition = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: FilterConditionWidget(
                  condition: condition,
                  fields: tableHeaders,
                  onChanged: (newCondition) {
                    onUpdateFilterCondition(index, newCondition);
                  },
                  onRemoved: () {
                    onRemoveFilterCondition(index);
                  },
                ),
              );
            }).toList(),

            if (filterConditions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '无过滤条件，将计算所有数据',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

            const SizedBox(height: 24), // 计算按钮
            Center(
              child: FondButton(
                onTap: onCalculate,
                buttonText: isBatchMode ? '执行批量计算' : '执行计算',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
