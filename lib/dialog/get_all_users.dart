
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class AllUserList extends StatelessWidget {
  final String orgId;
  final MentionedUser mentionedUser;
  const AllUserList({Key? key, required this.orgId, required this.mentionedUser}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<MyProvider>(context);
    final size = MediaQuery.of(context).size;
    final userList=provider.getCurrentOrganizationUserList(orgId);
    return  Theme(
      data: ThemeData.light(),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(24),
          ),
        ),
        backgroundColor: Constants.BACKGROUND_COLOR,
        child: Container(
            height: size.height * 0.30,
            width: size.width * 0.40,
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: size.height*0.30,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: userList.length,
                          itemBuilder: (_, index) {
                            return buildUserTile(userList[index],context);
                            // return SelectUserTile(
                            //     currentUserData: userList[index],
                            //     userList: allUserData,
                            //     clickCounter: clickCounter);
                          }),
                    ),
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

  Widget buildUserTile(CurrentUserData currentUserData,BuildContext context){
    final String userName=Utils.getUserName(currentUserData.userName, currentUserData.userSurname);
    return ListTile(
        leading: CircleAvatar(
            backgroundImage:
            NetworkImage(currentUserData.userUrl)),
        title: Text(userName),
      onTap: (){
          mentionedUser(Mention(mentionedUserName: userName));
          Navigator.pop(context);
      },
    );
  }
}

class Mention {
  final String mentionedUserName;

  const Mention({
    required this.mentionedUserName,
  });
}

typedef MentionedUser = void Function(Mention mention);
