

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_calendar/config/key_config.dart';
import 'package:firebase_calendar/models/faq.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:uuid/uuid.dart';

class FaqServices{

  final refFaqs = Configuration.isProduction?FirebaseFirestore.instance.collection('faqs'):FirebaseFirestore.instance.collection('faqs_test');


  //creates an faq with the given organization id
  Future  createFaq(String question,String organizationId,String answer,BuildContext context,String uid) async{
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    try {
      String faqId=Uuid().v1().toString();
      refFaqs.doc(faqId).set({
       'faqId':faqId,
        'organizationId':organizationId,
        'question':question,
        'answer':answer,
        'createdByUid':uid
      });
      Navigator.pop(context);
    }  catch (e) {
      Utils.showErrorToast();
    }
  }
  //gets all the faqs for organization
  Stream<List<FAQ>> getOrganizationFaqs(String orgId){
    return refFaqs.where('organizationId',isEqualTo: orgId).snapshots().map((organizations) {
      return organizations.docs.map((organization){
        return FAQ.fromMap(organization.data());
      }).toList();
    });
  }

  Future updateFaq(String faqId,String question,String answer,BuildContext context) async{
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    try {
      refFaqs.doc(faqId).update({
        'question':question,
        'answer':answer
      });
      Navigator.pop(context);
    }  catch (e) {
      Utils.showErrorToast();
    }
  }

  Future deleteFaq(String faqId) async{
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if(!isConnected){
      Utils.showInternetErrorToast();
      return;
    }
    try {
      refFaqs.doc(faqId).delete();
    }  catch (e) {
      Utils.showErrorToast();
    }
  }
}