import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/survey.dart';
import 'package:firebase_calendar/services/survey_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class AnswerSurveyScreen extends StatefulWidget {
  final CurrentUserData currentUserData;
  final Survey survey;
  const AnswerSurveyScreen({Key? key, required this.currentUserData,
    required this.survey}) : super(key: key);

  @override
  _AnswerSurveyScreenState createState() => _AnswerSurveyScreenState();
}

class _AnswerSurveyScreenState extends State<AnswerSurveyScreen> {


  late SurveyServices services;

  PageController _pageController = PageController(initialPage: 0);
  double currentPage = 0;
  List<bool> isIndexClicked=[];
  List<int> clickedIndex=[];




  late List<String> myResponses;
  bool isLastQuestionClicked=false;

  @override
  void initState() {
    services=SurveyServices(organizationId: widget.currentUserData.currentOrganizationId);
    services.init();
    myResponses=getMyResponses();
    widget.survey.surveyQuestions.forEach((element) {
      isIndexClicked.add(false);
      clickedIndex.add(-1);
    });

    if(!widget.survey.seenBy.contains(widget.currentUserData.uid)){
      services.updateSeenBy(widget.survey, widget.currentUserData.uid);
    }
    super.initState();
  }

  bool didIRespond(){
    bool didRespond=false;
    widget.survey.surveyResponses.forEach((element) {
      if(element.uid==widget.currentUserData.uid){
        didRespond=true;
      }
    });
    return didRespond;
  }

  List<String> getMyResponses(){
    List<String> myResponses=[];
    if(didIRespond()){
      widget.survey.surveyResponses.forEach((element) {
        if(element.uid==widget.currentUserData.uid){
          myResponses=element.responses;
        }
      });
    }
    return myResponses;
  }


  void _onChanged(int index) {
    setState(() {
      currentPage = index.toDouble();
    });
  }


  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return BaseScaffold(appBarName: 'Answer'.tr(), body:buildBody(size), shouldScroll: false,actions: [
      isLastQuestionClicked?IconButton(
          onPressed: () => saveSurvey(),
          icon: Icon(Icons.save, color: Constants.CANCEL_COLOR)):Container()
    ]);
  }

  Widget buildBody(Size size){
    return widget.survey.expiresAt.isBefore(DateTime.now())?Center(
      child: Container(
        child: Text('This survey has expired'.tr()),
      ),
    ):(myResponses.isEmpty? Column(
      children: [
        Container(
          height: size.height*0.7,
          child: PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: _onChanged,
              itemCount: widget.survey.surveyQuestions.length,
              scrollDirection: Axis.horizontal,
              controller: _pageController,
              itemBuilder: (context, index) {
                return _buildPageView(widget.survey.surveyQuestions[index],index);
              }),
        ),
        Spacer(),
        //DotsIndicator(dotsCount: widget.survey.surveyQuestions.length, position: currentPage),
        buildProgress()
      ],
    ):Center(child: Container(child: Text('Thank you for completing survey'.tr()))));
  }

  Widget buildProgress(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new LinearPercentIndicator(
            leading: Text('Question'.tr()+ ' ${(currentPage+1).toInt()}'+ ' of '.tr()+ '${widget.survey.surveyQuestions.length}'),
            width: 100.0,
            lineHeight: 20.0,
            percent: isLastQuestionClicked?1:currentPage/widget.survey.surveyQuestions.length,
            progressColor: Constants.CANCEL_COLOR,
            barRadius: Radius.circular(10)
          ),
        ],
      ),
    );
  }

  Widget _buildPageView(String question,int curIndex){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${curIndex+1}'+'.'+question,style: appTextStyle.copyWith(fontSize: 20)),
          SizedBox(height: 10,),
          ListView.builder(
            shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (_,index){
                return RadioListTile(title: Text(getTitle(index)),value: index, groupValue: clickedIndex[curIndex], onChanged: (value){
                     setState(() {
                       clickedIndex[curIndex]=index;
                       isIndexClicked[curIndex]=true;
                       if(curIndex==widget.survey.surveyQuestions.length-1){
                         isLastQuestionClicked=true;
                       }
                     });
                });
              }),
          isLastQuestionClicked?Container():MaterialButton(onPressed: isIndexClicked[curIndex]?()=>
              _pageController.nextPage(duration: Duration(milliseconds: 800), curve: Curves.bounceInOut):null,
            color: Constants.BUTTON_COLOR,child: Text('Next'.tr()),textColor: Colors.white,
            disabledColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  saveSurvey(){
    print(clickedIndex);
    services.saveSurvey(widget.survey,clickedIndex,widget.currentUserData.uid);
    Navigator.pop(context);
  }

  String getTitle(int index) {
    String title='';
   switch(widget.survey.type){
     case '1':
       switch(index){
         case 0:
           title='5';
           break;
         case 1:
           title='4';
           break;
         case 2:
           title='3';
           break;
         case 3:
           title='2';
           break;
         case 4:
           title='1';
           break;
       }
       break;
     case '2':
       switch(index){
         case 0:
           title='Strongly agree'.tr();
           break;
         case 1:
           title='Agree'.tr();
           break;
         case 2:
           title='Neutral'.tr();
           break;
         case 3:
           title='Disagree'.tr();
           break;
         case 4:
           title='Strongly disagree'.tr();
           break;
       }
       break;
     case '3':
       switch(index){
         case 0:
           title='Excellent'.tr();
           break;
         case 1:
           title='Very good'.tr();
           break;
         case 2:
           title='Good'.tr();
           break;
         case 3:
           title='Fair'.tr();
           break;
         case 4:
           title='Poor'.tr();
           break;
       }
       break;
   }
    return title;
  }
}
