import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fond/views/convertible_bond/models/convertible_bond.dart';
import 'package:fond/views/convertible_bond/widgets/bond_cell_renderer.dart';
import 'package:fond/views/convertible_bond/widgets/bond_detail_dialog.dart';

/// 可转债表格组件
class BondTableWidget extends StatelessWidget {
  final List<ConvertibleBond> bonds;
  final List<Map<String, dynamic>> tableHeaders;
  final ScrollController horizontalScrollController;
  final Function(String) onSort;
  final String? sortColumn;
  final bool sortAscending;
  final bool isLoading;

  const BondTableWidget({
    super.key,
    required this.bonds,
    required this.tableHeaders,
    required this.horizontalScrollController,
    required this.onSort,
    this.sortColumn,
    this.sortAscending = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child: Column(
        children: [
          // 表格标题栏 - 可点击排序
          _buildTableHeader(context),

          // 表格数据区
          Expanded(
            child:
                bonds.isEmpty
                    ? const Center(child: Text('没有符合条件的数据'))
                    : _buildTableBody(context),
          ),
        ],
      ),
    );
  }

  /// 构建表格标题栏
  Widget _buildTableHeader(BuildContext context) {
    return Container(
      height: 40,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SingleChildScrollView(
        controller: horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              tableHeaders
                  .map(
                    (header) => GestureDetector(
                      onTap: () => onSort(header['name']),
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Text(
                                header['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (sortColumn == header['name'])
                              Icon(
                                sortAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 16,
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  /// 构建表格数据区
  Widget _buildTableBody(BuildContext context) {
    return ListView.builder(
      itemCount: bonds.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // 显示底部加载提示
        if (index == bonds.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final bond = bonds[index];
        final isEven = index % 2 == 0;

        // 表格行 - 点击可查看详情
        return Container(
          color:
              isEven
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.surface.withAlpha(100),
          child: InkWell(
            onTap: () {
              showBondDetails(context, bond);
            },
            child: SingleChildScrollView(
              controller: horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    tableHeaders.map((header) {
                      return BondCellRenderer.buildCellForField(
                        header['name'],
                        bond,
                        context,
                      );
                    }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
