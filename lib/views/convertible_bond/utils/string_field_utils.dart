/// 字符串字段工具类
class StringFieldUtils {
  // 判断字段是否为字符串类型
  static bool isStringField(String fieldName) {
    // 这些字段明确是字符串类型
    final stringFields = [
      'p00868_f030', // 债券类型
      'bond_cd', 'jydm', // 债券代码
      'bond_nm', 'jydm_mc', // 债券名称
      'bond_id', // 债券ID
      'f004n_bond063', // 正股代码
      'p00868_f020', // 交易市场
    ];

    return stringFields.contains(fieldName);
  }

  // 获取字段显示名称
  static String getFieldDisplayName(
    String fieldName,
    List<Map<String, dynamic>> headers,
  ) {
    for (var header in headers) {
      if (header['name'] == fieldName) {
        return header['title'].toString().replaceFirst('2_', '');
      }
    }
    return fieldName;
  }
}
