import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/group_message.dart';
import 'package:firebase_calendar/services/messages_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ReplyDialog extends StatefulWidget {
  final GroupMessage messageToReply;
  final String channelId;
  final String senderId;
  final String senderName;
  const ReplyDialog({Key? key, required this.messageToReply, required this.channelId,
    required this.senderId, required this.senderName}) : super(key: key);

  @override
  State<ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<ReplyDialog> {
  final _controller = TextEditingController();
  String message = '';
  final messageService=MessageService();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if(widget.messageToReply.messageType=='photo'){
      return Dialog(
        child: Container(
          height: 170,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  width: size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Constants.CONTAINER_COLOR),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      VerticalDivider(
                          thickness: 5, color: Constants.CANCEL_COLOR),
                      ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          child: CachedNetworkImage(
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            imageUrl: widget.messageToReply.message,
                            placeholder: (context, url) =>
                                Align(child: new CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                            new Icon(Icons.error),
                          )),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              chatInputWidget(context)
            ],
          ),
        ),
      );
    }
    else return Dialog(
      child: Container(
        height: 170,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                width: size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Constants.CONTAINER_COLOR),
                child: Row(
                  children: [
                    VerticalDivider(thickness: 5, color: Constants.CANCEL_COLOR),
                    Container(
                        width: size.width*0.6,
                        height: 60,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(widget.messageToReply.message,maxLines: 2,overflow: TextOverflow.ellipsis),
                        )),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            chatInputWidget(context)
          ],
        ),
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
          // ]
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(width: 5),
            Expanded(
                child: TextField(
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 2,
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
              },
              decoration: InputDecoration(
                  hintText: 'Reply'.tr(), border: InputBorder.none),
            )),
            IconButton(
              onPressed: message.trim().isEmpty ? null : sendGroupMessageReply,
              icon: Icon(Icons.send),
              color: Constants.BUTTON_COLOR,
            ),
          ],
        ),
      ),
    );
  }

  Future sendGroupMessageReply() async{
    Navigator.pop(context);
    messageService.sendReply(widget.channelId,widget.senderId,
        widget.senderName,message,widget.messageToReply.message,widget.messageToReply.messageType);
  }
}
