import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/dialog/select_group_for_event.dart';
import 'package:firebase_calendar/models/announcement.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/announcements_service.dart';
import 'package:firebase_calendar/services/count_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddEditAnnouncement extends StatefulWidget {
  final Announcement? announcement;
  final CurrentUserData currentUserData;

  const AddEditAnnouncement(
      {Key? key, this.announcement, required this.currentUserData})
      : super(key: key);

  @override
  _AddEditAnnouncementState createState() => _AddEditAnnouncementState();
}

class _AddEditAnnouncementState extends State<AddEditAnnouncement> {
  late  AnnouncementService announcementService;
  final key = GlobalKey<FormState>();
  late String announcementTitle;
  late String announcement;
  late int priority;
  late String currentClick;
  late double priorityNumber;
  late List<String> toWho;
   late CountService countService;

  @override
  void initState() {
    announcementService=AnnouncementService();
    countService=CountService(organizationId: widget.currentUserData.currentOrganizationId);
    countService.init();
    announcement =
        widget.announcement == null ? '' : widget.announcement!.announcement;
    announcementTitle = widget.announcement == null
        ? ''
        : widget.announcement!.announcementTitle;
    priority =
        widget.announcement == null ? 1 : widget.announcement!.priority;
    switch (priority) {
      case 1:
        currentClick = 'low';
        break;
      case 2:
        currentClick = 'medium';
        break;
      case 3:
        currentClick = 'high';
        break;
    }
    toWho = widget.announcement == null ? [] : widget.announcement!.toWho;
    super.initState();
  }

