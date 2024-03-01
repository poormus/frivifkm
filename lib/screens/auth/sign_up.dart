import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/long_button.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/components/text_field.dart';
import 'package:firebase_calendar/models/api_model.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../../api.dart';

class SignUpApp extends StatefulWidget {

  final AuthService authService;

  const SignUpApp({Key? key, required this.authService}) : super(key: key);

  @override
  _SignUpAppState createState() => _SignUpAppState();
}

class _SignUpAppState extends State<SignUpApp> {


  String emailSignUp = '';
  String passwordSignUp = '';
  String nameSignUp = '';
  String surnameSignUp = '';
  String error = '';
  bool isLoading = false;


  bool isAgeChecked=false;

  updateUi(bool loading){
    setState(() {
      isLoading=loading;
    });
  }
  void register(MyProvider myProvider) async {

    if (myProvider.organizations.isEmpty) {
      Utils.showSnackBar(context, 'Select at least one organization'.tr());
    }else if(!isAgeChecked){
      Utils.showSnackBar(context, 'Confirm that you are older than 16'.tr());
    } else {
      if (Utils.validateRegister(
          emailSignUp.trim().replaceAll(" ", ""), passwordSignUp, nameSignUp, surnameSignUp, context)) {
        updateUi(true);
        await widget.authService
            .registerWithEmailAndPassword(emailSignUp.trim().replaceAll(" ", ""), passwordSignUp,
            nameSignUp, surnameSignUp, myProvider.organizations)
            .then((onSuccess) {
          updateUi(false);
          Navigator.pushReplacementNamed(context, '/home');
        }).catchError((err) {
          error = err.toString();
          Utils.showSnackBar(context, error);
          updateUi(false);
        }).onError((error, stackTrace) {
          updateUi(false);
        });
      }
    }
  }

  //show organization picker dialog
  void _showSelectOrganizationDialog(MyProvider myProvider) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return OrganizationPicker(organizationsToBeAdded: myProvider.organizations);
        }).then((dynamic value) => setState((){}));
  }






  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    final myProvider = Provider.of<MyProvider>(context, listen: false);
    return BaseScaffold(appBarName: 'Register'.tr(), body: buildBody(size, myProvider, context), shouldScroll: true);
    // return  buildBody(size, myProvider, context);
  }

  Widget buildBody(Size size, MyProvider myProvider, BuildContext context) {
    return SingleChildScrollView(
      child: Container(
      padding: EdgeInsets.all(12),
      width: size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFieldInput(
              autoCorrect: false,
              textInputType: TextInputType.emailAddress,
              hintText: Strings.EMAIL.tr(),
              onChangeValue: (s) => emailSignUp = s,
              isDone: false,
              shouldObscureText: false),
          SizedBox(height: 6),
          TextFieldInput(
              textInputType: TextInputType.visiblePassword,
              hintText: Strings.PASSWORD.tr(),
              onChangeValue: (s) => passwordSignUp = s,
              isDone: false,
              shouldObscureText: true),
          SizedBox(height: 6),
          TextFieldInput(
              hintText: Strings.USER_NAME.tr(),
              onChangeValue: (s) => nameSignUp = s,
              isDone: false,
              shouldObscureText: false),
          SizedBox(height: 6),
          TextFieldInput(
              hintText: Strings.USER_SURNAME.tr(),
              onChangeValue: (s) => surnameSignUp = s,
              isDone: true,
              shouldObscureText: false),
          SizedBox(height: 10),
          CustomTextButton(
              width: size.width,
              height: 35,
              text: Strings.CHOOSE_ORGANIZATION.tr(),
              textColor: Constants.BUTTON_COLOR,
              containerColor: Constants.BACKGROUND_COLOR,
              press: () {
                _showSelectOrganizationDialog(myProvider);
              }),
          SizedBox(height: 10),
          if (myProvider.organizations.length == 0)
            ...[]
          else ...[
            Container(
              height: 40,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: myProvider.organizations.length,
                  itemBuilder: (context, index) {
                    return organizationListHor(
                        myProvider.organizations[index], myProvider);
                  }),
            ),
          ],
          SizedBox(height: 10),

          ListTile(
            leading: Checkbox(
              activeColor: Constants.CANCEL_COLOR,
              value: isAgeChecked,
              onChanged: (bool? value) {
                setState(() {
                  isAgeChecked=value!;
                });
              },
            ),
              title: Text('I accept that I am older than 16'.tr()),
              subtitle:GestureDetector(
                onTap:(){
                  Utils.showPoliciesDialog(context);
                },
                child: Text('I agree to the Terms and Conditions and Privacy Policy.'.tr(),
                    style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blueAccent)),
              )
          ),

          SizedBox(height: 10),
          CustomTextButton(
              width: size.width,
              height: 35,
              text: Strings.SIGN_UP.tr(),
              textColor: Colors.white,
              containerColor: Constants.BUTTON_COLOR,
              press: isLoading?(){}:() {
                register(myProvider);
              }),
          SizedBox(height: 8),
          Container(
              width: size.width * 0.5,
              child: isLoading ? LinearProgressIndicator() : null)
        ],
      ),
  ),
    );
  }

  Widget organizationListHor(Organization organization, MyProvider myProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(organization.organizationUrl)),
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(75.0)),
            boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black)]),
        child: Stack(
          children: [
            Align(
                alignment: Alignment(1.4, -1.7),
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                      color: Constants.BACKGROUND_COLOR,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.cancel,
                      color: Constants.CANCEL_COLOR,
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        myProvider.organizations.remove(organization);
                      });
                    },
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class OrganizationPicker extends StatefulWidget {
  final List<Organization> organizationsToBeAdded;

  @override
  _OrganizationPickerState createState() => _OrganizationPickerState();

  const OrganizationPicker({
    required this.organizationsToBeAdded,
  });
}


class _OrganizationPickerState extends State<OrganizationPicker> {
  final authService = AuthService();
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
    List<Organization> filteredList = [];
    filteredList = organisations
        .where((element) => element.organizationName
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
    return filteredList;
  }

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
                            hintText: Strings.SEARCH.tr()),
                        onChanged: (val) {
                          setState(() {
                            query = val;
                          });
                        },
                      ),
                    ),
                    ListTile(
                        leading: CircleAvatar(
                            backgroundColor: Constants.BUTTON_COLOR,
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            )),
                        title: Text(Strings.REGISTER_NEW_ORGANIZATION.tr()),
                        onTap: () =>
                            Navigation.navigateToRegisterOrganizationAsAnAdmin(
                                context)),
                    StreamBuilder<List<Organization>>(
                      stream: getOrganizations,
                      builder: (context, snapShot) {
                        if (snapShot.hasData) {
                          if (snapShot.data!.length == 0) {
                            return Center(child: Text(Strings.NO_ORGANIZATION_FOUND.tr(),style: appTextStyle));
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

class OrgTile extends StatelessWidget {
  final Organization organization;

  const OrgTile({Key? key, required this.organization}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isInList = context.select<MyProvider, bool>((provider) {
      var isInTheList = false;
      for (var index = 0; index < provider.organizations.length; index++) {
        if (provider.organizations[index].organizationId ==
            organization.organizationId) {
          isInTheList = true;
          break;
        }
      }
      return isInTheList;
    });

    return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(organization.organizationUrl)),
        title: Text(organization.organizationName,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: isInList
            ? Icon(
          Icons.check_circle,
          color: Constants.BUTTON_COLOR,
        )
            : null,
        onTap: isInList
            ? null
            : () {
          var provider = context.read<MyProvider>();
          provider.addOrganization(organization);
        });
  }
}
