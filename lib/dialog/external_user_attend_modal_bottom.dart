import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/extensions/extensions.dart';
import 'package:firebase_calendar/services/event_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/my_provider.dart';

class ExternalUserAttendEvent extends StatefulWidget {
  final String guestId;
  final String eventId;

  ExternalUserAttendEvent({Key? key, required this.guestId, required this.eventId}) : super(key: key);

  @override
  State<ExternalUserAttendEvent> createState() => _ExternalUserAttendEventState();
}

class _ExternalUserAttendEventState extends State<ExternalUserAttendEvent> {
  final service = EventServices();

  final nameController=TextEditingController();

  final surnameController=TextEditingController();

  final emailController=TextEditingController();

  Future attendAsGuest(BuildContext context,MyProvider provider) async{
    if(nameController.text.toString().trim().isEmpty){
      Utils.showToastWithoutContext('Name can not be empty'.tr());
      return;
    }else if(!emailController.text.toString().trim().replaceAll(" ", '').isValidEmail()){
      Utils.showToastWithoutContext('E mail is empty or invalid');
      return;
    }
    service.updateExternalUserList(widget.eventId,widget.guestId,nameController.text.toString(),
        surnameController.text.toString(),emailController.text.toString());
    provider.hasUserClickedAttend=true;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    final provider=Provider.of<MyProvider>(context);
    return body(size,provider);
  }

  Widget body(Size size,MyProvider provider){
    return SingleChildScrollView(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(24),
          ),
        ),
        backgroundColor: Constants.BACKGROUND_COLOR,
        child: Container(
          width:size.width ,
            height: 250,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    child:Column(
                      children: [
                        SizedBox(height: 20),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              hintStyle: TextStyle(color: Colors.grey[800]),
                              hintText: "Name".tr(),
                              fillColor: Colors.white70),
                        ),
                        SizedBox(height: 5),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              hintStyle: TextStyle(color: Colors.grey[800]),
                              hintText: "E-mail".tr(),
                              fillColor: Colors.white70),
                        ),
                        SizedBox(height: 5),
                        Column(
                          children: [
                            Text('Your name and email will be visible'.tr()),
                            Text('to organization members'.tr())
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [

                            ElevatedCustomButton(text: 'Cancel'.tr(), press: (){
                              Navigator.pop(context);
                            }, color: Constants.CANCEL_COLOR),
                            ElevatedCustomButton(text: 'Attend'.tr(), press: (){
                              attendAsGuest(context,provider);
                            }, color: Constants.BUTTON_COLOR),
                          ],
                        )
                      ],
                    ),
                  ),
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
            )

        ),
      ),
    );
  }
}
