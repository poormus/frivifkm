import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/qr_scan.dart';
import 'package:firebase_calendar/services/qr_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

class ViewRecentUserActivity extends StatelessWidget {
  final String adminOrgId;
  final CurrentUserData userToManage;

  ViewRecentUserActivity({Key? key, required this.adminOrgId, required this.userToManage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qrServices=QrServices();

    final size=MediaQuery.of(context).size;
    final provider=Provider.of<MyProvider>(context);
    return BaseScaffold(appBarName: Utils.getUserName(userToManage.userName, userToManage.userSurname), body: buildBody(size,provider,qrServices), shouldScroll: false);
  }

  Widget buildBody(Size size,MyProvider provider,QrServices qrServices){
    return StreamBuilder<List<QrScan>>(
        stream: qrServices.getQrListForUser(adminOrgId, userToManage.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final list = snapshot.data!;

            if (list.length == 0) {
              return Center(child: Text('User logs will appear here'.tr()));
            } else
              return Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return buildCard(list[index], context,size,provider);
                    }),
              );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else
            return Center(child: CircularProgressIndicator());
        });
  }

  Widget buildCard(QrScan qrScan, BuildContext context, Size size,MyProvider provider) {
    final currentUserData=provider.getUserById(qrScan.uid);
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
              Text(qrScan.userName,style: appTextStyle.copyWith(fontWeight: FontWeight.bold,fontSize: 18),),
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
                  SizedBox(width: 20,),
                  qrScan.logType == 'pending'?Text('Pending'.tr()):Text(qrScan.logType.tr()),
                ],
              ),
              Row(
                mainAxisAlignment:qrScan.logType=='pending'? MainAxisAlignment.end:MainAxisAlignment.spaceBetween,
                children: [
                  if(qrScan.logType!='pending')...[
                    qrScan.logType=='Entry'?Icon(Icons.login,color: Constants.BUTTON_COLOR,):
                    Transform.rotate(
                        angle: 180 * math.pi / 180,
                        child: Icon(Icons.logout,color: Constants.CANCEL_COLOR,))
                  ],
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                      imageUrl: currentUserData.userUrl,
                      placeholder: (context, url) => new CircularProgressIndicator(),
                      errorWidget: (context, url, error) => new Icon(Icons.error),
                    ),
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
