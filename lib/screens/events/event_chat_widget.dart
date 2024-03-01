import 'dart:async';

import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/dialog/get_all_users.dart';
import 'package:firebase_calendar/helper/mark_down.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/event_chat.dart';
import 'package:firebase_calendar/services/event_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../components/sized_box.dart';

class EventChatScreen extends StatefulWidget {
  final CurrentUserData currentUserData;
  final String eventId;

  const EventChatScreen(
      {Key? key, required this.currentUserData, required this.eventId})
      : super(key: key);

  @override
  _EventChatScreenState createState() => _EventChatScreenState();
}

class _EventChatScreenState extends State<EventChatScreen> {
  final eventService = EventServices();
  String message = '';
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  late String myName;
  late List<String> otherNames;
  bool showMentionDialog = false;
  late Stream<List<EventChat>> getEventChats;
  late MyProvider provider;


  Future uploadEventChat() async {


    eventService.createEventChat(
        widget.eventId, widget.currentUserData.uid, message.trim().replaceAll('\n', '\n'));
    _controller.clear();
    setState(() {
      message = '';
    });
    Timer(
        Duration(milliseconds: 300),
        () => _scrollController.hasClients
            ? _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent)
            : null);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    provider = Provider.of<MyProvider>(context,listen: false);
    getEventChats=eventService.getEventChats(widget.eventId);
    Timer(
        Duration(milliseconds: 300),
        () => _scrollController.hasClients
            ? _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent)
            : null);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    myName = Utils.getUserName(
        widget.currentUserData.userName, widget.currentUserData.userSurname);
    otherNames = provider.getOtherNames(myName);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder<List<EventChat>>(
        stream: getEventChats,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messages = snapshot.data!;
            if (messages.length == 0) {
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      height: size.height * 0.1,
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                          color: Constants.BACKGROUND_COLOR,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Center(
                        child: Text(
                            'This is the very beginning of your chat'.tr()),
                      ),
                    ),
                    Spacer(),
                    //showMentionDialog?buildUserMention([], size):Container(),
                    chatInputWidget(context),
                    SizedBoxWidget()
                  ],
                ),
              );
            } else {
              return Expanded(
                child: Column(
                  children: [
                    Expanded(
                        child: ListView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: messages.length,
                            itemBuilder: (_, index) {
                              final message = messages[index];
                              final bool isMe =
                                  message.uid == widget.currentUserData.uid;
                              return EventChatMessageTile(
                                  uid: message.uid,
                                  provider: provider,
                                  myName: myName,
                                  otherNames: otherNames,
                                  message: message,
                                  isMe: isMe);
                            })),
                    chatInputWidget(context),
                    SizedBoxWidget()
                  ],
                ),
              );
            }
          } else if (snapshot.hasError) {
            return noDataWidget(snapshot.error.toString(), false);
          } else {
            return noDataWidget(null, true);
          }
        });
  }

  Widget chatInputWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20 * 0.75),
        decoration: BoxDecoration(
          border: Border.all(
            color: Constants.BACKGROUND_COLOR,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(40),
          // boxShadow: [
          //   BoxShadow(
          //       offset: Offset(0, 4),
          //       blurRadius: 32,
          //       color: Colors.black.withOpacity(0.1))
          //]
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(width: 5),
            Expanded(
                child: TextField(
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              controller: _controller,
              onChanged: (value) {
                if (value.trim().length <= 1) {
                  setState(() {
                    message = value;
                  });
                } else {
                  message = value;
                }
                if (value.endsWith('@')) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AllUserList(
                            orgId: widget.currentUserData.currentOrganizationId,
                            mentionedUser: (Mention mention) {
                              setState(() {
                                _controller.text =
                                    message + mention.mentionedUserName;
                              });
                              message = message + mention.mentionedUserName;
                            });
                      });
                }
              },
              decoration: InputDecoration(
                  hintText: 'Type message'.tr(), border: InputBorder.none),
            )),
            IconButton(
              onPressed: message.trim().isEmpty ? null : uploadEventChat,
              icon: Icon(Icons.send),
              color: Constants.BUTTON_COLOR,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserMention(List<CurrentUserData> users,Size size){
     return Container(
       color: Colors.blue,
       height: 30,
       width: size.width*0.8,
       child: ListView.builder(
         scrollDirection: Axis.horizontal,
         itemCount: users.length,
         itemBuilder: (context,index){
           return Container(
             child: Text(Utils.getUserName(users[index].userName, users[index].userSurname))
           );
         },
       ),
     );
  }
}

class EventChatMessageTile extends StatelessWidget {
  final EventChat message;
  final bool isMe;
  final String myName;
  final List<String> otherNames;
  final String uid;
  final MyProvider provider;

  const EventChatMessageTile(
      {Key? key,
      required this.message,
      required this.isMe,
      required this.myName,
      required this.otherNames,
      required this.uid,
      required this.provider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = provider.getUserById(uid);
    final userName =
        Utils.getUserName(currentUser.userName, currentUser.userSurname);
    final url = currentUser.userUrl;

    String time = Utils.toTime(message.createdAt);
    final radius = BorderRadius.only(
      topRight: Radius.circular(5.0),
      bottomLeft: Radius.circular(10.0),
      bottomRight: Radius.circular(5.0),
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundImage: NetworkImage(url)),
          SizedBox(
            width: 5,
          ),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                  color: Constants.BACKGROUND_COLOR, borderRadius: radius),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: appTextStyle.copyWith(
                          color: isMe
                              ? Constants.CANCEL_COLOR
                              : Constants.BUTTON_COLOR),
                    ),
                    SizedBox(height: 5),
                    MarkdownBody(
                      data: _replaceMentions(message.message)
                          .replaceAll('\n', '\\\n'),
                      builders: {
                        "coloredBox": ColoredBoxMarkdownElementBuilder(
                            context, otherNames, myName),
                      },
                      inlineSyntaxes: [
                        ColoredBoxInlineSyntax(),
                      ],
                      styleSheet: MarkdownStyleSheet.fromTheme(
                        Theme.of(context).copyWith(
                          textTheme: Theme.of(context).textTheme.apply(
                                bodyColor: Colors.black,
                                fontSizeFactor: 1,
                              ),
                        ),
                      ),
                    ),
                    // Text(
                    //   message.message,
                    //   style: appTextStyle.copyWith(fontSize: 16),
                    // ),
                    SizedBox(height: 5),
                    Text(
                      time,
                      style: appTextStyle.copyWith(fontSize: 10),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  String _replaceMentions(String text) {
    otherNames.map((u) => u).toSet().forEach((userName) {
      text = text.replaceAll('@$userName', '[@$userName]');
    });
    return text;
  }
}
