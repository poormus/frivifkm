import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/anim/popup_anim.dart';
import 'package:firebase_calendar/anim/slide_in_right.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/primary_button.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/event.dart';
import 'package:firebase_calendar/models/external_user.dart';
import 'package:firebase_calendar/screens/events/event_map.dart';
import 'package:firebase_calendar/services/event_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../dialog/external_user_attend_modal_bottom.dart';

//ignore:must_be_immutable
class EventDetailScreen extends StatelessWidget {
  final Event event;
  final String userRole;
  final String currentOrganizationId;
  final CurrentUserData currentUserData;
  EventServices eventServices = EventServices();
  final String subLevel;
  final String? guestId;

  EventDetailScreen(
      {Key? key,
      required this.event,
      required this.userRole,
      required this.currentOrganizationId,
      required this.currentUserData,
      required this.subLevel,
      this.guestId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<MyProvider>(context);
    return BaseScaffold(
        appBarName: 'Event Detail'.tr(),
        body: body(size, context, provider),
        shouldScroll: true);
  }

  showDeleteEventConfirmationDialog(BuildContext context) {
    BlurryDialogNew dialog = BlurryDialogNew(
        title: 'Delete this event?'.tr(),
        continueCallBack: () async {
          Navigator.of(context).pop();
          await eventServices.deleteEvent(event.eventId, context).catchError(
              (onError) => Utils.showToast(context, onError.toString()));
        });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  Widget body(Size size, BuildContext context, MyProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(HeroDialogRoute(builder: (context) {
                return _PopupCard(imageUrl: event.eventUrl);
              }));
            },
            child: Hero(
              tag: 'animate_popup',
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: size.width * 0.85,
                    height: 150,
                    imageUrl: event.eventUrl,
                    placeholder: (context, url) =>
                        Align(child: new CircularProgressIndicator()),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                  )),
            ),
          ),
          SizedBox(height: 10),
          guestId != null
              ? Container()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomTextButton(
                          width: size.width * 0.4,
                          height: 35,
                          text: 'Declined'.tr() +
                              ' : ${event.declinedUids.length}',
                          textColor: Constants.CANCEL_COLOR,
                          containerColor: Constants.BACKGROUND_COLOR,
                          press: currentOrganizationId == ''
                              ? () {}
                              : () {
                                  Navigation
                                      .navigateToDeclineAttendUserListScreen(
                                          context,
                                          event.declinedUids,
                                          event.attendingUids,
                                          event.externalUsers,
                                          currentOrganizationId,
                                          event.eventId,
                                          currentUserData);
                                }),
                      CustomTextButton(
                          width: size.width * 0.4,
                          height: 35,
                          text: 'Attending'.tr() +
                              ' : ${event.attendingUids.length + event.externalUsers.length}',
                          textColor: Constants.BUTTON_COLOR,
                          containerColor: Constants.BACKGROUND_COLOR,
                          press: currentOrganizationId == ''
                              ? () {}
                              : () {
                                  Navigation
                                      .navigateToDeclineAttendUserListScreen(
                                          context,
                                          event.declinedUids,
                                          event.attendingUids,
                                          event.externalUsers,
                                          currentOrganizationId,
                                          event.eventId,
                                          currentUserData);
                                }),
                    ],
                  ),
                ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Container(
                      width: size.width * 0.4,
                      height: size.height * 0.15,
                      decoration: BoxDecoration(
                          color: Constants.CONTAINER_COLOR,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    Positioned.fill(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            event.eventName,
                            style: appTextStyle.copyWith(
                                fontWeight: FontWeight.bold),
                          )),
                    )),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              'Name'.tr(),
                              style: textStyle,
                            )),
                      ),
                    )
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      width: size.width * 0.4,
                      height: size.height * 0.15,
                      decoration: BoxDecoration(
                          color: Constants.CONTAINER_COLOR,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    Positioned.fill(
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            Utils.toDate(event.eventDate),
                            style: appTextStyle.copyWith(
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              'Date'.tr(),
                              style: textStyle,
                            )),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Container(
                      width: size.width * 0.4,
                      height: size.height * 0.15,
                      decoration: BoxDecoration(
                          color: Constants.CONTAINER_COLOR,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    Positioned.fill(
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              '${Utils.toTime(event.eventStartTime)}-${Utils.toTime(event.eventEndTime)}',
                              style: appTextStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                            ))),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              'Time'.tr(),
                              style: textStyle,
                            )),
                      ),
                    )
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      width: size.width * 0.4,
                      height: size.height * 0.15,
                      decoration: BoxDecoration(
                          color: Constants.CONTAINER_COLOR,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              event.eventAddress,
                              style: appTextStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                            )),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              'Address'.tr(),
                              style: textStyle,
                            )),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () => handleLocationClick(
                                  event.coordinates, context),
                              icon: Icon(Icons.place),
                            )),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: size.width * 0.85,
            decoration: BoxDecoration(
              color: Constants.CONTAINER_COLOR,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    event.eventInformation,
                    style: appTextStyle,
                  ),
                ),
                Container(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'Information'.tr(),
                        style: textStyle,
                      )),
                ))
              ],
            ),
          ),
          SizedBox(height: 10),
          if (userRole == '4' || currentUserData.uid == event.createdByUid) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      PrimaryButton(
                          text: 'Delete Event'.tr(),
                          press: () {
                            showDeleteEventConfirmationDialog(context);
                          },
                          color: Constants.CANCEL_COLOR),
                      PrimaryButton(
                          text: 'Edit Event'.tr(),
                          press: () {
                            Navigator.pop(context);
                            Navigation.navigateToAddEditEventScreen(context,
                                currentUserData, userRole, event, subLevel);
                          },
                          color: Constants.BUTTON_COLOR),
                    ],
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 10),
          guestId == null
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: AttendForGuest(
                      guestId: guestId!,
                      event: event,
                      size: size,
                      services: eventServices,
                      provider: provider),
                ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

