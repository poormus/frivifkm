import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/anim/slide_in_right.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/my_appointment.dart';
import 'package:firebase_calendar/services/Firebase_service.dart';
import 'package:firebase_calendar/services/admin_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../shared/utils.dart';
import 'add_edit_appointment_sync_fusion.dart';

class MyBookingHistory extends StatelessWidget {
  final CurrentUserData userData;

  MyBookingHistory({Key? key, required this.userData}) : super(key: key);

  final firebaseService = FireBaseServices();
  final adminServices = AdminServices();

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  Widget buildBody() {
    return StreamBuilder<List<MyAppointment>>(
      stream: firebaseService.userAppointments(
          userData.currentOrganizationId, userData.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.length == 0) {
            return noDataWidget('Your history will appear here'.tr(), false);
          } else {
            return Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return RecentAppointmentTile(
                      appointment: snapshot.data![index],
                      adminService: adminServices,
                      currentUserData: userData,
                    );
                  }),
            );
          }
        } else if (snapshot.hasError) {
          return noDataWidget(snapshot.error.toString(), false);
        } else {
          return noDataWidget(null, true);
        }
      },
    );
  }
}

class RecentAppointmentTile extends StatelessWidget {
  final MyAppointment appointment;
  final AdminServices adminService;
  final CurrentUserData currentUserData;

  const RecentAppointmentTile(
      {Key? key,
      required this.appointment,
      required this.adminService,
      required this.currentUserData})
      : super(key: key);

  void showDeleteDialog(BuildContext context, String bookingId) {
    BlurryDialogNew alert = BlurryDialogNew(
        title: "Delete this booking?".tr(),
        continueCallBack: () async {
          Navigator.of(context).pop();
           adminService
              .deleteBooking(bookingId,context)
              .catchError((err) => Utils.showToast(context, err.toString()));
        });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Constants.CARD_COLOR,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appointment.roomName,
                style: appTextStyle.copyWith(fontWeight: FontWeight.bold,fontSize: 24)),
            SizedBox(
              height: 10,
            ),
            Text(appointment.subject, style: TextStyle(color: Colors.black38)),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(Utils.toDateTranslated(appointment.startTime,context),
                    style: TextStyle(color: Colors.black38)),
                SizedBox(
                  width: 10,
                ),
                Text(Utils.toTime(appointment.startTime),
                    style: TextStyle(color: Colors.black38)),
                Text('-'),
                Text(Utils.toTime(appointment.endTime),
                    style: TextStyle(color: Colors.black38))
              ],
            ),
            SizedBox(height: 10),
            Text(appointment.isConfirmed==true?'Approved'.tr():'Pending approval'.tr(),style: textStyle,),
            SizedBox(height: 10),
            appointment.endTime.isAfter(DateTime.now())?
            Text(appointment.isActive?'Active'.tr():'Denied by admin'.tr(),style: appTextStyle)
                :Text('Expired'.tr()),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.push(context,SlideInRight(AddEditAppointment(
                        appointment: appointment,
                        roomId: appointment.roomId,
                        userData: currentUserData,
                      )));
                    },
                    icon: Icon(Icons.edit, color: Constants.BUTTON_COLOR)),
                SizedBox(width: 10),
                IconButton(
                    onPressed: () {
                      showDeleteDialog(context, appointment.appointmentId);
                    },
                    icon: Icon(Icons.delete_rounded, color: Constants.CANCEL_COLOR)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
