import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/components/text_field.dart';
import 'package:firebase_calendar/models/group_message.dart';
import 'package:firebase_calendar/models/message.dart';
import 'package:firebase_calendar/services/messages_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditDirectMessageBottomSheet extends StatelessWidget {
  final String senderOrgId;
  final Message message;
  final String roomId;
  final MessageService service = MessageService();

   EditDirectMessageBottomSheet(
      {Key? key, required this.message, required this.roomId, required this.senderOrgId})
      : super(key: key);

  Future deleteMessage(BuildContext context) async {
    service.updateDirectMessage(roomId, message.messageId, 'Deleted',senderOrgId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = Container();
    widget = buildTextMessageEditWidget(context);
    return Container(height: 112, child: widget);
  }

  Widget buildTextMessageEditWidget(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            deleteMessage(context);
          },
          leading: Icon(
            Icons.delete,
            color: Constants.CANCEL_COLOR,
          ),
          title: Text('Delete'.tr()),
        ),
        ListTile(
          onTap: (){
            showDialog(context: context, builder: (context){
              return UpdateTextMessage(roomId:roomId ,message:message.message ,messageId: message.messageId,senderOrgId: senderOrgId,);
            });
          },
          leading: Icon(
            Icons.edit,
            color: Constants.CANCEL_COLOR,
          ),
          title: Text('Edit'.tr()),
        )
      ],
    );
  }


}

class UpdateTextMessage extends StatelessWidget {
  final String messageId;
  final String message;
  final String roomId;
  final String senderOrgId;
  final service=MessageService();
  UpdateTextMessage(
      {Key? key,
      required this.messageId,
      required this.message,
      required this.roomId, required this.senderOrgId})
      : super(key: key);


  String messageToBeSent='';

  @override
  Widget build(BuildContext context) {
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
            height: 160,
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: 20),
                    Container(
                        width: size.width * 0.75,
                        child: TextFormField(
                          initialValue: message,
                          textCapitalization: TextCapitalization.sentences,
                          minLines: 1,
                          maxLines: 2,
                          textInputAction: TextInputAction.newline,
                          onChanged: (value) => messageToBeSent=value,
                          decoration: InputDecoration(
                              hintText: 'Type message'.tr(), border: UnderlineInputBorder(
                          )),
                        )
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedCustomButton(
                            text: 'Update'.tr(),
                            press: () {
                              if(messageToBeSent.trim().isEmpty){
                                Utils.showToastWithoutContext('Message empty/not changed'.tr());
                                return;
                              }else{
                                service.updateDirectMessage(roomId,messageId,messageToBeSent,senderOrgId);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            },
                            color: Constants.BUTTON_COLOR)
                      ],
                    )
                  ],
                ),
                Align(
                  // These values are based on trial & error method
                  alignment: Alignment(1.1, -1.1),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
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
}
