import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/services/qr_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';


class SelectLogTypeDialog extends StatelessWidget {
  final String qrId;
  final String organizationId;
  QrServices qrServices=QrServices();
  SelectLogTypeDialog({Key? key, required this.qrId, required this.organizationId}) : super(key: key);



  Future updateLogType(String logType,BuildContext context,QrServices qrServices)async{
    qrServices.updateLogType(qrId,logType);
    Navigator.pop(context);
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
          height: 190,
          child: Stack(
            children: [
              Align(
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Select log type'.tr(),style: appTextStyle.copyWith(fontSize: 20),),
                    ),
                    SizedBox(height: 10),
                    CustomTextButton(
                        width: size.width * 0.6,
                        height: 40,
                        text: 'Entry'.tr(),
                        textColor: Constants.BUTTON_COLOR,
                        containerColor: Colors.white,
                        press: () {
                          updateLogType('Entry',context,qrServices);

                        }),
                    SizedBox(height: 25),
                    CustomTextButton(
                        width: size.width * 0.6,
                        height: 40,
                        text: 'Exit'.tr(),
                        textColor: Constants.BUTTON_COLOR,
                        containerColor: Colors.white,
                        press: () {
                          updateLogType('Exit',context,qrServices);
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
          )

      ),
    );
  }
}
