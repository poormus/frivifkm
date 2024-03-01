/* import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../shared/constants.dart';

class Register extends StatefulWidget {
  late final Function toggleView;

  Register({required this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _obscureText = true;
  final AuthService _auth = AuthService();
  String email = "";
  String password = "";
  String userName = "";
  String userSurname = "";
  List<Organization> organizations = [];
  String error = '';
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  //show organization picker dialog
  void _showSelectOrganizationDialog() {
    setState(() {
      organizations.clear();
    });
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return OrganizationPicker(
              onChanged: (_PickerChangedDetails details) {
                organizations = details.pickedOrganizations;
              },
              organizationsToBeAdded: organizations);
        }).then((dynamic value) => setState(() {
          debugPrint(value.toString());
        }));
  }

  void register() async {
    if (organizations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('add at least one organization'),
      ));
    } else {
      if (_formKey.currentState!.validate()) {
        setState(() {
          isLoading = true;
        });
        await _auth
            .registerWithEmailAndPassword(
                email, password, userName, userSurname, organizations)
            .then((onSuccess) {
          setState(() {
            isLoading = false;
          });
        }).catchError((err) {
          setState(() {
            isLoading = false;
            error = err.toString();
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height - 56;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Register'),
        elevation: 0.0,
        backgroundColor: Colors.black12,
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () {
                widget.toggleView();
              },
              icon: Icon(Icons.person),
              label: Text('sign in'))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/log_in.jpg'), fit: BoxFit.cover)),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                      hintText: 'email', icon: Icon(Icons.mail)),
                  validator: (val) =>
                      val!.isEmpty ? 'enter a valid e-mail' : null,
                  onChanged: (val) {
                    setState(() {
                      email = val;
                    });
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                      hintText: 'password', icon: Icon(Icons.lock)),
                  validator: (val) =>
                      val!.length < 6 ? 'password must be longer than 6' : null,
                  obscureText: _obscureText,
                  onChanged: (val) {
                    setState(() {
                      password = val;
                    });
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                      hintText: 'your name',
                      icon: Icon(Icons.drive_file_rename_outline)),
                  validator: (val) => val!.isEmpty && val.length <= 6
                      ? 'user name must be longer than 6 character'
                      : null,
                  onChanged: (val) {
                    setState(() {
                      userName = val;
                    });
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                      hintText: 'your surname',
                      icon: Icon(Icons.drive_file_rename_outline)),
                  validator: (val) => val!.isEmpty && val.length <= 6
                      ? 'surname must be longer than 6 character'
                      : null,
                  onChanged: (val) {
                    setState(() {
                      userSurname = val;
                    });
                  },
                ),
                TextButton(
                    style: TextButton.styleFrom(
                        primary: Colors.blue,
                        textStyle: const TextStyle(fontSize: 20)),
                    onPressed: _showSelectOrganizationDialog,
                    child: new Text('select organization')),
                SizedBox(height: 10),
                Container(
                  height: 100,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: organizations.length,
                      itemBuilder: (context, index) {
                        return organizationListHor(
                          organizations[index],
                        );
                      }),
                ),
                SizedBox(height: 10),
                ElevatedCustomButton(
                    text: 'register', press: register, color: Colors.blue),
                SizedBox(height: 12.0),
                Container(
                  child: isLoading ? CircularProgressIndicator() : null,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget organizationListHor(Organization organization) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(organization.organizationUrl)),
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(75.0)),
              boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black)]),
        ),
        Positioned(
            top: 0,
            right: 0,
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white)),
              child: Center(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      organizations.remove(organization);
                    });
                  },
                ),
              ),
            ))
      ],
    );
  }
}

class OrganizationPicker extends StatefulWidget {
  final _PickerChanged onChanged;
  final List<Organization> organizationsToBeAdded;

  @override
  _OrganizationPickerState createState() => _OrganizationPickerState();

  const OrganizationPicker({
    required this.onChanged,
    required this.organizationsToBeAdded,
  });
}

class _OrganizationPickerState extends State<OrganizationPicker> {
  final authService = AuthService();

  void dismissDialog() {
    setState(() {
      widget.onChanged(_PickerChangedDetails(
          pickedOrganizations: widget.organizationsToBeAdded));
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      // When task is over, close the dialog
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Theme(
      data: ThemeData.light(),
      child: AlertDialog(
        content: Container(
          height: size.height * 0.45,
          child: StreamBuilder<List<Organization>>(
            stream: authService.allOrganizations(),
            builder: (context, snapShot) {
              var organizations = snapShot.data;
              if (snapShot.hasData) {
                if (snapShot.data!.length == 0) {
                  return Center(child: Text('no companies added'));
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text('Available organizations'),
                      Divider(height: 2,thickness:2,color: Colors.black,),
                      Container(
                        height: 200,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapShot.data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return OrganizationTile(
                                  organization: organizations![index],
                                  organizations: widget.organizationsToBeAdded);
                            }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedCustomButton(
                              text: "Add",
                              press: dismissDialog,
                              color: Colors.amber),
                        ],
                      ),
                    ],
                  );
                }
              } else if (snapShot.hasError) {
                return Center(child: Text(snapShot.error.toString()));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
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
    required this.organization,
    required this.organizations,
  });
}

class _OrganizationTileState extends State<OrganizationTile> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
          backgroundImage: NetworkImage(widget.organization.organizationUrl)),
      title: Text(widget.organization.organizationName,maxLines: 1,overflow: TextOverflow.ellipsis),
      trailing: isTapped ? Icon(Icons.check_circle) : null,
      onTap: () {
        setState(() {
          isTapped = !isTapped;
        });
        if (isTapped) {
          if (!widget.organizations.contains(widget.organization)) {
            widget.organizations.add(widget.organization);
          }
        } else {
          if (widget.organizations.contains(widget.organization)) {
            widget.organizations.remove(widget.organization);
          }
        }
      },
    );
  }
}

/// Signature for callback which reports the picker value changed
typedef _PickerChanged = void Function(
    _PickerChangedDetails pickerChangedDetails);

/// Details for the [_PickerChanged].
class _PickerChangedDetails {
  final List<Organization> pickedOrganizations;

  const _PickerChangedDetails({
    required this.pickedOrganizations,
  });
}
 */