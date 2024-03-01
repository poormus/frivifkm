import 'package:cached_network_image/cached_network_image.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/anim/slide_in_right.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/extensions/extensions.dart';
import 'package:firebase_calendar/main.dart';
import 'package:firebase_calendar/models/survey.dart';
import 'package:firebase_calendar/screens/how_to/how_to_screen.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/current_user_data.dart';
import '../../shared/constants.dart';

class ViewStatisticsScreen extends StatefulWidget {
  final Survey survey;

  const ViewStatisticsScreen({Key? key, required this.survey})
      : super(key: key);

  @override
  _ViewStatisticsScreenState createState() => _ViewStatisticsScreenState();
}

class _ViewStatisticsScreenState extends State<ViewStatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider=Provider.of<MyProvider>(context);
    final size = MediaQuery.of(context).size;
    return BaseScaffold(
        appBarName: "Statistics".tr(),
        body: buildBody(size,provider,context),
        shouldScroll: false);
  }

  Widget buildBody(Size size,MyProvider provider,BuildContext context) {
    final list = widget.survey.surveyQuestions;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ExpansionPanelList.radio(
            children: list.mapIndexed((element, index) {
          return ExpansionPanelRadio(
              value: element,
              headerBuilder: (context, isExpanded) {
                return ListTile(title: Text(element));
              },
              body: buildChart(element, index,provider,size));
        }).toList()),
      ),
    );
    // return SingleChildScrollView(
    //   child: Padding(
    //     padding: const EdgeInsets.all(8.0),
    //     child: ExpansionPanelList.radio(
    //       children: widget.survey.surveyQuestions.map((e) =>
    //           ExpansionPanelRadio(
    //               canTapOnHeader: true,
    //               value: e, headerBuilder: (context, isExpanded){
    //                 return ListTile(title: Text(e));
    //           }, body: Container())).toList(),
    //     ),
    //   ),
    // );
  }

  Widget buildChart(String Question, int index,MyProvider provider,Size size) {
    final responsesForQuestion = <String>[];

    int zeroCount = 0;
    int oneCount = 0;
    int twoCount = 0;
    int threeCount = 0;
    int fourCount = 0;

    for (var i = 0; i < widget.survey.surveyResponses.length; i++) {
      responsesForQuestion
          .add(widget.survey.surveyResponses[i].responses[index]);
    }

    responsesForQuestion.forEach((element) {
      switch (element) {
        case '0':
          zeroCount++;
          break;
        case '1':
          oneCount++;
          break;
        case '2':
          twoCount++;
          break;
        case '3':
          threeCount++;
          break;
        case '4':
          fourCount++;
          break;
      }
    });
    final list = [0, 1, 2, 3, 4];
    final counts = [zeroCount, oneCount, twoCount, threeCount, fourCount];

    List<charts.Series<int, String>> series = [
      charts.Series(
          id: index.toString(),
          data: list,
          domainFn: (int response, i) => getResponseName(response.toString()),
          measureFn: (int, _) => counts[int])
    ];
    final model = [
      new charts.SelectionModelConfig<String>(
        type: charts.SelectionModelType.info,
        changedListener: (model) {
          buildUidList(index,model.selectedDatum.first.datum,provider,size);
          print('Change in ${model.selectedDatum.first.datum}');
        },
        updatedListener: (model) {
          print('updatedListener in $model');
        },
      )
    ];
    return Container(height: 100, child: charts.BarChart(series,selectionModels: model));
  }

  String getResponseName(String response) {
    String name = '';
    switch (widget.survey.type) {
      case '1':
        switch (response) {
          case '0':
            name = '5';
            break;
          case '1':
            name = '4';
            break;
          case '2':
            name = '3';
            break;
          case '3':
            name = '2';
            break;
          case '4':
            name = '1';
            break;
        }
        break;
      case '2':
        switch (response) {
          case '0':
            name = 'Strongly agree'.tr();
            break;
          case '1':
            name = 'Agree'.tr();
            break;
          case '2':
            name = 'Neutral'.tr();
            break;
          case '3':
            name = 'Disagree'.tr();
            break;
          case '4':
            name = 'Strongly disagree'.tr();
            break;
        }
        break;
      case '3':
        switch (response) {
          case '0':
            name = 'Excellent'.tr();
            break;
          case '1':
            name = 'Very good'.tr();
            break;
          case '2':
            name = 'Good'.tr();
            break;
          case '3':
            name = 'Fair'.tr();
            break;
          case '4':
            name = 'Poor'.tr();
            break;
        }
        break;
    }

    return name;
  }

  void buildUidList(int index, int answerIndex,MyProvider provider,Size size) {
    List<String> uids=[];
    final responses=widget.survey.surveyResponses;
    responses.forEach((element) {
      if(element.responses[index]==answerIndex.toString()){
        uids.add(element.uid);
      }
    });
    showSnackBAr(uids,provider,size);
  }


  List<CurrentUserData> getUsersFromUid(MyProvider provider,List<String> uids){
    List<CurrentUserData> users=[];
    uids.forEach((uid) {
      provider.allUsersOfOrganization.forEach((user) {
        if(user.uid==uid){
          users.add(user);
        }
      });
    });
    return users;
  }
  Widget buildList(Size size,List<String> uids,MyProvider provider){
    final userList= getUsersFromUid(provider, uids);
    return Container(
      margin: EdgeInsets.only(left: 5),
      height: 50,
      width: size.width * 0.6,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: userList.length,
          itemBuilder: (_, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: 30,
                  height: 50,
                  imageUrl: userList[index].userUrl,
                  placeholder: (context, url) =>
                  new LinearProgressIndicator(),
                  errorWidget: (context, url, error) =>
                  new Icon(Icons.error),
                ),
              ),
            );
          }),
    );
  }
  void showSnackBAr(List<String> uids,MyProvider provider,Size size) {
    final snackBar= SnackBar(
      content: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Constants.BACKGROUND_COLOR
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildList(size, uids, provider),
              Image.asset('assets/frivi_logo.png',height: 30,width: 30,)
            ],
          )),
      dismissDirection: DismissDirection.down,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
    MyApp.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);

  }

}



