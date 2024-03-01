import 'dart:async';

import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/sized_box.dart';
import 'package:firebase_calendar/dialog/edit_direct_message.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/message.dart';
import 'package:firebase_calendar/services/count_service.dart';
import 'package:firebase_calendar/services/messages_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/utils.dart';

class ChatScreen extends StatefulWidget {
  final String senderOrgId;
  final CurrentUserData currentUserData;
  final String chattedUserUid;
  final String roomName;
  final String url;
  final String userName;

  const ChatScreen({
    Key? key,
    required this.currentUserData,
    required this.roomName,
    required this.chattedUserUid, required this.url, required this.userName, required this.senderOrgId,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with  WidgetsBindingObserver{
  final messageService = MessageService();
  late CountService countService;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String message = '';
  String lastMessage = 'last message';

  late Stream<List<Message>> getMessages;

  Future sendMessage() async {


    ///sender id is saved as url pay attention in case of an error...
    String userName = widget.currentUserData.userName;
    await messageService.uploadMessage(widget.roomName, message,
        widget.currentUserData.uid, userName, widget.chattedUserUid,widget.senderOrgId,widget.currentUserData.userUrl);
    _controller.clear();
    lastMessage = message;
    setState(() {
      message = '';
    });
    Timer(
        Duration(milliseconds: 300),
        () => _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent));
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scrollController.dispose();
    if (lastMessage != 'last message') {
      messageService.uploadStartedChat(
          widget.currentUserData.uid,
          widget.currentUserData.userUrl,
          widget.currentUserData.userName,
          widget.roomName,
          widget.chattedUserUid,
          lastMessage,
          widget.senderOrgId,countService);
    }
    super.dispose();
  }

  @override
  void initState() {

    countService=CountService(organizationId: widget.senderOrgId);
    countService.init();

    messageService.setUnseenMessageToZero(
        widget.currentUserData.uid, widget.roomName,widget.currentUserData.currentOrganizationId,countService);

    getMessages=messageService.getMessages(widget.roomName,widget.senderOrgId);
    Timer(
        Duration(milliseconds: 300),
        () => _scrollController.hasClients
            ? _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent)
            : null);

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
      // --
        print('Resumed');
        break;
      case AppLifecycleState.inactive:
      // --
        print('Inactive');
        break;
      case AppLifecycleState.paused:
        if (lastMessage != 'last message') {
          messageService.uploadStartedChat(
              widget.currentUserData.uid,
              widget.currentUserData.userUrl,
              widget.currentUserData.userName,
              widget.roomName,
              widget.chattedUserUid,
              lastMessage,
              widget.senderOrgId,countService);
        }
        print('Paused');
        break;
      case AppLifecycleState.detached:
      // --
        print('Detached');
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<MyProvider>(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Constants.BACKGROUND_COLOR,
        appBar: buildAppBar(),
        body: Container(
          height: size.height - 80,
          width: size.width,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          child: StreamBuilder<List<Message>>(
            stream: getMessages,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.length == 0) {
                  return Column(
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
                      chatInputWidget(context),
                      SizedBoxWidget()
                    ],
                  );
                } else {
                  final messages = snapshot.data;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController
                          .jumpTo(_scrollController.position.maxScrollExtent);
                    } else {
                      setState(() => null);
                    }
                  });
                  return Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              itemCount: messages!.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                final bool isNew = !message.isRead;

                                final bool toMe =
                                    message.idUser == widget.chattedUserUid;
                                if (isNew && toMe) {
                                  messageService.markAsRead(
                                      widget.roomName, message.messageId,widget.senderOrgId);
                                }
                                final bool isMe =
                                    message.idUser == widget.currentUserData.uid;
                                return MessageTile(message: message, isMe: isMe,roomId: widget.roomName,senderOrgId: widget.senderOrgId,);
                              }),
                        ),
                      ),
                      chatInputWidget(context),
                      SizedBoxWidget()
                    ],
                  );
                }
              } else if (snapshot.hasError) {
                return noDataWidget(snapshot.error.toString(), false);
              } else {
                return noDataWidget(null, true);
              }
            },
          ),
        ),
      ),
    );
  }

  //appbar build function
  PreferredSizeWidget buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(80),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: AppBar(
            elevation: 0,
            backgroundColor: Constants.BACKGROUND_COLOR,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                BackButton(color: Colors.black),
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.url),
                ),
                SizedBox(width: 10),
                Text(
                    '${Utils.getUserName(widget.userName,'')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, color: Colors.black))
              ],
            )),
      ),
    );
  }

  ///bottom send message bar
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
                if(value.trim().length<=1){
                  setState(() {
                    message = value;
                  });
                }else {
                  message=value;
                }
              },
              decoration: InputDecoration(
                  hintText: 'Type message'.tr(), border: InputBorder.none),
            )),
            IconButton(
              onPressed: message.trim().isEmpty ? null : sendMessage,
              icon: Icon(Icons.send),
              color: Constants.BUTTON_COLOR,
            ),
          ],
        ),
      ),
    );
  }
}

//individual message tile
class MessageTile extends StatelessWidget {
  final Message message;
  final bool isMe;
  final roomId;
  final String senderOrgId;
  const MessageTile({Key? key, required this.message, required this.isMe,required this.roomId, required this.senderOrgId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String time = Utils.toTime(message.createdAt);
    final radius = !isMe
        ? BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          );
    return GestureDetector(
      onLongPress: (){
        isMe && message.message!='Deleted'?showModalBottomSheet(context: context, builder: (context){
          return EditDirectMessageBottomSheet(message: message,roomId: roomId,senderOrgId: senderOrgId,);
        }):null;
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                      color: isMe
                          ? Constants.BUTTON_COLOR
                          : Constants.BACKGROUND_COLOR,
                      borderRadius: radius),
                  child: Linkify(
                    linkStyle: TextStyle(color: isMe ? Colors.white : Colors.black87),
                    onOpen: (link) async {
                      if (await canLaunch(link.url)) {
                        await launch(link.url);
                      } else {
                        throw 'Could not launch';
                      }
                    },
                    text: message.message,
                    style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                    maxLines: 10,
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  time,
                  style: appTextStyle.copyWith(fontSize: 12),
                ),
              ),
              if (isMe) ...[
                message.isRead
                    ? Icon(
                        Icons.done_all,
                        color: Constants.CANCEL_COLOR,
                        size: 18,
                      )
                    : Icon(Icons.done_all, size: 18)
              ]
            ],
          )
        ],
      ),
    );
  }
}
