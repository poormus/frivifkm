import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

class SelectNewOrganization extends StatefulWidget {
  final String uid;
  final CurrentUserData currentUserData;
  const SelectNewOrganization({Key? key, required this.uid, required this.currentUserData}) : super(key: key);

  @override
  _SelectNewOrganizationState createState() => _SelectNewOrganizationState();
}

class _SelectNewOrganizationState extends State<SelectNewOrganization> {
  final authService = AuthService();
  final List<Organization> orgList = [];
  String query = '';
  late Stream<List<Organization>> getOrganizations;

  @override
  void initState() {
    getOrganizations=authService.allOrganizations();
    super.initState();
  }
  void dismissDialog() {
    Future.delayed(const Duration(milliseconds: 200), () {
      // When task is over, close the dialog
      Navigator.pop(context);
    });
  }

  List<Organization> _filterOrganizations(List<Organization> organisations) {
    return organisations
        .where((element) => element.organizationName
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  }

  updateUserOrganizations() {
    if (orgList.isEmpty) {
      Utils.showToast(context, 'You have not selected any organizations'.tr());
    } else {
      authService.updateUserOrganizationList(widget.uid, orgList);
      Navigator.pop(context);
    }
  }

  onTap(MyProvider provider, Organization organization, int index) {
    bool check = isInTheList(provider, organization);
    if (check) {
      setState(() {
        provider.selectedOrganizations.removeWhere(
            (element) => element.organizationId == organization.organizationId);
      });
      orgList.removeWhere(
          (element) => element.organizationId == organization.organizationId);
      print('remove called');
      print(orgList.length);
      print(provider.selectedOrganizations.length);
    } else {
      setState(() {
        provider.selectedOrganizations.add(organization);
      });
      orgList.add(organization);
      print('add called');
      print(provider.selectedOrganizations.length);
      print(orgList.length);
    }
  }

  bool isInTheList(MyProvider provider, Organization organization) {
    var isInTheList = false;
    for (var index = 0;
        index < provider.selectedOrganizations.length;
        index++) {
      if (provider.selectedOrganizations[index].organizationId ==
          organization.organizationId) {
        isInTheList = true;
        break;
      }
    }
    return isInTheList;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<MyProvider>(context, listen: true);
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
            height: size.height * 0.50,
            width: size.width * 0.40,
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: textInputDecoration.copyWith(
                            prefixIcon: Icon(
                              Icons.search,
                              color: Constants.BACKGROUND_COLOR,
                            ),
                            hintText: 'Search'.tr()),
                        onChanged: (val) {
                          setState(() {
                            query = val;
                          });
                        },
                      ),
                    ),
                    CustomTextButton(
                        width: size.width * 0.6,
                        height: 35,
                        press: updateUserOrganizations,
                        text: 'Add organizations'.tr(),
                        textColor: Constants.BUTTON_COLOR,
                        containerColor: Colors.white),
                    StreamBuilder<List<Organization>>(
                      stream: getOrganizations,
                      builder: (context, snapShot) {
                        if (snapShot.hasData) {
                          if (snapShot.data!.length == 0) {
                            return Center(child: Text(' '));
                          } else {
                            final organizations =
                                _filterOrganizations(snapShot.data!);
                            return Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: organizations.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return OrgTile(
                                      currentUserData: widget.currentUserData,
                                      onTap: () {
                                        onTap(provider, organizations[index],
                                            index);
                                      },
                                      provider: provider,
                                      organization: organizations[index],
                                    );
                                  }),
                            );
                          }
                        } else if (snapShot.hasError) {
                          return Center(child: Text(snapShot.error.toString()));
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
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
}

class OrgTile extends StatelessWidget {
  final CurrentUserData currentUserData;
  final Organization organization;
  final VoidCallback onTap;
  final MyProvider provider;

  const OrgTile(
      {Key? key,
        required this.currentUserData,
      required this.organization,
      required this.onTap,
      required this.provider})
      : super(key: key);

  bool isUserApprovedByOrganization(){
    bool isApproved=false;
    for(var i=0; i<currentUserData.userOrganizations.length; i++){
      if(currentUserData.userOrganizations[i].organizationId==organization.organizationId){
       isApproved= currentUserData.userOrganizations[i].isApproved;
       break;
      }
    }
    return isApproved;
  }

  @override
  Widget build(BuildContext context) {
    var isInList = context.select<MyProvider, bool>((provider) {
      var isInTheList = false;
      for (var index = 0;
          index < provider.selectedOrganizations.length;
          index++) {
        if (provider.selectedOrganizations[index].organizationId ==
            organization.organizationId) {
          isInTheList = true;
          break;
        }
      }
      return isInTheList;
    });

    var isOrganizationJoined = context.select<MyProvider, bool>((provider) {
      var isInTheList = false;
      for (var index = 0;
          index < provider.alreadyJoinedOrganizations.length;
          index++) {
        if (provider.alreadyJoinedOrganizations[index] ==
            organization.organizationId) {
          isInTheList = true;
          break;
        }
      }
      return isInTheList;
    });


    if(organization.blockedUsers.contains(currentUserData.uid)){
      return ListTile(
          leading: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(organization.organizationUrl)),
          title: Text(organization.organizationName,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('This organization blocked you'.tr()),
      );
    }else if(isOrganizationJoined){
      return ListTile(
          leading: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(organization.organizationUrl)),
          title: Text(organization.organizationName,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Icon(
            Icons.check_circle,
            color: Constants.BUTTON_COLOR,
          ),
        subtitle: isUserApprovedByOrganization()?null:Text('Pending approval'.tr()),
      );
    }else {
      return  ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.white,
              backgroundImage: NetworkImage(organization.organizationUrl)),
          title: Text(organization.organizationName,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: isInList
              ? Icon(
            Icons.check_circle,
            color: Constants.BUTTON_COLOR,
          )
              : null,
          onTap: onTap);
    }

  }
}
// return isOrganizationJoined
// ? Container()
//     : ListTile(
// leading: CircleAvatar(
// backgroundImage: NetworkImage(organization.organizationUrl)),
// title: Text(organization.organizationName,
// maxLines: 1, overflow: TextOverflow.ellipsis),
// trailing: isInList
// ? Icon(
// Icons.check_circle,
// color: Constants.BUTTON_COLOR,
// )
// : null,
// onTap: onTap);
