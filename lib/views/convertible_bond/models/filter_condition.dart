/// 过滤条件模型
class FilterCondition {
  String field;
  String operator;
  String value;

  FilterCondition({
    required this.field,
    required this.operator,
    required this.value,
  });

  // 创建副本的方法
  FilterCondition copy() {
    return FilterCondition(field: field, operator: operator, value: value);
  }
}