  Future createOrUpdateAnnouncement(MyProvider provider) async {
    if (toWho.isEmpty) {
      Utils.showSnackBar(context, 'Select target group'.tr());
      return;
    }
    if (key.currentState!.validate()) {
      String userName = '${widget.currentUserData.userName} ${widget.currentUserData.userSurname}';
      if (widget.announcement == null) {
        await announcementService.createAnnouncement(
            announcement,
            announcementTitle,
            widget.currentUserData.currentOrganizationId,
            userName,
            priority,
            context,
            toWho,
             widget.currentUserData.uid
        );
        countService.updateAnnouncementCountOnCreateAnnouncement(provider, toWho);
      } else {
        await announcementService.updateAnnouncement(
            widget.announcement!.announcementId,
            announcement,
            announcementTitle,
            priority,
            context,
            toWho);
        countService.updateAnnouncementCountOnUpdateAnnouncement(provider, toWho, widget.announcement!.seenBy);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context);
    return BaseScaffold(
        appBarName: Strings.CREATE_ANNOUNCEMENT.tr(),
        body: buildBody(provider),
        shouldScroll: true);
    return buildScaffold(
        Strings.CREATE_ANNOUNCEMENT.tr(), context, buildBody(provider), null);
  }

  Widget buildBody(MyProvider provider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
            key: key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPopUp(),
                buildTargetList(provider),
                _buildTextFieldTitle(),
                _buildTextField(),
                SizedBox(height: 6),
                _buildFlags(),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedCustomButton(
                        text: widget.announcement != null
                            ? Strings.UPDATE_ANNOUNCEMENT.tr()
                            : Strings.PUBLISH_ANNOUNCEMENT.tr(),
                        press:()=> createOrUpdateAnnouncement(provider),
                        color: Constants.BUTTON_COLOR),
                    SizedBox(width: 10),
                  ],
                )
              ],
            )),
      ),
    );
  }

  Widget _buildTextField() {
    final maxLines = 7;
    return Container(
      margin: EdgeInsets.all(12),
      height: maxLines * 24.0,
      child: TextFormField(
        initialValue: announcement,
        textInputAction: TextInputAction.newline,
        maxLength: 250,
        inputFormatters: [
          LengthLimitingTextInputFormatter(250),
        ],
        maxLines: maxLines,
        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
          hintText: Strings.YOUR_ANNOUNCEMENT.tr(),
          fillColor: Constants.CONTAINER_COLOR,
          filled: true,
        ),
        onChanged: (val) => announcement = val,
        validator: (val) =>
            val!.isEmpty ? Strings.FIELD_CAN_NOT_BE_EMPTY.tr() : null,
      ),
    );
  }

  Widget _buildTextFieldTitle() {
    final maxLines = 3;
    return Container(
      margin: EdgeInsets.all(12),
      height: maxLines * 24.0,
      child: TextFormField(
        initialValue: announcementTitle,
        textInputAction: TextInputAction.newline,
        maxLength: 100,
        inputFormatters: [
          LengthLimitingTextInputFormatter(100),
        ],
        maxLines: maxLines,
        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
          hintText: Strings.TITLE.tr(),
          fillColor: Constants.CONTAINER_COLOR,
          filled: true,
        ),
        onChanged: (val) {
          announcementTitle = val;
        },
        validator: (val) =>
            val!.isEmpty ? Strings.FIELD_CAN_NOT_BE_EMPTY.tr() : null,
      ),
    );
  }

  Widget _buildFlags() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(Strings.SELECT_PRIORITY.tr(), style: appTextStyle),
        IconButton(
            onPressed: () {
              setState(() {
                currentClick = 'low';
              });
              priority = 1;
            },
            icon: currentClick == 'low'
                ? Icon(Icons.flag, color: Colors.green, size: 40)
                : Icon(Icons.flag_outlined, color: Colors.green, size: 20)),
        IconButton(
            onPressed: () {
              setState(() {
                currentClick = 'medium';
              });
              priority = 2;
            },
            icon: currentClick == 'medium'
                ? Icon(Icons.flag, color: Colors.amber, size: 40)
                : Icon(Icons.flag_outlined, color: Colors.amber, size: 20)),
        IconButton(
            onPressed: () {
              setState(() {
                currentClick = 'high';
              });
              priority = 3;
            },
            icon: currentClick == 'high'
                ? Icon(Icons.flag, color: Colors.redAccent, size: 40)
                : Icon(Icons.flag_outlined, color: Colors.redAccent, size: 20)),
      ],
    );
  }

  showGroupListDialog() {
    toWho = [];
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return SelectUserForGroupDialog(groupList: (SelectGroup group) {
            setState(() {
              toWho = group.groupDataList;
            });
          });
        }).then((value) => null);
  }

  Widget _buildPopUp() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Constants.CONTAINER_COLOR),
      child: ListTile(
        onTap: () {
          showGroupListDialog();
        },
        leading: Text(
          'To'.tr(),
          style: appTextStyle,
        ),
        trailing: Icon(Icons.arrow_drop_down),
      ),
    );
  }

  Widget buildTargetList(MyProvider provider) {
    return toWho.isEmpty
        ? Container()
        : Container(
            height: 50,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Constants.CONTAINER_COLOR),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: toWho.length,
              itemBuilder: (context, index) {
                return buildTile(toWho[index], provider);
              },
            ),
          );
  }

  Widget buildTile(String id, MyProvider provider) {
    String text = '';
    if (id == '1' || id == '2' || id == '3') {
      switch (id) {
        case '1':
          text = 'Guests'.tr();
          break;

        case '2':
          text = 'Members'.tr();
          break;

        case '3':
          text = 'Leaders'.tr();
          break;
      }
    } else {
      text = provider.getGroupNameById(id);
    }
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(text),
            IconButton(
                onPressed: () {
                  setState(() {
                    toWho.remove(id);
                  });
                },
                icon: Icon(
                  Icons.cancel,
                  color: Constants.CANCEL_COLOR,
                  size: 20,
                ))
          ],
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Slider(
      min: 1,
      max: 3,
      onChanged: (double value) {
        setState(() {
          priorityNumber = value;
          switch (value.toInt()) {
            case 1:
              priority = 1;
              break;
            case 2:
              priority = 2;
              break;
            case 3:
              priority = 3;
              break;
          }
        });
      },
      activeColor: Colors.red,
      value: priorityNumber,
      divisions: 2,
      label: '$priority',
    );
  }
}