void handleLocationClick(Coordinates? coordinates, BuildContext context) async {
  final String googleMapslocationUrl =
      "https://www.google.com/maps/search/?api=1&query=${coordinates?.lat},${coordinates?.long}";

  final String encodedURl = Uri.encodeFull(googleMapslocationUrl);
  if (await canLaunch(encodedURl)) {
    await launch(encodedURl);
  } else {
    print('Could not launch $encodedURl');
    throw 'Could not launch $encodedURl';
  }
}

class _PopupCard extends StatelessWidget {
  final String imageUrl;

  const _PopupCard({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: 'animate_popup',
          child: Material(
            color: Constants.BACKGROUND_COLOR,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(image: NetworkImage(imageUrl))),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AttendForGuest extends StatefulWidget {
  final String guestId;
  final Event event;
  final Size size;
  final EventServices services;
  final MyProvider provider;
  const AttendForGuest(
      {Key? key,
      required this.guestId,
      required this.event,
      required this.size,
      required this.services,
      required this.provider})
      : super(key: key);

  @override
  _AttendForGuestState createState() => _AttendForGuestState();
}

class _AttendForGuestState extends State<AttendForGuest> {
  late Event event;

  @override
  void dispose() {
    widget.provider.hasUserClickedAttend = false;
    super.dispose();
  }

  @override
  void initState() {
    event = widget.event;
    super.initState();
  }

  bool isAttending(Event event) {
    bool isAttending = false;
    List<String> guestIds = [];
    event.externalUsers.forEach((element) {
      guestIds.add(element.guestId);
    });
    if (guestIds.contains(widget.guestId)) {
      isAttending = true;
    }
    return isAttending;
  }

  void removeAttendStatus(Event event, MyProvider provider) {
    log('called');
    widget.services.removeAttendStatus(event, widget.guestId).then((value) => {
          provider.hasUserClickedAttend = false,
          setState(() {
            event.externalUsers
                .removeWhere((element) => element.guestId == widget.guestId);
          })
        });
  }

  void showModalBottom(String eventId, MyProvider provider) {
    showDialog(
        context: context,
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: ExternalUserAttendEvent(
                guestId: widget.guestId, eventId: eventId),
          );
        }).then((value) => {
          if (provider.hasUserClickedAttend)
            {
              setState(() {
                event.externalUsers.add(ExternalUser(
                    guestId: widget.guestId, name: '', surname: '', email: ''));
              })
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomTextButton(
            width: widget.size.width * 0.25,
            height: 35,
            text: isAttending(event) ? 'Attending'.tr() : 'Attend'.tr(),
            textColor:
                isAttending(event) ? Colors.white : Constants.BUTTON_COLOR,
            containerColor: isAttending(event)
                ? Constants.BUTTON_COLOR
                : Constants.BACKGROUND_COLOR,
            press: () => isAttending(event)
                ? removeAttendStatus(event, widget.provider)
                : showModalBottom(event.eventId, widget.provider)),
        SizedBox(width: 10)
      ],
    );
  }
}
