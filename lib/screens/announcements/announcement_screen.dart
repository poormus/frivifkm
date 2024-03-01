import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold_main_screen_item.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/dialog/sort_by_dialog.dart';
import 'package:firebase_calendar/models/announcement.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/announcements_service.dart';
import 'package:firebase_calendar/services/count_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/utils.dart';

class Announcements extends StatefulWidget {
  final CurrentUserData userData;
  final String userRole;
  final List<Announcement> announcements;

  Announcements(
      {Key? key,
      required this.userData,
      required this.userRole,
      required this.announcements})
      : super(key: key);

  @override
  State<Announcements> createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  final service = AnnouncementService();
  late CountService countService;
  String sortString = 'time';
  late Stream<List<Announcement>> getAnnouncements;

  @override
  void initState() {
    countService =
        CountService(organizationId: widget.userData.currentOrganizationId);
    countService.init();
    getAnnouncements = service
        .getOrganizationAnnouncements(widget.userData.currentOrganizationId);
    // service.listenToChanges(widget.userData.currentOrganizationId);
    // service.requestNextPage(widget.userData.currentOrganizationId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context);
    return BaseScaffoldMainScreenItem(
        body: buildBody(provider), fab: buildFab(context));
    //return BaseScaffold(appBarName: Strings.ANNOUNCEMENT.tr(), body: buildBody(), shouldScroll: false,floatingActionButton: buildFab(context));
  }

  Widget? buildFab(BuildContext context) {
    return widget.userRole == '4' || widget.userRole == '3'
        ? AvatarGlow(
            animate: true,
            repeat: true,
            glowColor: Constants.BUTTON_COLOR,
            child: FloatingActionButton(
              backgroundColor: Constants.BUTTON_COLOR,
              onPressed: () {
                service.firstRequestIndex++;
                Navigation.navigateToAddEditAnnouncementScreen(
                    context, widget.userData, null);
              },
              child: Icon(Icons.campaign),
            ),
          )
        : null;
  }

