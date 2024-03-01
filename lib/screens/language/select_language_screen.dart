import 'dart:developer';

import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';





class SelectLanguageScreen extends StatelessWidget {
  String languageName(String lang) {
    String langName = "";
    switch (lang) {
      case "en":
        langName = "English";
        break;
      case "no":
        langName = "Norsk";
        break;
    }
    return langName;
  }

  const SelectLanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(appBarName: 'Language'.tr(), body: buildBody(context), shouldScroll: false);
    return buildScaffold('Language'.tr(), context, buildBody(context), null);
  }

  Widget buildBody(BuildContext context){
    return ListView.builder(
        itemCount: context.supportedLocales.length,
        itemBuilder: (BuildContext context, index) {
          print(context.supportedLocales[index].toLanguageTag());
          return _SwitchListTileMenuItem(
              title: languageName(
                  context.supportedLocales[index].toLanguageTag()),
              locale: context.supportedLocales[index]);
        });
  }
}

class _SwitchListTileMenuItem extends StatelessWidget {
  const _SwitchListTileMenuItem({
    Key? key,
    required this.title,
    this.subtitle,
    required this.locale,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final Locale locale;

  bool isSelected(BuildContext context) => locale == context.locale;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
      elevation: 10,
      shadowColor: isSelected(context) ? Constants.BACKGROUND_COLOR : null,
      color: isSelected(context) ? Constants.BACKGROUND_COLOR : null,
      child: ListTile(
          dense: true,
          // isThreeLine: true,
          title: Text(
            title,
              ),
          onTap: () async {
            log(locale.toString(), name: toString());
            await context.setLocale(locale); //BuildContext extension method
            Navigator.pop(context);
          }),
    );
  }
}
