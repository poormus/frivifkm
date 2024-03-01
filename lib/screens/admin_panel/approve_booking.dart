import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/screens/rooms_screen/booking_calendar.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/dialog/blurry_dialog.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/my_appointment.dart';
import 'package:firebase_calendar/services/admin_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ApproveBooking extends StatelessWidget {
  final CurrentUserData currentUserData;
  final AdminServices adminServices;
   ApproveBooking({Key? key, required this.currentUserData, required this.adminServices})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MyAppointment>>(
        stream: adminServices.getBookingsToApprove(currentUserData.currentOrganizationId),
        builder: (context, snapshots) {
          if (snapshots.hasData) {
            final appointments = snapshots.data!;
            appointments.removeWhere((element) => element.endTime.isBefore(DateTime.now()));
            if (snapshots.data!.length == 0) {
              return noDataWidget('No pending booking approval'.tr(), false);
            } else {
              return Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      return ApproveBookingTile(
                        appointment: appointments[index],
                        currentUserData: currentUserData,
                        adminServices: adminServices,
                      );
                    }),
              );
            }
          } else if (snapshots.hasError) {
            return noDataWidget(snapshots.error.toString(), false);
          } else {
            return noDataWidget(null, true);
          }
        });
  }


}

//approve booking tile
class ApproveBookingTile extends StatelessWidget {
  final MyAppointment appointment;
  final CurrentUserData currentUserData;
  final AdminServices adminServices;

   ApproveBookingTile(
      {Key? key, required this.appointment, required this.currentUserData, required this.adminServices})
      : super(key: key);



  showApproveDialog(BuildContext context) {
    BlurryDialogNew alert = BlurryDialogNew(
        title: "Approve this booking?".tr(),
        continueCallBack: () async {
          Navigator.of(context).pop();
          adminServices.approveBooking(appointment.appointmentId);
        });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  showDeleteDialog(BuildContext context) {
    BlurryDialogNew alert = BlurryDialogNew(
        title: "Delete this booking?".tr(),
        continueCallBack: () async {
          Navigator.of(context).pop();
           adminServices.deactivateBooking(appointment.appointmentId,context);
        });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void openRoomCalendar(BuildContext context) {
    Navigation.navigateToRoomCalendar(context,  appointment.roomId,
        currentUserData, appointment.roomName);
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        openRoomCalendar(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Card(
          color: Constants.CARD_COLOR,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.roomName,style: TextStyle(fontSize: 20)),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(Utils.toDateTranslated(appointment.startTime,context),style: textStyle,),
                    Text('${Utils.toTime(appointment.startTime)}-${Utils.toTime(appointment.endTime)}',style: textStyle,)
                  ],
                ),
                SizedBox(height: 5,),
                Text(appointment.userName,style: textStyle,),
                SizedBox(height: 5,),
                Text(appointment.subject,style: textStyle,),
                SizedBox(height: 5,),
                Text(appointment.note??'No note',style: textStyle,),
                Padding(
                  padding: const EdgeInsets.only(left: 6.0,right: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedCustomButton(text: 'Delete booking'.tr(), press: (){
                        showDeleteDialog(context);
                      }, color: Constants.CANCEL_COLOR),
                      ElevatedCustomButton(text: 'Approve booking'.tr(), press: (){
                        showApproveDialog(context);
                      }, color: Constants.BUTTON_COLOR),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