  void showSortDialog() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return SortDialog(sort: (OnSortSelected sort) {
            setState(() {
              sortString = sort.sortString;
            });
          });
        }).then((value) => null);
  }

  List<Announcement> _sortAnnouncements(
      List<Announcement> announcements, String sortString) {
    List<Announcement> sortedList = [];
    switch (sortString) {
      case 'priority':
        sortedList = announcements
          ..sort((a1, a2) {
            return a1.priority.compareTo(a2.priority);
          });
        sortedList = sortedList.reversed.toList();
        break;
      case 'time':
        sortedList = announcements
          ..sort((a1, a2) {
            return a1.createdAt.compareTo(a2.createdAt);
          });
        sortedList = sortedList.reversed.toList();
        break;
    }
    return sortedList;
  }

  // Widget buildBody() {
  //   return NotificationListener<ScrollNotification>(
  //     onNotification: (ScrollNotification scrollInfo) {
  //       if (scrollInfo.metrics.maxScrollExtent == scrollInfo.metrics.pixels) {
  //         announcementServices.requestNextPage(widget.userData.currentOrganizationId);
  //       }
  //       return true;
  //     },
  //     child: StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
  //       stream: announcementServices.streamController.stream,
  //       builder: (context, snapshot) {
  //         if (snapshot.hasData) {
  //           final allAnnouncements = snapshot.data!.map((e) =>
  //               Announcement.fromMap(e.data()!)).toList();
  //           final sortedList = _sortAnnouncements(allAnnouncements, sortString);
  //           if (allAnnouncements.length == 0) {
  //             return noDataWidget(Strings.ANNOUNCEMENT_EMPTY_LIST.tr(), false);
  //           } else {
  //             return Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(
  //                           horizontal: 12.0, vertical: 4),
  //                       child: GestureDetector(
  //                           onTap: () => showSortDialog(),
  //                           child: Icon(Icons.sort_by_alpha)),
  //                     ),
  //                   ],
  //                 ),
  //                 Expanded(
  //                   child: ListView.builder(
  //                     itemCount: sortedList.length,
  //                     itemBuilder: (context, index) {
  //                       return AnnouncementTile(
  //                           userRole: widget.userRole,
  //                           announcement: sortedList[index],
  //                           userData: widget.userData);
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             );
  //           }
  //         } else if (snapshot.hasError) {
  //           return noDataWidget(snapshot.error.toString(), false);
  //         } else {
  //           return noDataWidget(null, true);
  //         }
  //       },
  //     ),
  //   );
  // }

  List<Announcement> getMyAnnouncements(List<Announcement> announcements) {
    List<Announcement> myAnnouncements = [];
    if (widget.userRole == '3' || widget.userRole == '4') {
      myAnnouncements = announcements;
    } else {
      announcements.forEach((element) {
        if (isMyGroupIdListWithinAnnouncementToWhoList(
            element.toWho, element.seenBy)) {
          myAnnouncements.add(element);
        }
      });
    }
    return myAnnouncements;
  }

  bool isMyGroupIdListWithinAnnouncementToWhoList(
      List<String> toWho, List<String> seenBy) {
    if (toWho.contains(widget.userRole) ||
        widget.userData.groupIds.toSet().intersection(toWho.toSet()).length !=
            0) {
      return true;
    } else
      return false;
  }

  // Widget buildBody(MyProvider provider) {
  //   return StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
  //       stream: service.streamController.stream,
  //       builder: (context, snapshot) {
  //
  //         if (snapshot.hasData) {
  //           final allAnnouncements = snapshot.data!.map((e) =>
  //                             Announcement.fromMap(e.data()!)).toList();
  //           final myAnnouncements = getMyAnnouncements(allAnnouncements);
  //           final sortedList = _sortAnnouncements(myAnnouncements, sortString);
  //           if (allAnnouncements.length == 0) {
  //             return noDataWidget(Strings.ANNOUNCEMENT_EMPTY_LIST.tr(), false);
  //           } else {
  //             return Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(
  //                           horizontal: 12.0, vertical: 4),
  //                       child: GestureDetector(
  //                           onTap: () => showSortDialog(),
  //                           child: Icon(Icons.filter_alt,
  //                               color: Constants.CANCEL_COLOR)),
  //                     ),
  //                   ],
  //                 ),
  //                 Expanded(
  //                   child: ListView(
  //                     children: [
  //                       ListView.builder(
  //                         physics: NeverScrollableScrollPhysics(),
  //                         itemCount: sortedList.length,
  //                         shrinkWrap: true,
  //                         itemBuilder: (context, index) {
  //                           return AnnouncementTile(
  //                             provider: provider,
  //                             service: service,
  //                             userRole: widget.userRole,
  //                             announcement: sortedList[index],
  //                             userData: widget.userData,
  //                             countService: countService,
  //                           );
  //                         },
  //                       ),
  //                       sortedList.length>30?Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: ElevatedCustomButton(text: 'Load more',
  //                             press: (){
  //                             service.requestNextPage(widget.userData.currentOrganizationId);
  //                         },
  //                             color: Constants.CANCEL_COLOR),
  //                       ):Container()
  //
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             );
  //           }
  //         } else if (snapshot.hasError) {
  //           return noDataWidget(snapshot.error.toString(), false);
  //         } else
  //           return noDataWidget(Strings.ANNOUNCEMENT_EMPTY_LIST.tr(), false);
  //       });
  // }
  Widget buildBody(MyProvider provider) {
    return StreamBuilder<List<Announcement>>(
        stream: getAnnouncements,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final allAnnouncements = snapshot.data!;
            final myAnnouncements = getMyAnnouncements(allAnnouncements);
            final sortedList = _sortAnnouncements(myAnnouncements, sortString);
            if (allAnnouncements.length == 0) {
              return noDataWidget(Strings.ANNOUNCEMENT_EMPTY_LIST.tr(), false);
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 4),
                        child: GestureDetector(
                            onTap: () => showSortDialog(),
                            child: Icon(Icons.filter_alt,
                                color: Constants.CANCEL_COLOR)),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return AnnouncementTile(
                          provider: provider,
                          service: service,
                          userRole: widget.userRole,
                          announcement: sortedList[index],
                          userData: widget.userData,
                          countService: countService,
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          } else if (snapshot.hasError) {
            return noDataWidget(snapshot.error.toString(), false);
          } else
            return noDataWidget(Strings.ANNOUNCEMENT_EMPTY_LIST.tr(), true);
        });
  }
}

