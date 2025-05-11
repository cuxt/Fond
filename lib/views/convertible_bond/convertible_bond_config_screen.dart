import 'package:flutter/material.dart';
import 'package:fond/views/convertible_bond/widgets/batch_result_table.dart';
import 'package:fond/views/convertible_bond/widgets/calculation_config_card.dart';
import 'package:fond/views/convertible_bond/widgets/date_selection_toolbar.dart';
import 'package:fond/views/convertible_bond/widgets/single_day_result_card.dart';
import 'package:fond/views/convertible_bond/controllers/convertible_bond_controller.dart';
import 'package:fond/views/convertible_bond/models/filter_condition.dart';
import 'package:fond/views/convertible_bond/utils/string_field_utils.dart';
import 'package:intl/intl.dart';

/// 可转债配置页面 - 用于配置数据计算而非直接展示数据
class ConvertibleBondConfigScreen extends StatefulWidget {
  const ConvertibleBondConfigScreen({super.key});

  @override
  State<ConvertibleBondConfigScreen> createState() =>
      _ConvertibleBondConfigScreenState();
}

class _ConvertibleBondConfigScreenState
    extends State<ConvertibleBondConfigScreen> {
  // 控制器
  final ConvertibleBondController _controller = ConvertibleBondController();

  // 状态管理
  bool _isLoading = false;
  String _errorMessage = '';

  // 日期选择
  late DateTime _selectedDate;
  String _formattedDate = '';

  // 批量计算相关
  bool _isBatchMode = false;
  late DateTime _startDate;
  late DateTime _endDate;
  String _startDateFormatted = '';
  String _endDateFormatted = '';
  List<Map<String, dynamic>> _batchResults = [];

  // 计算配置
  String? _selectedField;
  String _selectedCalculation = '中位数';
  final List<String> _calculationTypes = [
    '平均值',
    '中位数',
    '最大值',
    '最小值',
    '标准差',
    '求和',
  ];

  // 字段信息
  List<Map<String, dynamic>> _tableHeaders = [];

  // 过滤条件
  final List<FilterCondition> _filterConditions = [];

  // 计算结果
  Map<String, dynamic> _calculationResult = {};

  @override
  void initState() {
    super.initState();

    // 初始化日期相关变量
    _selectedDate = DateTime.now();
    _formattedDate = DateFormat('yyyyMMdd').format(_selectedDate);

    // 初始化批量计算的日期范围
    _startDate = _selectedDate.subtract(const Duration(days: 7)); // 默认7天前
    _endDate = _selectedDate;
    _startDateFormatted = DateFormat('yyyyMMdd').format(_startDate);
    _endDateFormatted = DateFormat('yyyyMMdd').format(_endDate);

    _loadBondFields();
  }

  // 加载可转债字段信息
  Future<void> _loadBondFields() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 获取数据表头信息
      final headers = await _controller.loadBondFields(_formattedDate);

      // 设置表头数据
      if (headers.isNotEmpty) {
        setState(() {
          _tableHeaders = headers;
          // 默认选择第一个非代码、名称的数值型字段
          for (var header in headers) {
            final name = header['name'].toString();
            if (!['bond_nm', 'bond_id', 'bond_cd'].contains(name)) {
              _selectedField = name;
              break;
            }
          }
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // 打开日期选择器
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _formattedDate = DateFormat('yyyyMMdd').format(_selectedDate);
        // 清空计算结果
        _calculationResult = {};
      });
    }
  }

  // 选择日期范围
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      saveText: '确定',
      cancelText: '取消',
      confirmText: '确认',
      helpText: '选择日期范围',
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _startDateFormatted = DateFormat('yyyyMMdd').format(_startDate);
        _endDateFormatted = DateFormat('yyyyMMdd').format(_endDate);

        // 清空批量计算结果
        _batchResults = [];
      });
    }
  }

  // 前一天
  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      _formattedDate = DateFormat('yyyyMMdd').format(_selectedDate);
      // 清空计算结果
      _calculationResult = {};
    });
  }

  // 后一天
  void _goToNextDay() {
    // 不能超过今天
    final now = DateTime.now();
    if (_selectedDate.isBefore(now)) {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
        _formattedDate = DateFormat('yyyyMMdd').format(_selectedDate);
        // 清空计算结果
        _calculationResult = {};
      });
    }
  }

  // 添加过滤条件
  void _addFilterCondition() {
    if (_tableHeaders.isEmpty) return;

    final fieldName = _tableHeaders.first['name'].toString();

    // 判断字段是否为字符串类型
    final isStringField = StringFieldUtils.isStringField(fieldName);
    final defaultOperator = isStringField ? '等于' : '大于';
    final defaultValue = isStringField ? '' : '0';

    setState(() {
      _filterConditions.add(
        FilterCondition(
          field: fieldName,
          operator: defaultOperator,
          value: defaultValue,
        ),
      );
    });
  }

  // 删除过滤条件
  void _removeFilterCondition(int index) {
    setState(() {
      _filterConditions.removeAt(index);
    });
  }

  // 更新过滤条件
  void _updateFilterCondition(int index, FilterCondition condition) {
    setState(() {
      _filterConditions[index] = condition;
    });
  }

  // 切换计算模式
  void _toggleMode(int index) {
    setState(() {
      _isBatchMode = index == 1;
      // 切换模式时清空计算结果
      if (_isBatchMode) {
        _calculationResult = {};
      } else {
        _batchResults = [];
      }
    });
  }

  // 执行计算
  Future<void> _performCalculation() async {
    if (_selectedField == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择要计算的字段')));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_isBatchMode) {
        // 执行批量计算
        final results = await _controller.performBatchCalculation(
          startDate: _startDate,
          endDate: _endDate,
          selectedField: _selectedField,
          calculationType: _selectedCalculation,
          filterConditions: _filterConditions,
        );

        setState(() {
          _batchResults = results;
          _isLoading = false;
        });
      } else {
        // 执行单日计算
        final result = await _controller.performSingleDayCalculation(
          date: _formattedDate,
          selectedField: _selectedField,
          calculationType: _selectedCalculation,
          filterConditions: _filterConditions,
        );

        setState(() {
          _calculationResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('计算过程发生错误: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;

        if (_isBatchMode) {
          _batchResults = [];
        } else {
          _calculationResult = {};
        }
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('计算出错: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '发生错误',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(_errorMessage),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadBondFields,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
                : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 日期选择工具栏
                        DateSelectionToolbar(
                          isBatchMode: _isBatchMode,
                          selectedDate: _selectedDate,
                          startDate: _startDate,
                          endDate: _endDate,
                          formattedDate: _formattedDate,
                          startDateFormatted: _startDateFormatted,
                          endDateFormatted: _endDateFormatted,
                          selectDate: _selectDate,
                          selectDateRange: _selectDateRange,
                          goToPreviousDay: _goToPreviousDay,
                          goToNextDay: _goToNextDay,
                          onToggleMode: _toggleMode,
                        ),

                        const SizedBox(height: 24),

                        // 计算配置卡片
                        CalculationConfigCard(
                          selectedField: _selectedField,
                          selectedCalculation: _selectedCalculation,
                          calculationTypes: _calculationTypes,
                          tableHeaders: _tableHeaders,
                          filterConditions: _filterConditions,
                          onFieldChanged: (value) {
                            setState(() {
                              _selectedField = value;
                            });
                          },
                          onCalculationTypeChanged: (value) {
                            setState(() {
                              _selectedCalculation = value;
                            });
                          },
                          onAddFilterCondition: _addFilterCondition,
                          onUpdateFilterCondition: _updateFilterCondition,
                          onRemoveFilterCondition: _removeFilterCondition,
                          onCalculate: _performCalculation,
                          isBatchMode: _isBatchMode,
                        ),

                        const SizedBox(height: 24),

                        // 显示计算结果
                        if (!_isBatchMode && _calculationResult.isNotEmpty)
                          SingleDayResultCard(
                            calculationResult: _calculationResult,
                            selectedField: _selectedField,
                            tableHeaders: _tableHeaders,
                            formattedDate: _formattedDate,
                          ),

                        if (_isBatchMode && _batchResults.isNotEmpty)
                          BatchResultTable(
                            batchResults: _batchResults,
                            selectedField: _selectedField,
                            selectedCalculation: _selectedCalculation,
                            tableHeaders: _tableHeaders,
                          ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
