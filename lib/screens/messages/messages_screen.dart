import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold_main_screen_item.dart';
import 'package:firebase_calendar/models/created_chats.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/started_group_chat.dart';
import 'package:firebase_calendar/screens/messages/channels.dart';
import 'package:firebase_calendar/screens/messages/messages.dart';
import 'package:firebase_calendar/screens/messages/people.dart';
import 'package:firebase_calendar/services/messages_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';

class Messages extends StatefulWidget {
  final CurrentUserData userdata;
  final String userRole;
  final int totalPrivateChatUnseenMessage;
  final int totalChannelUnseenMessage;
  final List<CreatedChats> createdChats;
  final List<StartedGroupChat> startedGroupChats;
  const Messages(
      {Key? key, required this.userdata, required this.userRole, required this.totalPrivateChatUnseenMessage,
        required this.totalChannelUnseenMessage, required this.createdChats, required this.startedGroupChats})
      : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {

  late Stream<List<CreatedChats>> getCreatedChats;
  late Stream<List<StartedGroupChat>> getStartedChats;
  final messageService = MessageService();
  String isClicked = 'inbox';

  @override
  void initState() {
    getCreatedChats=messageService.getCreatedChats(widget.userdata.uid, widget.userdata.currentOrganizationId);
    getStartedChats=messageService.getStartedGroupChats(widget.userdata.uid, widget.userdata.currentOrganizationId);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BaseScaffoldMainScreenItem(body: _buildBody());
    return BaseScaffold(appBarName: 'Messages'.tr(), body: _buildBody(), shouldScroll: false);
    return buildScaffold('Messages', context, _buildBody(), null);
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: Constants.TAB_HEIGHT,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        isClicked = 'users';
                      });
                    },
                    child: Text(
                      'Users'.tr(),
                      style: TextStyle(
                          color: isClicked == 'users'
                              ? Constants.BUTTON_COLOR
                              : Colors.grey),
                    )),
              ),
              VerticalDivider(width: 3, color: Colors.grey),
              Expanded(
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        isClicked = 'channels';
                      });
                    },
                    child: Text('Channels'.tr(),
                        style: TextStyle(
                            color: isClicked == 'channels'
                                ? Constants.BUTTON_COLOR
                                : Colors.grey))),
              ),
              VerticalDivider(width: 3, color: Colors.grey),
              Expanded(
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        isClicked = 'inbox';
                      });
                    },
                    child: Text('Inbox'.tr(),
                        style: TextStyle(
                            color: isClicked == 'inbox'
                                ? Constants.BUTTON_COLOR
                                : Colors.grey))),
              ),
            ],
          ),
        ),
        Divider(
          height: 3,
          color: Colors.grey,
        ),
        SizedBox(height: 5),
        if(isClicked == 'users')...[
          People(userData: widget.userdata, messageService: messageService)
        ] else if(isClicked == 'inbox')...[
          FutureBuilder(
              future: Future.delayed(Duration(seconds: 2)),
              builder: (c,s){
                if(s.connectionState==ConnectionState.done){
                  int totalPrivateChatUnseenMessage=0;
                  int totalChannelUnseenMessage=0;
                  List<CreatedChats> createdChats=[];
                  List<StartedGroupChat> createdGroupChats=[];
                  return StreamBuilder<List<CreatedChats>>(
                      stream: getCreatedChats,
                      builder: (context, snapshot) {
                        if(snapshot.hasData){
                          createdChats=snapshot.data!;
                          createdChats.forEach((element) {
                            totalPrivateChatUnseenMessage+=element.unseenMessageCount;
                          });
                          return StreamBuilder<List<StartedGroupChat>>(
                              stream: getStartedChats,
                              builder: (context, snapshot) {
                                if(snapshot.hasData){
                                  createdGroupChats=snapshot.data!;
                                  createdGroupChats.forEach((element) {
                                    totalChannelUnseenMessage+=element.unseenMessageCount;
                                  });
                                }
                                return  StartedChats(
                                  userData: widget.userdata,
                                  messageService: messageService,
                                  totalChannelUnseenMessage:totalChannelUnseenMessage,
                                  totalPrivateChatUnseenMessage: totalPrivateChatUnseenMessage,
                                  createdChats:createdChats,
                                  startedGroupChats: createdGroupChats,
                                );
                              }
                          );
                        }else{
                          return Container();
                        }
                      }
                  );

                }else return Column(
                  children: [
                    noDataWidget('', true),
                    Center(child: Text('Fetching data'.tr())),
                  ],
                );
              })
          ] else if(isClicked == 'channels')...[
              Channels(currentUserData: widget.userdata, userRole: widget.userRole)
            ]
      ],
    );
  }
}

