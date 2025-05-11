import 'package:flutter/material.dart';
import 'package:fond/views/convertible_bond/models/convertible_bond.dart';
import 'package:fond/views/convertible_bond/services/convertible_bond_service.dart';
import 'package:fond/views/convertible_bond/utils/bond_filter.dart';
import 'package:fond/views/convertible_bond/utils/bond_sorter.dart';
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
  List<ConvertibleBond> _bonds = []; // 状态管理
  bool _isLoading = false;
  String _errorMessage = '';
  int _totalCount = 0;
  final int _pageSize = 600; // 一次性加载600条数据

  // 日期选择
  late DateTime _selectedDate;
  String _formattedDate = '';

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
    _selectedDate = DateTime.now();
    _formattedDate = DateFormat('yyyyMMdd').format(_selectedDate);
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

  // 获取当前选择的日期，格式为yyyyMMdd
  String _getFormattedDate() {
    return _formattedDate;
  }

  // 打开日期选择器
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      // 不使用locale参数，避免依赖flutter_localizations
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _formattedDate = DateFormat('yyyyMMdd').format(_selectedDate);
      });

      // 使用新选择的日期加载数据
      await _loadData(forceRefresh: false);
    }
  }

  // 加载可转债数据
  Future<void> _loadData({bool forceRefresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 始终从第1条数据开始，一次性加载所有数据
      final response = await _bondService.getConvertibleBonds(
        date: _getFormattedDate(),
        begin: 1, // 固定从第1条开始
        count: _pageSize, // 一次性加载600条
        page: 1, // 固定第1页
        forceRefresh: forceRefresh,
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
  } // 刷新数据

  Future<void> _refreshData() async {
    await _loadData(forceRefresh: true); // 强制刷新，不使用缓存
  }

  // 前一天
  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      _formattedDate = DateFormat('yyyyMMdd').format(_selectedDate);
    });
    _loadData(forceRefresh: false);
  }

  // 后一天
  void _goToNextDay() {
    // 不能超过今天
    final now = DateTime.now();
    if (_selectedDate.isBefore(now)) {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
        _formattedDate = DateFormat('yyyyMMdd').format(_selectedDate);
      });
      _loadData(forceRefresh: false);
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
                Row(
                  children: [
                    // 日期选择按钮
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_formattedDate.substring(0, 4)}-${_formattedDate.substring(4, 6)}-${_formattedDate.substring(6, 8)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 前一天按钮
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      onPressed: _goToPreviousDay,
                      tooltip: '前一天',
                    ),
                    // 后一天按钮
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: _goToNextDay,
                      tooltip: '后一天',
                    ),
                    const SizedBox(width: 16),
                    FondButton(onTap: _refreshData, buttonText: '刷新'),
                  ],
                ),
              ],
            ),
          ),

          // 搜索和筛选区
          BondSearchFilterWidget(
            searchController: _searchController,
            filterBondType: _filterBondType,
            bondTypes: _bondTypes,
            onFilterChanged: _handleFilterTypeChanged,
          ), // 数据统计区
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  '日期: ${_formattedDate.substring(0, 4)}-${_formattedDate.substring(4, 6)}-${_formattedDate.substring(6, 8)}',
                ),
                const SizedBox(width: 16),
                Text('总数: $_totalCount'),
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
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ), // 表格区域
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
        ],
      ),
    );
  }
}
