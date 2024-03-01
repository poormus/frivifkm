import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/services/qr_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';

class SortLogsByDateDialog extends StatefulWidget {
  final onFiltersSet filterSet;

  SortLogsByDateDialog({Key? key, required this.filterSet}) : super(key: key);

  @override
  State<SortLogsByDateDialog> createState() => _SortLogsByDateDialogState();
}

class _SortLogsByDateDialogState extends State<SortLogsByDateDialog> {


  DateTime logDateFrom = DateTime.now();

  DateTime logDateTo = DateTime.now().add(Duration(hours: 1));


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(24),
        ),
      ),
      backgroundColor: Constants.BACKGROUND_COLOR,
      child: Container(
          height: 230,
          child: Stack(
            children: [
              Align(
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Select date range'.tr(),
                        style: appTextStyle.copyWith(fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        pickDateFrom(pickDate: true);
                      },
                      child: Container(
                          height: 45,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.white,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    Utils.toDateTranslated(
                                        logDateFrom, context),
                                    style: appTextStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Icon(Icons.arrow_drop_down_outlined),
                              ],
                            ),
                          )),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        pickDateTo(pickDate: true);
                      },
                      child: Container(
                          height: 45,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.white,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(Utils.toDateTranslated(logDateTo, context),
                                    style: appTextStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Icon(Icons.arrow_drop_down_outlined),
                              ],
                            ),
                          )),
                    ),
                    SizedBox(height: 10),
                    CustomTextButton(
                        width: size.width * 0.5,
                        height: 35,
                        text: 'Apply'.tr(),
                        textColor: Colors.white,
                        containerColor: Constants.BUTTON_COLOR,
                        press: () {
                          widget.filterSet(SelectedDates(dateFrom: logDateFrom, dateTo: logDateTo));
                          Navigator.pop(context);
                        })
                  ],
                ),
              ),
              Align(
                // These values are based on trial & error method
                alignment: Alignment(1.1, -1.1),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.cancel,
                      color: Constants.CANCEL_COLOR,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Future pickDateFrom({required bool pickDate}) async {
    final date = await pickDateTime(logDateFrom, pickDate: pickDate);
    if (date == null) return;
    setState(() {
      logDateFrom = date;
    });
  }

  Future pickDateTo({required bool pickDate}) async {
    final date = await pickDateTime(logDateTo, pickDate: pickDate);
    if (date == null) return;
    setState(() {
      logDateTo = date;
    });
  }

  Future<DateTime?> pickDateTime(DateTime initialDate,
      {required bool pickDate, DateTime? firstDate}) async {
    if (pickDate) {
      final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate ?? DateTime(2015, 8),
          lastDate: DateTime(2101));
      if (date == null) return null;
      final time = Duration(hours: date.hour, minutes: date.minute);
      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
          context: context, initialTime: TimeOfDay.fromDateTime(initialDate));
      if (timeOfDay == null) return null;
      final date =
          DateTime(initialDate.year, initialDate.month, initialDate.day);
      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);
      return date.add(time);
    }
  }
}

class SelectedDates {
  DateTime dateFrom;
  DateTime dateTo;

  SelectedDates({
    required this.dateFrom,
    required this.dateTo,
  });
}

typedef onFiltersSet(SelectedDates dates);
