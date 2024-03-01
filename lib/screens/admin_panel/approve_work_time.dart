import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/dialog/update_work_time_dialog.dart';
import 'package:firebase_calendar/models/work_time.dart';
import 'package:firebase_calendar/services/group_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ApproveWorkTimeScreen extends StatefulWidget {
  final List<WorkTime> workTimes;
  final String groupName;
  final String uid;
  final int currentTotalPoint;
  ApproveWorkTimeScreen(
      {Key? key, required this.workTimes, required this.groupName,
        required this.uid, required this.currentTotalPoint})
      : super(key: key);

  @override
  State<ApproveWorkTimeScreen> createState() => _ApproveWorkTimeScreen();
}

class _ApproveWorkTimeScreen extends State<ApproveWorkTimeScreen> {

  GroupServices groupServices = GroupServices();

  late MyProvider provider;
  late List<WorkTime>? userWorkTimes;

  @override
  void didChangeDependencies() {
    provider=Provider.of<MyProvider>(context);
    userWorkTimes=provider.allWorkTimeOfAnOrganization['${widget.uid}'];
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    provider.setWorkTimesIdToZero();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return BaseScaffold(
        appBarName: widget.groupName,
        body: buildBody(context),
        shouldScroll: false);
  }


  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tap to select'.tr()),
              ElevatedCustomButton(text: 'Approve'.tr(), press: (){
                if(provider.workTimesId.length==0){
                  Utils.showToastWithoutContext('Please approve at least one item'.tr());
                  return;
                }
                groupServices.approveWorkTime(widget.uid,provider.workTimesId,provider.totalPoint+widget.currentTotalPoint,
                    provider,userWorkTimes);
                Navigator.pop(context);
                Navigator.pop(context);
              }, color: Constants.BUTTON_COLOR)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Total point approved:'.tr()),
                  SizedBox(width: 5),
                  Text(provider.totalPoint.toString()),
                ],
              ),
              Row(
                children: [
                  IconButton(onPressed: (){
                    setState(() {
                      provider.selectAllWorkTimes(widget.workTimes);
                    });

                  }, icon: Icon(Icons.select_all))
                ],
              )
            ],
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
              itemCount: widget.workTimes.length,
              itemBuilder: (_, index) {
                return buildListTile(widget.workTimes[index], context,provider);
              }),
        ),
      ],
    );
  }

  Widget buildListTile(WorkTime workTime, BuildContext context,MyProvider provider) {
    return Padding(
          padding: const EdgeInsets.all(4.0),
          child: GestureDetector(
            onTap: (){
              if(workTime.isApproved){
                Utils.showToastWithoutContext('Already approved'.tr());
              }else{
                if(provider.isWorkTimeIdInTheList(workTime.id)){
                  setState(() {
                    provider.removeWorkTimeId(workTime);
                  });

                }else if(!provider.isWorkTimeIdInTheList(workTime.id)){
                  setState(() {
                    provider.addWorkTimeId(workTime);
                  });
                }
              }
            },
            child: Card(
              child: Container(
                decoration: BoxDecoration(
                    color: Constants.CONTAINER_COLOR,
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(Utils.toDateTranslated(
                              workTime.workDate, context)),
                          workTime.isApproved?Text('Approved'.tr(),style: appTextStyle.copyWith(color: Constants.CANCEL_COLOR),):Container()
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              height: 40,
                              width: 60,
                              decoration: BoxDecoration(
                                  color: Constants.BACKGROUND_COLOR,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: Text(
                                  '${workTime.hourWorked
                                      .toString()}' +
                                      'h'.tr(),
                                  style: appTextStyle.copyWith(fontSize: 20),),
                              )),
                          provider.isWorkTimeIdInTheList(workTime.id)?Icon(Icons.check):Container()
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
  }


}
