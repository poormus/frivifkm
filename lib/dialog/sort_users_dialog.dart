import 'dart:io';

import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class SortUserDialog extends StatelessWidget {
  final sortSelected sort;
  const SortUserDialog({Key? key, required this.sort})
      : super(key: key);



  void passSortString(BuildContext context,String sortString){
    sort(OnSortSelected(sortString: sortString));
    dismissDialog(context);
  }

  void dismissDialog(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 200), () {
      // When task is over, close the dialog
      Navigator.pop(context);
    });
  }
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
          height: 325,
          child: Stack(
            children: [
              Align(
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Sort by'.tr(),style: appTextStyle.copyWith(fontSize: 20),),
                    ),
                    SizedBox(height: 10),
                    CustomTextButton(
                        width: size.width * 0.6,
                        height: 40,
                        text: 'Admin'.tr(),
                        textColor: Constants.BUTTON_COLOR,
                        containerColor: Colors.white,
                        press: () {
                          sort(OnSortSelected(sortString: 'admin'));
                            dismissDialog(context);
                        }),
                    SizedBox(height: 10),
                    CustomTextButton(
                        width: size.width * 0.6,
                        height: 40,
                        text: 'Leader'.tr(),
                        textColor: Constants.BUTTON_COLOR,
                        containerColor: Colors.white,
                        press: () {
                          sort(OnSortSelected(sortString: 'leader'));
                          dismissDialog(context);
                        }),
                    SizedBox(height: 10),
                    CustomTextButton(
                        width: size.width * 0.6,
                        height: 40,
                        text: 'Member'.tr(),
                        textColor: Constants.BUTTON_COLOR,
                        containerColor: Colors.white,
                        press: () {
                          sort(OnSortSelected(sortString: 'member'));
                          dismissDialog(context);
                        }),
                    SizedBox(height: 10),
                    CustomTextButton(
                        width: size.width * 0.6,
                        height: 40,
                        text: 'Guest'.tr(),
                        textColor: Constants.BUTTON_COLOR,
                        containerColor: Colors.white,
                        press: () {
                          sort(OnSortSelected(sortString: 'guest'));
                          dismissDialog(context);
                        }),
                    SizedBox(height: 10),
                    CustomTextButton(
                        width: size.width * 0.6,
                        height: 40,
                        text: 'All'.tr(),
                        textColor: Constants.BUTTON_COLOR,
                        containerColor: Colors.white,
                        press: () {
                          sort(OnSortSelected(sortString: 'all'));
                          dismissDialog(context);
                        }),
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
          )

      ),
    );
  }
}

/// create this class to pass the data type you want
class OnSortSelected {
 OnSortSelected ({required this.sortString});
  final String sortString;
}

/// Signature for callback which reports the picker value changed based on the class above...
typedef sortSelected = void Function(OnSortSelected onSortSelected);
