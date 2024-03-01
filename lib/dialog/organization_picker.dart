import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class OrganizationPicker extends StatefulWidget {
  final _PickerChanged onChanged;
  final List<Organization> organizationsToBeAdded;

  @override
  _OrganizationPickerState createState() => _OrganizationPickerState();

  const OrganizationPicker({
    required this.onChanged, required this.organizationsToBeAdded,
  });
}

class _OrganizationPickerState extends State<OrganizationPicker> {
  final authService = AuthService();
  late Stream<List<Organization>> getOrganizations;
  @override
  void initState() {
    getOrganizations=authService.allOrganizations();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Theme(
      data: ThemeData.light(),
      child: StreamBuilder<List<Organization>>(
        stream: getOrganizations,
        builder: (context, snapShot) {
          var organizations=snapShot.data;
          if(snapShot.hasData){
            if(snapShot.data!.length==0){
              return AlertDialog(
                content: Container(
                  width: double.maxFinite,
                  height: size.height * 0.6,
                  child: Center(child: Text('no companies added'))
                ),
              );
            }else{
              return AlertDialog(
                content: Container(
                  width: double.maxFinite,
                  height: size.height * 0.6,
                  child: ListView.builder(
                      itemCount: snapShot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return OrganizationTile(organization: organizations![index],organizations: widget.organizationsToBeAdded);
                      }),
                ),
              );
            }
          }else if(snapShot.hasError){
            return AlertDialog(
              content: Container(
                width: double.maxFinite,
                height: size.height * 0.6,
                child: Center(child: Text(snapShot.error.toString()))
              ),
            );
          }else{
            return AlertDialog(
              content: Container(
                width: double.maxFinite,
                height: size.height * 0.6,
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}

class OrganizationTile extends StatefulWidget {

  final Organization organization;
  final List<Organization> organizations;

  @override
  _OrganizationTileState createState() => _OrganizationTileState();
  const OrganizationTile({
    required this.organization, required this.organizations,
  });
}

class _OrganizationTileState extends State<OrganizationTile> {

  bool isTapped=false;
  @override
  Widget build(BuildContext context) {
    return  ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(widget.organization.organizationUrl)),
      title: Text(widget.organization.organizationName),
      trailing: isTapped? Icon(Icons.check_circle):null,
      onTap: (){
        setState(() {
          isTapped=!isTapped;
        });
        if(isTapped){
          widget.organizations.add(widget.organization);
        }else{
          widget.organizations.remove(widget.organization);
        }
      },
    );
  }
}



/// Details for the [_PickerChanged].
class _PickerChangedDetails {
  _PickerChangedDetails({this.index = -1, this.resourceId});

  final int index;
  final Object? resourceId;
}
/// Signature for callback which reports the picker value changed
typedef _PickerChanged = void Function(
    _PickerChangedDetails pickerChangedDetails);



