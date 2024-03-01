import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/config/key_config.dart';
import 'package:firebase_calendar/models/announcement.dart';
import 'package:firebase_calendar/services/announcements_service.dart';
import 'package:firebase_calendar/services/count_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../shared/utils.dart';

//ignore: must_be_immutable
class AnnouncementDetailScreen extends StatelessWidget {
  final Announcement announcement;
  final String uid;

  AnnouncementService service=AnnouncementService();
   AnnouncementDetailScreen({Key? key, required this.announcement, required this.uid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {


    if(!announcement.seenBy.contains(uid)){
      service.updateSeenByForUser(announcement, uid);
      final countService=CountService(organizationId: announcement.organizationId);
      countService.init();
      countService.updateAnnouncementCountOnSeenByUser(uid,ItemType.ANNOUNCEMENT);
    }
    Size size = MediaQuery.of(context).size;
    return BaseScaffold(appBarName: Strings.DETAILS.tr(), body: _buildBody(size, context), shouldScroll: false);
    return buildScaffold(Strings.DETAILS.tr(), context, _buildBody(size, context), null);
  }

  Widget _buildBody(Size size, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(
              '${Utils.getTimeAgo(announcement.createdAt, context)}${Strings.BY.tr()}${announcement.createdBy}',
              style: appTextStyle),
          SizedBox(height: 10),
          Container(
            width: size.width,
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('${announcement.announcementTitle}'),
            ),
          ),
          Divider(
            height: 2,
            color: Colors.grey[500],
          ),
          Container(
            width: size.width,
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('${announcement.announcement}'),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.visibility,color: Constants.BUTTON_COLOR,),
                  onPressed: (){
                    Navigation.navigateToSeenByScreen(context,announcement.seenBy,announcement.organizationId);
                  },
                ),
              ],
            ),
          ),
          //TranslateAnnouncement(toTranslate: announcement.announcement)
        ],
      ),
    );
  }
}


class TranslateAnnouncement extends StatefulWidget {
  final String toTranslate;
  const TranslateAnnouncement({Key? key, required this.toTranslate}) : super(key: key);

  @override
  _TranslateAnnouncementState createState() => _TranslateAnnouncementState();
}

class _TranslateAnnouncementState extends State<TranslateAnnouncement> {

  String translatedText='';
  bool isTranslating=false;
  
  updateUi(bool translate){
    setState(() {
      isTranslating=translate;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        InkWell(

          onTap: () => translate(),
          child: Container(
            width: 100,
            height: 50,
            child: Text('Translate'.tr(),
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue)),
          ),
        ),
        translatedText==''?Container():Container(
          width: size.width,
          decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${translatedText}'),
          ),
        ),
        SizedBox(height: 10),
        isTranslating?CircularProgressIndicator():Container()
      ],
    );
  }

  translate() async{

    final String defaultLocale = Platform.localeName;
    String to=defaultLocale.substring(0,2);
    final url=
    Uri.parse('https://translation.googleapis.com/language/translate/v2?target=${to}&key=${Configuration.API_KEY_TRANSLATE}&q=${widget.toTranslate}');
    String text='';
    try {
      updateUi(true);
      final response=await http.post(url);
      if(response.statusCode==200){
        final body=json.decode(response.body);
        final translations=body['data']['translations'] as List;
        final translation=translations.first;
        setState(() {
          translatedText=translation['translatedText'];
          isTranslating=false;
        });
      }else{
        updateUi(false);
      }
    } on Exception catch (e) {
      Utils.showToastWithoutContext('An error occurred'.tr());
      updateUi(false);
    }


  }
}

