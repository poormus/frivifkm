import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../models/current_user_data.dart';


class SeeOffers extends StatelessWidget {
  final CurrentUserData currentUserData;

  const SeeOffers({Key? key, required this.currentUserData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('No offers at this point'.tr()),);
  }
}
