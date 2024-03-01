import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';

class ChangeOrgDialog extends StatelessWidget {
  final CurrentUserData currentUserData;
  final AuthService _auth = AuthService();
   ChangeOrgDialog({Key? key, required this.currentUserData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userOrgs=currentUserData.userOrganizations;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(24),
        ),
      ),
      backgroundColor: Constants.BACKGROUND_COLOR,
      child: Container(
          height: size.height * 0.4,
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Organizations'.tr(),style: TextStyle(fontSize: 20),),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height:size.height * 0.30 ,
                      child: ListView.builder(
                          itemCount:userOrgs.length ,
                          itemBuilder: (context,index){
                            return ListTile(
                              selected: currentUserData.currentOrganizationId==userOrgs[index].organizationId,
                              selectedColor: Constants.CANCEL_COLOR,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                  imageUrl: userOrgs[index].organizationUrl,
                                  placeholder: (context, url) =>
                                      Center(child: new CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => new Icon(Icons.error),
                                ),
                              ),
                              title: Text(userOrgs[index].organizationName),
                              onTap: (){
                                if (userOrgs[index].organizationId == currentUserData.currentOrganizationId) {
                                  return;
                                }
                                _auth.updateCurOrganizationForUser(
                                    currentUserData.uid, userOrgs[index].organizationId, context);
                              },
                            );
                          }),
                    ),
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
    );
  }

}
