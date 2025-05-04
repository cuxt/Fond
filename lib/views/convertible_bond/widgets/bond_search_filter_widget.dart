import 'package:flutter/material.dart';

/// 可转债搜索和筛选组件
class BondSearchFilterWidget extends StatelessWidget {
  final TextEditingController searchController;
  final String filterBondType;
  final List<String> bondTypes;
  final ValueChanged<String?> onFilterChanged;

  const BondSearchFilterWidget({
    super.key,
    required this.searchController,
    required this.filterBondType,
    required this.bondTypes,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // 搜索框
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '搜索债券代码或名称',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
              onChanged: (value) {
                // 搜索内容变化时触发状态更新
              },
            ),
          ),
          const SizedBox(width: 16),
          // 债券类型筛选
          DropdownButton<String>(
            value: filterBondType,
            items:
                bondTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
            onChanged: onFilterChanged,
          ),
        ],
      ),
    );
  }
}
