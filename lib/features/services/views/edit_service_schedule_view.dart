// مسار الملف: lib/features/services/views/edit_service_schedule_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../viewmodels/service_schedule_viewmodel.dart';
// import '../models/service_schedule_model.dart';

class EditServiceScheduleView extends StatelessWidget {
  const EditServiceScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ServiceScheduleViewModel>(context);
    final schedule = viewModel.schedule;

    final weekDays = [
      'saturday',
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
    ];

    return Scaffold(
      backgroundColor: context.qsColors.background,
      appBar: AppBar(
        backgroundColor: context.qsColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          viewModel.initialSchedule != null ? context.tr('edit') : context.tr('add_schedule_slot'),
          style: TextStyle(
            color: context.qsColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: context.qsColors.text,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          viewModel.isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: () async {
                    final success = await viewModel.saveSchedule(context);
                    if (success && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text(
                    context.tr('save'),
                    style: TextStyle(
                      color: context.qsColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.qsColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  right: BorderSide(color: context.qsColors.primary, width: 5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.qsColors.text.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.qsColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: context.qsColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr('working_schedule'),
                      style: TextStyle(
                        color: context.qsColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 📝 اسم الفترة (label)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.qsColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.qsColors.textSub.withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.qsColors.text.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('period_name'),
                    style: TextStyle(
                      color: context.qsColors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: viewModel.labelController,
                    style: TextStyle(color: context.qsColors.text),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: context.qsColors.background,
                      hintText: context.tr('period_name_hint'),
                      hintStyle: TextStyle(
                        color: context.qsColors.textSub.withOpacity(0.6),
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.qsColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: schedule.isActive
                      ? context.qsColors.primary.withOpacity(0.3)
                      : context.qsColors.textSub.withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.qsColors.text.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        context.tr('working_days_hours'),
                        style: TextStyle(
                          color: context.qsColors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      Switch.adaptive(
                        value: schedule.isActive,
                        onChanged: (val) => viewModel.toggleActive(val),
                        activeColor: context.qsColors.primary,
                      ),
                    ],
                  ),
                  if (schedule.isActive) ...[
                    const Divider(height: 24),
                    Text(
                      context.tr('select_days'),
                      style: TextStyle(
                        color: context.qsColors.textSub,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: weekDays.map((dayName) {
                        final isSelected = schedule.days.contains(dayName);
                        return FilterChip(
                          label: Text(
                            context.tr(dayName.toLowerCase()),
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected
                                  ? context.qsColors.primary
                                  : context.qsColors.textSub,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (val) {
                            viewModel.toggleDay(dayName);
                          },
                          showCheckmark: false,
                          selectedColor: context.qsColors.primary.withOpacity(
                            0.1,
                          ),
                          backgroundColor: context.qsColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? context.qsColors.primary.withOpacity(0.5)
                                  : context.qsColors.textSub.withOpacity(0.2),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTimePicker(
                          context,
                          context.tr('start_time'),
                          _formatTo12Hour(context, schedule.startTime),
                          () => viewModel.updateStartTime(context),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: context.qsColors.textSub,
                        ),
                        _buildTimePicker(
                          context,
                          context.tr('end_time'),
                          _formatTo12Hour(context, schedule.endTime),
                          () => viewModel.updateEndTime(context),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    String label,
    String time,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.35,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: context.qsColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.qsColors.textSub.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: context.qsColors.textSub, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: context.qsColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTo12Hour(BuildContext context, String timeStr) {
    if (timeStr.isEmpty) return timeStr;
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
        final periodStr = hour >= 12
            ? (isArabic ? context.tr('auto_tr_79') : 'PM')
            : (isArabic ? context.tr('auto_tr_92') : 'AM');

        int hour12 = hour % 12;
        if (hour12 == 0) hour12 = 12;
        final minuteStr = minute.toString().padLeft(2, '0');
        return '$hour12:$minuteStr $periodStr';
      }
    } catch (_) {}
    return timeStr;
  }
}

