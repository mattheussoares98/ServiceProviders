import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/toast_util.dart';

class GetNewDate {
  GetNewDate._();

  static Future<DateTime?> get({
    bool insertHoursAndMinutes = true,
    DateTime? currentSelectedDate,
    required DateTime minimumDate,
    required DateTime maximumDate,
    required BuildContext context,
  }) async {
    DateTime? selectedDate;

    FocusManager.instance.primaryFocus?.unfocus();

    final currentSelectedIsBeforeMinimumDate =
        currentSelectedDate?.isBefore(minimumDate) ?? true;
    final correctMinimumDate = currentSelectedIsBeforeMinimumDate
        ? minimumDate
        : currentSelectedDate!;

    final firstDate = currentSelectedIsBeforeMinimumDate
        ? correctMinimumDate
        : minimumDate;
    final initialDate = currentSelectedIsBeforeMinimumDate
        ? correctMinimumDate
        : currentSelectedDate;

    if (PlatformUtil.isIOS) {
      selectedDate = await _showCupertinoDatePicker(
        firstDate: firstDate,
        context: context,
        maximumDate: maximumDate,
        initialDate: initialDate,
        mode: CupertinoDatePickerMode.date,
      );
    } else {
      selectedDate = await showDatePicker(
        context: context,
        firstDate: firstDate,
        initialDate: initialDate,
        lastDate: maximumDate,
      );
    }

    if (selectedDate == null || !insertHoursAndMinutes) return selectedDate;

    TimeOfDay? selectedTime;

    if (PlatformUtil.isIOS) {
      if (!context.mounted) return null;
      final time = await _showCupertinoDatePicker(
        firstDate: firstDate,
        context: context,
        maximumDate: maximumDate,
        initialDate: initialDate,
        mode: CupertinoDatePickerMode.time,
      );
      selectedTime = time == null
          ? null
          : TimeOfDay(hour: time.hour, minute: time.minute);
    } else {
      if (!context.mounted) return null;
      selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          currentSelectedDate ?? DateTime.now(),
        ),
      );
    }

    if (selectedTime == null) {
      if (!context.mounted) return null;
      ToastUtil.showError('Horário não atualizado'.hardcoded);

      return null;
    }

    final finalDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (finalDateTime.isBefore(firstDate)) {
      if (!context.mounted) return null;
      ToastUtil.showError(
        'O horário não pode ser menor que a data mínima'.hardcoded,
      );
      return null;
    }

    return finalDateTime;
  }

  static Future<DateTime?> _showCupertinoDatePicker({
    required DateTime? maximumDate,
    required DateTime? firstDate,
    required DateTime? initialDate,
    required BuildContext context,
    required CupertinoDatePickerMode mode,
  }) {
    DateTime? tempPickedDate = firstDate;

    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoTheme(
          data: CupertinoThemeData(
            brightness: Brightness.light,
            primaryColor: context.theme.primaryColor,
            textTheme: CupertinoTextThemeData(
              dateTimePickerTextStyle: TextStyle(
                color: context.theme.primaryColor,
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          child: Container(
            height: 280,
            color: Colors.white,
            child: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(Sizes.p8),
                      child: BaseText.headline(
                        mode == CupertinoDatePickerMode.date
                            ? 'Data'.hardcoded
                            : 'Horário'.hardcoded,
                      ),
                    ),
                    SizedBox(
                      height: 180,
                      child: CupertinoDatePicker(
                        mode: mode,
                        initialDateTime: initialDate,
                        minimumDate: firstDate,
                        maximumDate: maximumDate,
                        use24hFormat: true,
                        onDateTimeChanged: (DateTime newDate) {
                          tempPickedDate = newDate;
                        },
                      ),
                    ),
                    CupertinoButton(
                      child: BaseText('OK'.hardcoded),
                      onPressed: () => context.pop<DateTime?>(tempPickedDate),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
