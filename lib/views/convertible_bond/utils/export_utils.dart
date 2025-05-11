import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:fond/views/convertible_bond/utils/string_field_utils.dart';

/// 导出工具类
class ExportUtils {
  /// 导出计算结果为CSV文件
  static Future<void> exportToCSV({
    required BuildContext context,
    required List<Map<String, dynamic>> batchResults,
    required String selectedField,
    required String selectedCalculation,
    required List<Map<String, dynamic>> tableHeaders,
  }) async {
    if (batchResults.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('没有数据可导出')));
      return;
    }

    try {
      // 准备CSV数据
      List<List<dynamic>> csvData = []; // 添加表头
      String fieldDisplayName = StringFieldUtils.getFieldDisplayName(
        selectedField,
        tableHeaders,
      );
      csvData.add(['日期', '$fieldDisplayName计算结果($selectedCalculation)', '数据量']);

      // 添加数据行
      for (var result in batchResults) {
        csvData.add([
          result['display_date'],
          result['result'] != null
              ? result['result'].toStringAsFixed(4)
              : '无数据',
          result['count'] != null ? result['count'].toString() : '0',
        ]);
      }

      // 转换为CSV格式
      String csv = const ListToCsvConverter().convert(csvData);

      // 使用文件选择器保存文件
      final String fileName =
          '可转债${fieldDisplayName}_${selectedCalculation}_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';

      if (Platform.isAndroid || Platform.isIOS) {
        // 移动设备上的处理逻辑
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/$fileName';
        final File file = File(path);
        await file.writeAsString(csv);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('数据已保存至 $path')));
      } else {
        // 桌面设备上的处理逻辑
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: '保存CSV文件',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['csv'],
        );

        if (outputFile != null) {
          final File file = File(outputFile);
          await file.writeAsString(csv);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('数据已导出至 ${file.path}')));
        }
      }
    } catch (e) {
      debugPrint('导出数据时发生错误: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('导出失败: ${e.toString()}')));
    }
  }
}
