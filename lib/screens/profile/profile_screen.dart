import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold_main_screen_item.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/my_appointment.dart';
import 'package:firebase_calendar/screens/offers/offers_main.dart';
import 'package:firebase_calendar/screens/offers/see_offers.dart';
import 'package:firebase_calendar/screens/rooms_screen/booking_history.dart';
import 'package:firebase_calendar/screens/profile/edit_profile_screen.dart';
import 'package:firebase_calendar/services/Firebase_service.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:flutter/material.dart';

import '../../anim/slide_in_right.dart';
import '../../shared/strings.dart';
import '../../shared/utils.dart';

class Profile extends StatelessWidget {
  final CurrentUserData userData;
  final String userRole;
  final authService = AuthService();
  final firebaseService = FireBaseServices();
  Profile({Key? key, required this.userData, required this.userRole}) : super(key: key);

  void editProfilePage(CurrentUserData userData,BuildContext context) {
    Navigation.navigateToEditProfile(context,userData);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BaseScaffold(shouldScroll: false,appBarName: Strings.PROFILE,body: buildBody(size,context));
  }

  Widget buildBody(Size size,BuildContext context) {
    return StreamBuilder<CurrentUserData>(
        stream: authService.getCurrentUser(userData.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final email = snapshot.data!.email;
            final userPhone = snapshot.data!.userPhone;
            final userName =
                '${snapshot.data!.userName} ${snapshot.data!.userSurname}';
            final totalPoint=snapshot.data!.totalPoint;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            width: size.width*0.4,
                            height: size.width*0.4,
                            imageUrl: snapshot.data!.userUrl,
                            placeholder: (context, url) =>
                            new LinearProgressIndicator(),
                            errorWidget: (context, url, error) =>
                            new Icon(Icons.error),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: size.width*0.5,
                            child: Text(userName.toUpperCase(),
                                style: TextStyle(fontSize: 20, color: Colors.black,overflow: TextOverflow.ellipsis)),
                          ),
                          Text(
                            Utils.getUserRoleFromIndex(userRole),
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text("Email:".tr(), style: textStyle),
                        SizedBox(height: 8),
                        Text("$email",style: appTextStyle,),
                        SizedBox(height: 8),
                        Divider(color: Colors.black12, thickness: 1, height: 4),
                        SizedBox(height: 8),
                        Text('Phone:'.tr(), style: textStyle),
                        SizedBox(height: 8),
                        Text(userPhone != ''
                            ? "$userPhone"
                            : 'Not given'.tr(),style: appTextStyle,),
                        SizedBox(height: 8),
                        Divider(color: Colors.black12, thickness: 1, height: 4),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => Navigation.navigateToUseCodeScreen(context,snapshot.data!),
                                child: Text('Have a code?'.tr(),
                                    style: TextStyle(
                                        decoration: TextDecoration.underline, color: Colors.black)),
                              ),
                              ElevatedCustomButton(
                                  text: 'Edit Profile'.tr(),
                                  press: () {
                                    editProfilePage(snapshot.data!,context);
                                  },
                                  color: Constants.BUTTON_COLOR)
                            ],
                          ),
                        ),
                        // buildPoint(totalPoint,size,context,userData)
                      ],
                    ),
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return noDataWidget(snapshot.error.toString(), false);
          } else {
            return noDataWidget(null, true);
          }
        });
  }

  Widget buildBodyNewNotUsed(Size size,BuildContext context) {
    final email = userData.email;
    final userPhone = userData.userPhone;
    final userName = Utils.getUserName(userData.userName, userData.userSurname);

    final totalPoint=userData.totalPoint;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: size.width * 0.3,
                    height: size.height * 0.2,
                    imageUrl: userData.userUrl,
                    placeholder: (context, url) =>
                    new LinearProgressIndicator(),
                    errorWidget: (context, url, error) =>
                    new Icon(Icons.error),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: size.width*0.5,
                    child: Text(userName.toUpperCase(),
                        style: TextStyle(fontSize: 20, color: Colors.black,overflow: TextOverflow.ellipsis)),
                  ),
                  Text(
                    Utils.getUserRoleFromIndex(userRole),
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 16),
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text("Email:".tr(), style: textStyle),
                SizedBox(height: 8),
                Text("$email",style: appTextStyle,),
                SizedBox(height: 8),
                Divider(color: Colors.black12, thickness: 1, height: 4),
                SizedBox(height: 8),
                Text('Phone:'.tr(), style: textStyle),
                SizedBox(height: 8),
                Text(userPhone != ''
                    ? "$userPhone"
                    : 'Not given'.tr(),style: appTextStyle,),
                SizedBox(height: 8),
                Divider(color: Colors.black12, thickness: 1, height: 4),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => Navigation.navigateToUseCodeScreen(context,userData),
                        child: Text('Have a code?'.tr(),
                            style: TextStyle(
                                decoration: TextDecoration.underline, color: Colors.black)),
                      ),
                      ElevatedCustomButton(
                          text: 'Edit Profile'.tr(),
                          press: () {
                            editProfilePage(userData,context);
                          },
                          color: Constants.BUTTON_COLOR)
                    ],
                  ),
                ),
                //buildPoint(totalPoint,size,context,userData)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildPoint(int totalPoint,Size size,BuildContext context,CurrentUserData currentUserData){
    return Stack(
      children:[
        Container(
          height: 150,
          decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/point_background.png'),opacity: 0.3)
          ),
        ),
      Positioned.fill(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Container(
                  width: 50,
                  height: 50,
                  child: Image.asset('assets/point_badge.png')),
              Text('You have'.tr(),style: appTextStyle.copyWith(color: Constants.BUTTON_COLOR,fontSize: 16)),
              Text('${totalPoint} points'.tr(),style: appTextStyle.copyWith(color: Constants.BUTTON_COLOR,fontSize: 22)),
               ElevatedCustomButton(text: 'See offers'.tr(), press: (){
                 Navigator.push(
                     context,
                     SlideInRight(OffersMain(currentUserData:currentUserData)));
               }, color: Constants.BUTTON_COLOR)
            ],
          ),
        ),
      )
      ]
    );
  }
}




