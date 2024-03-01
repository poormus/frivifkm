import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/models/channel.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/group.dart';
import 'package:firebase_calendar/services/count_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../models/poll.dart';
import '../services/messages_services.dart';
import '../shared/no_data_or_progres_widget.dart';

class SelectChannelDialog extends StatefulWidget {
  final Poll poll;
  final CurrentUserData currentUserData;
  const SelectChannelDialog({Key? key, required this.poll, required this.currentUserData})
      : super(key: key);

  @override
  _SelectUserForGroupDialogState createState() =>
      _SelectUserForGroupDialogState();
}

class _SelectUserForGroupDialogState extends State<SelectChannelDialog> {

  MessageService service = MessageService();

  late Stream<List<Channel>> channels;
  late CountService countService;
  String channelId='';
  String channelName='';
  List<String> memberUids=[];


  int selectedIndex=-1;
  bool isSelected=false;

  @override
  void initState() {
    countService=CountService(organizationId: widget.currentUserData.currentOrganizationId);
    countService.init();
    channels=service.getChannels(widget.currentUserData.currentOrganizationId);
    super.initState();
  }

  void dismissDialog() {
    Future.delayed(const Duration(milliseconds: 200), () {
      // When task is over, close the dialog
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context);
    final size = MediaQuery.of(context).size;
    return Theme(
      data: ThemeData.light(),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(24),
          ),
        ),
        backgroundColor: Constants.BACKGROUND_COLOR,
        child: Container(
            height: 250,
            width: size.width * 0.40,
            child: Stack(
              children: [
                Column(
                  children: [
                    StreamBuilder<List<Channel>>(
                        stream: channels,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final channels = snapshot.data!;
                            return Container(
                              height: 200,
                              child: ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (_, index) {
                                    final channel = channels[index];
                                    return buildChannels(channel, context, provider,size,index);
                                  }),
                            );
                          } else if (snapshot.hasError) {
                            return noDataWidget(snapshot.error.toString(), false);
                          } else
                            return noDataWidget(null, true);
                        }),
                    MaterialButton(onPressed: isSelected?()=>shareOnChannel():null,
                      color: Constants.BUTTON_COLOR,child: Text('Share'.tr()),textColor: Colors.white,
                    disabledColor: Colors.grey,
                    )
                  ],
                ),
                Align(
                  // These values are based on trial & error method
                  alignment: Alignment(1.1, -1.1),
                  child: InkWell(
                    onTap: () {
                      dismissDialog();
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
      ),
    );
  }

  shareOnChannel(){
    Utils.showToastWithoutContext('Sharing'.tr());
    setState(() {
      isSelected=false;
    });
    final service=MessageService();
    service.uploadGroupChat(channelId, widget.currentUserData.uid, getName(), getMessage());
    service.uploadStartedGroupChat(widget.currentUserData.currentOrganizationId, channelId, channelName,
        getMessage(), widget.currentUserData.uid, getName(), memberUids,countService);
    Navigator.pop(context);
  }

  String getName(){
    return Utils.getUserName(widget.currentUserData.userName, widget.currentUserData.userSurname);
  }
  String getMessage(){
    String message='${widget.poll.pollQuestion} poll results:\n';
    widget.poll.pollItems.forEach((element) {
      message+='${element.item}: total vote: ${element.answeredUserId.length}\n';
    });
    return message;
  }

  Widget buildChannels(
      Channel channel, BuildContext context, MyProvider provider,Size size,int index) {
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        color: Constants.CONTAINER_COLOR,
        child: ListTile(title: Text('# ${channel.channelName}', style: appTextStyle),
        trailing: selectedIndex == index ? Icon(Icons.check,color: Constants.BUTTON_COLOR) : null,
        onTap: (){
          channelId=channel.channelId;
          channelName=channel.channelName;
          memberUids=channel.membersIds;
          setState(() {
            selectedIndex = index;
            isSelected=true;
          });
        },
        ),

      ),
    );
  }

}






