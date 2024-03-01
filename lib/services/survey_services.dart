import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/models/survey.dart';
import 'package:firebase_calendar/services/count_service.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:uuid/uuid.dart';

import '../config/key_config.dart';
import '../shared/utils.dart';

class SurveyServices {
  final String organizationId;

  late CollectionReference<Map<String, dynamic>> surveyRef;
  late CountService countService;

  init() {
    surveyRef = Configuration.isProduction
        ? FirebaseFirestore.instance.collection(
        'survey/${organizationId}/surveys')
        : FirebaseFirestore.instance.collection(
        'survey_test/${organizationId}/surveys');
    countService=CountService(organizationId: organizationId);
    countService.init();
  }

  SurveyServices({
    required this.organizationId,
  });

  bool validateCreateSurvey(BuildContext context,List<String> surveyQuestions,List<String> toWho,String surveyTitle,String? type){
    if(surveyTitle.trim().isEmpty){
      Utils.showSnackBar(context, 'Add survey title'.tr());
      return false;
    } else if(surveyQuestions.isEmpty){
      Utils.showSnackBar(context, 'Add at least a survey question'.tr());
      return false;
    }else if(toWho.isEmpty){
      Utils.showSnackBar(context, 'Select target group'.tr());
      return false;
    }else if(type==null){
      Utils.showSnackBar(context, 'Select type'.tr());
      return false;
    }
    else return true;
  }


  void createSurvey(String surveyTitle,String createdBy,List<String> surveyQuestions,
      List<String> toWho,String type,DateTime expiresAt,MyProvider provider) async{
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    final surveyId=Uuid().v1().toString();
    final survey=Survey(surveyId: surveyId, organizationId: organizationId, surveyTitle: surveyTitle,
        createdBy: createdBy,surveyQuestions: surveyQuestions, toWho: toWho, seenBy: [], surveyResponses: [],
       createdAt: DateTime.now(),expiresAt: expiresAt,type: type
    );
    surveyRef.doc(surveyId).set(survey.toMap());
    countService.updateSurveyCountOnCreateSurvey(provider, toWho);
  }


  void updateSurvey() {}

  Stream<List<Survey>> getSurveys(){
    return surveyRef.snapshots().map((survey) => survey.docs.map((e) => Survey.fromMap(e.data())).toList());
  }

  ///updates survey seen by data so that it will not show on the main list;
  void updateSeenBy(Survey survey, String uid) {
    final seenBy=survey.seenBy;
    seenBy.add(uid);
    surveyRef.doc(survey.surveyId).update({'seenBy':seenBy});
    countService.updateAnnouncementCountOnSeenByUser(uid, ItemType.SURVEY);
  }

  void saveSurvey(Survey survey, List<int> responses,String uid) {

    List<String> toStringList=responses.map((e) => e.toString()).toList();
    final mySurveyResponse=SurveyResponse(uid: uid,responses:toStringList);
    final surveyResponses=survey.surveyResponses;
    surveyResponses.add(mySurveyResponse);

    List<Map<String,dynamic>> surveyResponsesMap=[];

    surveyResponses.forEach((element) {
      final response=SurveyResponse(uid: element.uid, responses: element.responses).toMap();
      surveyResponsesMap.add(response);
    });

    surveyRef.doc(survey.surveyId).update({'surveyResponses': surveyResponsesMap});

  }

  void deleteSurvey(Survey survey,MyProvider provider) async{
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    surveyRef.doc(survey.surveyId).delete();
    countService.updateSurveyCountOnDeleteSurvey(provider, survey.toWho, survey.seenBy);
  }



}