class AnnouncementTile extends StatefulWidget {
  final MyProvider provider;
  final Announcement announcement;
  final CurrentUserData userData;
  final String userRole;
  final AnnouncementService service;
  final CountService countService;

  const AnnouncementTile(
      {Key? key,
      required this.provider,
      required this.announcement,
      required this.userData,
      required this.userRole,
      required this.service,
      required this.countService})
      : super(key: key);

  @override
  _AnnouncementTileState createState() => _AnnouncementTileState();
}

class _AnnouncementTileState extends State<AnnouncementTile> {
  late int priority;
  late Icon priorityIcon;

  void editAnnouncement() {
    Navigation.navigateToAddEditAnnouncementScreen(
        context, widget.userData, widget.announcement);
  }

  void showDeleteDialog(BuildContext context, String announcementId) {
    BlurryDialogNew alert = BlurryDialogNew(
        title: Strings.DELETE_ANNOUNCEMENT.tr(),
        continueCallBack: () {
          widget.service.deleteAnnouncement(announcementId);
          widget.countService.updateAnnouncementCountOnDeleteAnnouncement(
              widget.provider,
              widget.announcement.toWho,
              widget.announcement.seenBy);
          Navigator.of(context).pop();
        });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void showAnnouncementDetailScreen() {
    Navigation.navigateToAnnouncementDetail(
        context, widget.announcement, widget.userData.uid);
  }

  @override
  Widget build(BuildContext context) {
    priority = widget.announcement.priority;
    switch (priority) {
      case 1:
        priorityIcon = Icon(Icons.flag_rounded, color: Colors.green);
        break;
      case 2:
        priorityIcon = Icon(Icons.flag_rounded, color: Colors.amber);
        break;
      case 3:
        priorityIcon = Icon(Icons.flag_rounded, color: Colors.redAccent);
        break;
    }
    bool isToMe = false;
    if (widget.userData.groupIds
                .toSet()
                .intersection(widget.announcement.toWho.toSet())
                .length !=
            0 ||
        widget.announcement.toWho.contains(widget.userRole)) {
      isToMe = true;
    }

    return widget.userRole == '4' || isToMe || widget.userRole == '3'
        ? GestureDetector(
            onTap: showAnnouncementDetailScreen,
            child: Card(
                color: Constants.CONTAINER_COLOR,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      ListTile(
                        isThreeLine: true,
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                                widget.announcement.createdBy
                                    .toUpperCase()
                                    .substring(0, 1),
                                style: appTextStyle.copyWith(
                                    fontSize: 22, color: Colors.blue)),
                          ),
                        ),
                        title: Text(
                          widget.announcement.announcementTitle,
                          maxLines: 1,
                          style: appTextStyle.copyWith(
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            widget.announcement.createdBy,
                            style: appTextStyle,
                          ),
                        ),
                        trailing: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Column(
                            children: [
                              Text(
                                Utils.getTimeAgo(
                                    widget.announcement.createdAt, context),
                                style: appTextStyle,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                  width: 50,
                                  child: Row(
                                    children: [
                                      priorityIcon,
                                      if (!widget.announcement.seenBy
                                          .contains(widget.userData.uid)) ...[
                                        Icon(Icons.info_rounded,
                                            color: Constants.CANCEL_COLOR)
                                      ]
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      ),
                      if (widget.announcement.creatorUid ==
                              widget.userData.uid ||
                          widget.userRole == '4') ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                onPressed: editAnnouncement,
                                icon: Icon(Icons.edit,
                                    color: Constants.BUTTON_COLOR)),
                            SizedBox(width: 10),
                            IconButton(
                                onPressed: () {
                                  showDeleteDialog(context,
                                      widget.announcement.announcementId);
                                },
                                icon: Icon(Icons.delete_rounded,
                                    color: Constants.CANCEL_COLOR)),
                          ],
                        )
                      ]
                    ],
                  ),
                )),
          )
        : Container();
  }
}
