import 'package:flutter/material.dart';
import 'package:fond/views/convertible_bond/models/convertible_bond.dart';
import 'package:fond/views/convertible_bond/services/convertible_bond_service.dart';
import 'package:fond/views/convertible_bond/utils/bond_filter.dart';
import 'package:fond/views/convertible_bond/utils/bond_sorter.dart';
import 'package:fond/views/convertible_bond/widgets/bond_pagination_widget.dart';
import 'package:fond/views/convertible_bond/widgets/bond_search_filter_widget.dart';
import 'package:fond/views/convertible_bond/widgets/bond_table_widget.dart';
import 'package:fond/widgets/fond_button.dart';
import 'package:intl/intl.dart';

class ConvertibleBondScreen extends StatefulWidget {
  const ConvertibleBondScreen({super.key});

  @override
  State<ConvertibleBondScreen> createState() => _ConvertibleBondScreenState();
}

class _ConvertibleBondScreenState extends State<ConvertibleBondScreen> {
  // 服务和数据
  final ConvertibleBondService _bondService = ConvertibleBondService();
  List<ConvertibleBond> _bonds = [];

  // 状态管理
  bool _isLoading = false;
  String _errorMessage = '';
  int _totalCount = 0;
  int _currentPage = 1;
  final int _pageSize = 50;

  // UI控制
  late List<Map<String, dynamic>> _tableHeaders = [];
  final ScrollController _horizontalScrollController = ScrollController();

  // 排序相关
  String? _sortColumn;
  bool _sortAscending = true;

  // 筛选相关
  String _filterBondType = '全部';
  final List<String> _bondTypes = ['全部', 'A股', 'B股', '上证', '深证'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 根据descrs数据设置表头
  void _setupTableHeaders(List<Map<String, dynamic>> descrs) {
    setState(() {
      // 使用完整的descrs数据设置表头，不再筛选
      _tableHeaders =
          descrs.map<Map<String, dynamic>>((descr) {
            return {
              'title': descr['title'].toString().replaceFirst(
                '2_',
                '',
              ), // 移除标题中的"2_"前缀
              'name': descr['name'],
              'flex': 2, // 默认每列flex为2
            };
          }).toList();

      // 不再过滤表头，而是显示所有列
      debugPrint('设置了 ${_tableHeaders.length} 个表头字段');
    });
  }

  // 获取今天日期，格式为yyyyMMdd
  String _getTodayDate() {
    final now = DateTime.now();
    return DateFormat('yyyyMMdd').format(now);
  }

  // 加载可转债数据
  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final begin = (_currentPage - 1) * _pageSize + 1;
      final response = await _bondService.getConvertibleBonds(
        date: _getTodayDate(),
        begin: begin,
        count: _pageSize,
        page: _currentPage,
      );

      // 设置表头数据
      if (response.descrs.isNotEmpty && _tableHeaders.isEmpty) {
        _setupTableHeaders(response.descrs);
      }

      setState(() {
        _bonds = response.bonds;
        _totalCount = response.bonds.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // 刷新数据
  Future<void> _refreshData() async {
    setState(() {
      _currentPage = 1;
    });
    await _loadData();
  }

  // 加载下一页
  void _loadNextPage() {
    setState(() {
      _currentPage++;
    });
    _loadData();
  }

  // 加载上一页
  void _loadPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _loadData();
    }
  }

  // 根据字段对数据进行排序
  void _sortData(String column) {
    setState(() {
      // 如果点击相同列，切换排序方向
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }

      // 使用工具类进行排序
      BondSorter.sortBonds(_bonds, column, _sortAscending);
    });
  }

  // 处理筛选类型改变
  void _handleFilterTypeChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _filterBondType = newValue;
      });
    }
  }

  // 获取筛选后的数据
  List<ConvertibleBond> _getFilteredBonds() {
    return BondFilter.filterBonds(
      _bonds,
      _searchController.text,
      _filterBondType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBonds = _getFilteredBonds();

    return Scaffold(
      body: Column(
        children: [
          // 标题和操作区
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '可转债列表',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                FondButton(onTap: _refreshData, buttonText: '刷新'),
              ],
            ),
          ),

          // 搜索和筛选区
          BondSearchFilterWidget(
            searchController: _searchController,
            filterBondType: _filterBondType,
            bondTypes: _bondTypes,
            onFilterChanged: _handleFilterTypeChanged,
          ),

          // 数据统计区
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('总数: $_totalCount'),
                const SizedBox(width: 16),
                Text('当前页: $_currentPage'),
                const SizedBox(width: 16),
                Text('筛选结果: ${filteredBonds.length}'),
              ],
            ),
          ),

          // 分割线
          const Divider(),

          // 错误信息
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '加载失败: $_errorMessage',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),

          // 加载中提示
          if (_isLoading && _bonds.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator())),

          // 表格区域
          if (_bonds.isNotEmpty)
            Expanded(
              child: BondTableWidget(
                bonds: filteredBonds,
                tableHeaders: _tableHeaders,
                horizontalScrollController: _horizontalScrollController,
                onSort: _sortData,
                sortColumn: _sortColumn,
                sortAscending: _sortAscending,
                isLoading: _isLoading,
              ),
            ),

          // 分页操作
          if (_bonds.isNotEmpty)
            BondPaginationWidget(
              currentPage: _currentPage,
              pageSize: _pageSize,
              itemCount: _bonds.length,
              onPrevious: _loadPreviousPage,
              onNext: _loadNextPage,
            ),
        ],
      ),
    );
  }
}
