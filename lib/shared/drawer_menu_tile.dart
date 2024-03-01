import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';


class DrawerMenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;
  const DrawerMenuTile({Key? key, required this.title, required this.icon, required this.onTap, this.trailing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,color: Constants.CANCEL_COLOR,),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
