import 'package:avatar_glow/avatar_glow.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/faq.dart';
import 'package:firebase_calendar/screens/faq/add_edit_faq.dart';
import 'package:firebase_calendar/services/faq_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/utils.dart';

class FaqScreen extends StatefulWidget {
  final CurrentUserData currentUserData;

  const FaqScreen({Key? key, required this.currentUserData}) : super(key: key);

  @override
  _FaqScreenState createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final faqServices = FaqServices();
  late String userRole;

  @override
  void initState() {
    userRole = Utils.getUserRole(widget.currentUserData.userOrganizations,
        widget.currentUserData.currentOrganizationId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
        appBarName: 'FAQ'.tr(),
        body: buildBody(),
        shouldScroll: false,
        floatingActionButton: buildFab());
    return buildScaffold('FAQ', context, buildBody(), buildFab());
  }

  Widget? buildFab() {
    return userRole == '4' || userRole == '3'
        ? AvatarGlow(
            animate: true,
            repeat: true,
            glowColor: Constants.BUTTON_COLOR,
            child: FloatingActionButton(
              backgroundColor: Constants.BUTTON_COLOR,
              onPressed: () {
                Navigation.navigateToAddEditFaqScreen(
                    context,
                    widget.currentUserData.currentOrganizationId,
                    null,
                    widget.currentUserData.uid);
              },
              child: Icon(Icons.question_answer_outlined),
            ),
          )
        : null;
  }

  Widget buildBody() {
    return StreamBuilder<List<FAQ>>(
      stream: faqServices
          .getOrganizationFaqs(widget.currentUserData.currentOrganizationId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final list = snapshot.data!;
          if (list.length == 0) {
            return noDataWidget('No faq added'.tr(), false);
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FaqTile(
                  faq: list,
                  userData: widget.currentUserData,
                  userRole: userRole,
                  faqServices: faqServices,
                ),
              ),
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

class FaqTile extends StatelessWidget {
  final List<FAQ> faq;
  final CurrentUserData userData;
  final String userRole;
  final FaqServices faqServices;

  const FaqTile(
      {Key? key,
      required this.faq,
      required this.userData,
      required this.userRole,
      required this.faqServices})
      : super(key: key);

  void navigateToAddEditFaq(FAQ faq, BuildContext context) {
    Navigation.navigateToAddEditFaqScreen(
        context, userData.currentOrganizationId, faq, userData.uid);
  }

  showDeleteFaqDialog(BuildContext context, String faqId) {
    BlurryDialogNew alert = BlurryDialogNew(
        title: "Delete this Faq?".tr(),
        continueCallBack: () {
          faqServices.deleteFaq(faqId);
          Navigator.of(context).pop();
        });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList.radio(
      children: faq
          .map((e) => ExpansionPanelRadio(
              canTapOnHeader: true,
              value: e.faqId,
              headerBuilder: (context, isExpanded) {
                return ListTile(
                  title: Text(e.question),
                );
              },
              body: ListTile(
                  title: Linkify(
                    text: e.answer,
                    linkStyle: TextStyle(color: Colors.blueAccent),
                    onOpen: (link) async {
                      if (await canLaunch(link.url)) {
                        await launch(link.url);
                      } else {
                        throw 'Could not launch';
                      }
                    },
                  ),
                  subtitle: e.createdByUid == userData.uid || userRole == '4'
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                onPressed: () {
                                  navigateToAddEditFaq(e, context);
                                },
                                icon: Icon(Icons.edit,
                                    color: Constants.BUTTON_COLOR)),
                            SizedBox(width: 10),
                            IconButton(
                                onPressed: () {
                                  showDeleteFaqDialog(context, e.faqId);
                                },
                                icon: Icon(Icons.delete_rounded,
                                    color: Constants.CANCEL_COLOR)),
                          ],
                        )
                      : null)))
          .toList(),
    );
  }
}
