import 'package:avatar_glow/avatar_glow.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold_main_screen_item.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/dialog/select_log_type.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/qr_scan.dart';
import 'package:firebase_calendar/screens/qr_scan/qr_view.dart';
import 'package:firebase_calendar/services/qr_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class UserLogsSingle extends StatelessWidget {
  final CurrentUserData currentUserData;
  final String userRole;
  QrServices qrServices = QrServices();
  UserLogsSingle(
      {Key? key, required this.currentUserData, required this.userRole})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BaseScaffoldMainScreenItem(
      body: _buildBody(size),
      fab: _buildFab(context),
    );
  }

  Widget _buildBody(Size size) {
    return StreamBuilder<List<QrScan>>(
        stream: qrServices.getQrListForUser(
            currentUserData.currentOrganizationId, currentUserData.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final list = snapshot.data!;
            if (list.length == 0) {
              return Center(child: Text('Your logs will appear here'.tr()));
            } else
              return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return buildCard(list[index], context, size);
                  });
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else
            return Center(child: CircularProgressIndicator());
        });
  }

  Widget _buildFab(BuildContext context) {
    return AvatarGlow(
      animate: true,
      repeat: true,
      glowColor: Constants.BUTTON_COLOR,
      child: FloatingActionButton(
        backgroundColor: Constants.BUTTON_COLOR,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => QrView(
                    currentUserData: currentUserData,
                    userRole: userRole,
                  )));
        },
        child: Icon(Icons.qr_code),
      ),
    );
  }

  Widget buildCard(QrScan qrScan, BuildContext context, Size size) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Constants.CONTAINER_COLOR,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Row(
                children: [
                  Text(Utils.toDateTranslated(qrScan.createdAt, context)),
                  SizedBox(width: 20),
                  Text(Utils.toTime(qrScan.createdAt)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Log status:'.tr()),
                  SizedBox(
                    width: 20,
                  ),
                  qrScan.logType == 'pending'
                      ? Text('Pending'.tr())
                      : Text(qrScan.logType.tr()),
                ],
              ),
              Row(
                mainAxisAlignment: qrScan.logType == 'pending'
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.spaceBetween,
                children: [
                  if (qrScan.logType != 'pending') ...[
                    qrScan.logType == 'Entry'
                        ? Icon(
                            Icons.login,
                            color: Constants.BUTTON_COLOR,
                          )
                        : Transform.rotate(
                            angle: 180 * math.pi / 180,
                            child: Icon(
                              Icons.logout,
                              color: Constants.CANCEL_COLOR,
                            ))
                  ],
                  ElevatedCustomButton(
                    text: 'Select log type'.tr(),
                    color: Constants.BUTTON_COLOR,
                    press: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return SelectLogTypeDialog(
                              qrId: qrScan.id,
                              organizationId:
                                  currentUserData.currentOrganizationId,
                            );
                          });
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
