import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:flutter/material.dart';



class OfferHistory extends StatelessWidget {
  final CurrentUserData currentUserData;
  const OfferHistory({Key? key, required this.currentUserData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('your history is empty'.tr()),);
  }
}
