import 'package:flutter/material.dart';

/// 日期选择工具条
class DateSelectionToolbar extends StatelessWidget {
  final bool isBatchMode;
  final DateTime selectedDate;
  final DateTime startDate;
  final DateTime endDate;
  final String formattedDate;
  final String startDateFormatted;
  final String endDateFormatted;
  final Function(BuildContext) selectDate;
  final Function(BuildContext) selectDateRange;
  final VoidCallback goToPreviousDay;
  final VoidCallback goToNextDay;
  final Function(int) onToggleMode;

  const DateSelectionToolbar({
    super.key,
    required this.isBatchMode,
    required this.selectedDate,
    required this.startDate,
    required this.endDate,
    required this.formattedDate,
    required this.startDateFormatted,
    required this.endDateFormatted,
    required this.selectDate,
    required this.selectDateRange,
    required this.goToPreviousDay,
    required this.goToNextDay,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('可转债数据分析', style: theme.textTheme.headlineMedium),
        Row(
          children: [
            // 计算模式切换
            ToggleButtons(
              isSelected: [!isBatchMode, isBatchMode],
              onPressed: onToggleMode,
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('单日计算'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('批量计算'),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // 根据模式显示不同的日期选择
            if (!isBatchMode) ...[
              // 单日日期选择按钮
              InkWell(
                onTap: () => selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${formattedDate.substring(0, 4)}-${formattedDate.substring(4, 6)}-${formattedDate.substring(6, 8)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.calendar_today, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 前一天按钮
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                onPressed: goToPreviousDay,
                tooltip: '前一天',
              ),
              // 后一天按钮
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: goToNextDay,
                tooltip: '后一天',
              ),
            ] else ...[
              // 日期范围选择按钮
              InkWell(
                onTap: () => selectDateRange(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${startDateFormatted.substring(0, 4)}-${startDateFormatted.substring(4, 6)}-${startDateFormatted.substring(6, 8)} 至 '
                        '${endDateFormatted.substring(0, 4)}-${endDateFormatted.substring(4, 6)}-${endDateFormatted.substring(6, 8)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.date_range, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
