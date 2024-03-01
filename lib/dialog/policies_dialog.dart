import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowPolicies extends StatelessWidget {

  ShowPolicies({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(24),
        ),
      ),
      backgroundColor: Constants.BACKGROUND_COLOR,
      child: Container(
          height: size.height * 0.25,
          child: Stack(
            children: [
              ListView(
                children: [
                  ListTile(
                    title: Text('Terms of Use'.tr()),
                    subtitle:  Linkify(
                      linkStyle: TextStyle(color: Colors.blueAccent),
                      onOpen: (link) async {
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          throw 'Could not launch';
                        }
                      },
                      text: 'https://friviapp.com/terms-of-use',
                    ),
                  ),
                  ListTile(
                    title: Text('Privacy Policy'.tr()),
                    subtitle:   Linkify(
                      linkStyle: TextStyle(color: Colors.blueAccent),
                      onOpen: (link) async {
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          throw 'Could not launch';
                        }
                      },
                      text: 'https://friviapp.com/privacy-policy-app/',
                    ),
                  ),
                ],
              ),
              Align(
                // These values are based on trial & error method
                alignment: Alignment(1.1, -1.1),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.cancel,
                      color: Constants.CANCEL_COLOR,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

}
