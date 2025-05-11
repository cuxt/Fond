import 'package:flutter/material.dart';
import 'package:fond/views/convertible_bond/models/filter_condition.dart';
import 'package:fond/views/convertible_bond/utils/string_field_utils.dart';

/// 过滤条件组件
class FilterConditionWidget extends StatelessWidget {
  final FilterCondition condition;
  final List<Map<String, dynamic>> fields;
  final Function(FilterCondition) onChanged;
  final VoidCallback onRemoved;

  const FilterConditionWidget({
    super.key,
    required this.condition,
    required this.fields,
    required this.onChanged,
    required this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
    // 根据字段类型选择不同的操作符
    final numericOperators = ['大于', '小于', '等于', '大于等于', '小于等于', '不等于'];
    final stringOperators = ['等于', '不等于', '包含', '不包含', '开头是', '结尾是'];

    // 判断当前字段类型
    final isString = StringFieldUtils.isStringField(condition.field);
    final operators = isString ? stringOperators : numericOperators;

    // 如果切换了字段类型，可能需要调整操作符
    String currentOperator = condition.operator;
    if (!operators.contains(currentOperator)) {
      currentOperator = operators.first;
    }

    return Row(
      children: [
        // 字段选择
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: '字段',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            value:
                condition.field.isNotEmpty
                    ? condition.field
                    : fields.first['name'].toString(),
            items:
                fields.map((field) {
                  return DropdownMenuItem<String>(
                    value: field['name'].toString(),
                    child: Text(
                      field['title'].toString().replaceFirst('2_', ''),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                // 字段改变时，如果类型也改变了，则重置操作符为新类型的默认值
                bool newIsString = StringFieldUtils.isStringField(value);
                String newOperator = condition.operator;

                if (isString != newIsString) {
                  newOperator =
                      newIsString
                          ? stringOperators.first
                          : numericOperators.first;
                }

                onChanged(
                  FilterCondition(
                    field: value,
                    operator: newOperator,
                    value: condition.value,
                  ),
                );
              }
            },
          ),
        ),

        const SizedBox(width: 8),

        // 操作符选择
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: '条件',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            value: currentOperator,
            items:
                operators.map((op) {
                  return DropdownMenuItem<String>(value: op, child: Text(op));
                }).toList(),
            onChanged: (value) {
              onChanged(
                FilterCondition(
                  field: condition.field,
                  operator: value!,
                  value: condition.value,
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 8),

        // 值输入
        Expanded(
          flex: 1,
          child: TextFormField(
            decoration: InputDecoration(
              labelText: '值',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              hintText: isString ? '输入文本' : '输入数字',
            ),
            initialValue: condition.value,
            keyboardType: isString ? TextInputType.text : TextInputType.number,
            onChanged: (value) {
              onChanged(
                FilterCondition(
                  field: condition.field,
                  operator: currentOperator,
                  value: value,
                ),
              );
            },
          ),
        ),

        // 删除按钮
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onRemoved,
        ),
      ],
    );
  }
}
