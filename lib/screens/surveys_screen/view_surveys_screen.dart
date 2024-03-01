import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/survey.dart';
import 'package:firebase_calendar/screens/surveys_screen/view_statistics_screen.dart';
import 'package:firebase_calendar/services/survey_services.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../anim/slide_in_right.dart';
import '../../components/cutom_circular.dart';
import '../../shared/constants.dart';
import 'add_new_survey.dart';
import 'answer_survey_screen.dart';

class ViewSurveysScreen extends StatefulWidget {
  final CurrentUserData currentUserData;
  final String userRole;

  const ViewSurveysScreen(
      {Key? key, required this.currentUserData, required this.userRole})
      : super(key: key);

  @override
  State<ViewSurveysScreen> createState() => _ViewSurveysScreenState();
}

class _ViewSurveysScreenState extends State<ViewSurveysScreen> {
  late SurveyServices surveyService;
  late MyProvider provider;

  @override
  void initState() {
    surveyService = SurveyServices(
        organizationId: widget.currentUserData.currentOrganizationId);
    surveyService.init();
    provider = Provider.of<MyProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBarName: 'Surveys'.tr(),
      body: buildBody(),
      shouldScroll: false,
      floatingActionButton: buildFab(context),
    );
  }

  List<Survey> getMySurveys(List<Survey> surveys) {
    List<Survey> mySurveys = [];
    if (widget.userRole == '4' || widget.userRole == '3') {
      mySurveys = surveys;
    } else {
      surveys.forEach((element) {
        bool isToMe = false;
        if (widget.currentUserData.groupIds
                    .toSet()
                    .intersection(element.toWho.toSet())
                    .length !=
                0 ||
            element.toWho.contains(widget.userRole)) {
          isToMe = true;
        }
        if (isToMe) {
          mySurveys.add(element);
        }
      });
    }
    return mySurveys;
  }

  Widget buildBody() {
    return StreamBuilder<List<Survey>>(
        stream: surveyService.getSurveys(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // if(snapshot.data?.length==0){
            //   return ProgressWithIcon();
            // }
            final data = getMySurveys(snapshot.data!);
            return ListView.builder(
                itemCount: data.length,
                itemBuilder: (_, index) {
                  final survey = data[index];
                  final createdBy = provider.getUserById(data[index].createdBy);
                  return buildTile(
                      createdBy.userUrl, survey, widget.currentUserData.uid);
                });
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return Center(child: ProgressWithIcon());
          }
        });
  }

  Widget? buildFab(BuildContext context) {
    return widget.userRole == '4' || widget.userRole == '3'
        ? AvatarGlow(
            animate: true,
            repeat: true,
            glowColor: Constants.BUTTON_COLOR,
            child: FloatingActionButton(
              backgroundColor: Constants.BUTTON_COLOR,
              onPressed: () {
                Navigator.push(
                    context,
                    SlideInRight(Dismissible(
                      key: Key('addSurvey'),
                      onDismissed: (_) => Navigator.of(context).pop(),
                      direction: DismissDirection.startToEnd,
                      child: AddEditSurvey(
                          currentUserData: widget.currentUserData),
                    )));
              },
              child: Icon(Icons.add),
            ),
          )
        : null;
  }

  Widget buildTile(String createdBy, Survey survey, String uid) {
    return Card(
      child: Column(
        children: [
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  SlideInRight(Dismissible(
                    key: Key('answerSurvey'),
                    onDismissed: (_) => Navigator.of(context).pop(),
                    direction: DismissDirection.startToEnd,
                    child: AnswerSurveyScreen(
                        currentUserData: widget.currentUserData,
                        survey: survey),
                  )));
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                width: 30,
                height: 30,
                imageUrl: createdBy,
                placeholder: (context, url) => new LinearProgressIndicator(),
                errorWidget: (context, url, error) => new Icon(Icons.error),
              ),
            ),
            title: Text(survey.surveyTitle),
            subtitle: Text('${survey.surveyQuestions.length.toString()} ' +
                'question(s)'.tr()),
            trailing: !survey.seenBy.contains(uid)
                ? Icon(Icons.info, color: Constants.CANCEL_COLOR)
                : null,
          ),
          survey.createdBy == widget.currentUserData.uid ||
                  widget.userRole == '4'
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total answers:'.tr() +
                          ' ${survey.surveyResponses.length}'),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    SlideInRight(Dismissible(
                                        onDismissed: (_) =>
                                            Navigator.of(context).pop(),
                                        direction: DismissDirection.startToEnd,
                                        key: Key('statistics'),
                                        child: ViewStatisticsScreen(
                                            survey: survey))));
                              },
                              icon: Icon(
                                Icons.poll,
                                color: Constants.BUTTON_COLOR,
                              )),
                          IconButton(
                              onPressed: () {
                                deleteSurvey(survey, provider);
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Constants.CANCEL_COLOR,
                              ))
                        ],
                      )
                    ],
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  void deleteSurvey(Survey survey, MyProvider provider) {
    final dialog = BlurryDialogNew(
        title: 'Delete survey?',
        continueCallBack: () {
          surveyService.deleteSurvey(survey, provider);
          Navigator.pop(context);
        });
    showDialog(
        context: context,
        builder: (_) {
          return dialog;
        });
  }
}
