import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/primary_button.dart';
import 'package:firebase_calendar/dialog/blurry_dialog.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_with_title.dart';
import 'package:firebase_calendar/dialog/select_image_dialog.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/screens/admin_panel/update_org_info.dart';
import 'package:firebase_calendar/services/admin_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../anim/slide_in_right.dart';
import '../../shared/utils.dart';

class ManageOrganization extends StatefulWidget {
  final CurrentUserData currentUserData;

  const ManageOrganization({Key? key, required this.currentUserData})
      : super(key: key);

  @override
  _ManageOrganizationState createState() => _ManageOrganizationState();
}

class _ManageOrganizationState extends State<ManageOrganization> {
  final key = GlobalKey<FormState>();
  final adminService = AdminServices();

  String _image1 = "";
  final picker = ImagePicker();

  bool isNameUpdating = false;
  bool isPicUpdating = false;

  @override
  void initState() {
    super.initState();
  }

  //we also need to update every user's organization url  who has this organization
  Future pickPicture(MyProvider provider) async {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SelectImageSourceDialog(
              selectedImage: (onImageSelected onSelected) async {
            setState(() {
              isPicUpdating = true;
            });
            adminService
                .updateOrgPic(widget.currentUserData.currentOrganizationId,
                    onSelected.imageFile, provider)
                .then((onSuccess) {
              setState(() {
                isPicUpdating = false;
              });
            }).catchError((onError) {
              setState(() {
                isPicUpdating = false;
              });
            });
          });
        });
  }

  Future handleEmail(Organization organization) async {
    showDialog(
        context: context,
        builder: (context) {
          return BlurryDialogWithTitle(
              content:
                  'It may take up to 72 hours to complete your request, and is valid only for voluntary organizations'
                      .tr(),
              title: 'Apply for verification?'.tr(),
              continueCallBack: () {
                adminService.sendApprovalRequest(organization);
                Navigator.pop(context);
              });
        });
  }

  String buildMailBody(Organization organization) {
    return 'Organization name:${organization.organizationName}'
        "\n"
        'Organization id:${organization.organizationId}'
        "\n";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<MyProvider>(context);
    return StreamBuilder<Organization>(
      stream: adminService
          .getOrganization(widget.currentUserData.currentOrganizationId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final organization = snapshot.data!;
          return _buildOrgInfo(organization, provider, size);
        } else {
          return noDataWidget(null, true);
        }
      },
    );
  }

  Widget _buildOrgInfo(
      Organization organization, MyProvider provider, Size size) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.65,
                height: MediaQuery.of(context).size.height * 0.35,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.height * 0.3,
                        imageUrl: organization.organizationUrl,
                        placeholder: (context, url) =>
                            Align(child: new CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            new Icon(Icons.error),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        boxShadow: [BoxShadow(blurRadius: 10)],
                        borderRadius: BorderRadius.circular(30),
                        color: Constants.BACKGROUND_COLOR),
                    child: IconButton(
                        onPressed: () {
                          pickPicture(provider);
                        },
                        icon: Icon(Icons.edit, color: Constants.BUTTON_COLOR))),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        boxShadow: [BoxShadow(blurRadius: 10)],
                        borderRadius: BorderRadius.circular(30),
                        color: Constants.BACKGROUND_COLOR),
                    child: IconButton(
                        onPressed: organization.isApproved
                            ? () {}
                            : () {
                                handleEmail(organization);
                              },
                        icon: Icon(
                            organization.isApproved
                                ? Icons.check
                                : Icons.question_mark,
                            color: Constants.BUTTON_COLOR))),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(organization.organizationName,
              style: appTextStyle.copyWith(
                  fontWeight: FontWeight.bold, fontSize: 20)),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PrimaryButton(
                  text: 'Go premium'.tr(),
                  press: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return BlurryDialog(
                              title: 'About premium'.tr(),
                              content:
                                  'Please visit friviapp.com to see premium packages'
                                      .tr(),
                              continueCallBack: () => Navigator.pop(context));
                        });
                  },
                  color: Constants.CANCEL_COLOR),
              PrimaryButton(
                  text: 'Update'.tr(),
                  press: () {
                    Navigator.push(
                        context,
                        SlideInRight(
                            UpdateOrgInfo(organization: organization)));
                  },
                  color: Constants.BUTTON_COLOR),
            ],
          ),
          SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(Icons.link),
              title: Text('Share your invite code'.tr(),
                  style: appTextStyle.copyWith(fontSize: 20)),
              subtitle: Text(
                  'Share your organization code with someone you want to join your organization'
                      .tr(),
                  style: appTextStyle.copyWith(fontSize: 12)),
              onTap: () => handleSharing(organization),
            ),
          ),
          Container(
              child: isNameUpdating || isPicUpdating
                  ? CircularProgressIndicator()
                  : null)
        ],
      ),
    );
  }

  Future<String> handleDynamicLink(String orgName, String orgId) async {
    return '${orgId}';
  }

  handleSharing(Organization organization) {
    Utils.showSnackBar(context, 'Generating code'.tr());
    handleDynamicLink(
            organization.organizationName, organization.organizationId)
        .then((value) {
      final shareText =
          '${Utils.getUserName(widget.currentUserData.userName, widget.currentUserData.userSurname)} wants you to join ${organization.organizationName} use following code to join ${widget.currentUserData.currentOrganizationId} or use the link $value';
      Share.share(shareText);
    });
  }
}
