import 'package:fond/views/convertible_bond/models/convertible_bond.dart';

/// 可转债过滤工具类
class BondFilter {
  /// 根据搜索条件和债券类型筛选可转债列表
  static List<ConvertibleBond> filterBonds(
    List<ConvertibleBond> bonds,
    String searchText,
    String bondType,
  ) {
    if (searchText.isEmpty && bondType == '全部') {
      return bonds;
    }

    return bonds.where((bond) {
      // 根据债券类型筛选
      bool matchesType =
          bondType == '全部' ||
          bond.bondType == bondType ||
          bond.market.contains(bondType);

      // 根据搜索文本筛选
      bool matchesSearch =
          searchText.isEmpty ||
          bond.bondCode.contains(searchText) ||
          bond.bondName.contains(searchText);

      return matchesType && matchesSearch;
    }).toList();
  }
}
