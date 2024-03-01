import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/main_screen_scaffold.dart';

import 'package:firebase_calendar/main.dart';
import 'package:firebase_calendar/models/announcement.dart';
import 'package:firebase_calendar/models/badge_count.dart';
import 'package:firebase_calendar/models/created_chats.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/started_group_chat.dart';
import 'package:firebase_calendar/screens/admin_panel/admin_panel_screen.dart';
import 'package:firebase_calendar/screens/announcements/announcement_detail.dart';
import 'package:firebase_calendar/screens/announcements/announcement_screen.dart';
import 'package:firebase_calendar/screens/events/event_main_screen.dart';
import 'package:firebase_calendar/screens/messages/chat_screen.dart';
import 'package:firebase_calendar/screens/messages/group_chat_screen.dart';
import 'package:firebase_calendar/screens/messages/messages_screen.dart';
import 'package:firebase_calendar/screens/profile/profile_screen.dart';
import 'package:firebase_calendar/screens/rooms_screen/room_and_booking_history.dart';
import 'package:firebase_calendar/screens/tasks/tasks_screen_main.dart';
import 'package:firebase_calendar/services/count_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/drawer.dart';
import 'package:firebase_calendar/shared/end_drawer.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class MainScreenWithBottomNav extends StatefulWidget {
  final CurrentUserData currentUserData;
  final String userRole;
  final String subLevel;
  const MainScreenWithBottomNav(
      {Key? key,
      required this.currentUserData,
      required this.userRole,
      required this.subLevel})
      : super(key: key);

  @override
  State<MainScreenWithBottomNav> createState() =>
      _MainScreenWithBottomNavState();
}

class _MainScreenWithBottomNavState extends State<MainScreenWithBottomNav> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  int currentIndex = 0;
  // final messageService = MessageService();
  // final announcementService=AnnouncementService();
  late CountService countService;
  // late Stream<List<CreatedChats>> getCreatedChats;
  // late Stream<List<StartedGroupChat>> getStartedGroupChats;
  // late Stream<List<Announcement>> getAnnouncements;
  late Stream<BadgeCount> getCount;

  onNotificationOpened() {
    //Check URL
    OneSignal.Notifications.addClickListener((event) {
      final url = event.result.url!;
    });
    /*  OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      //filled later
      print('"OneSignal: notification opened');

      String url = result.notification.launchUrl ?? "";
      Map<String, dynamic> notificationData =
          result.notification.additionalData ?? {};
      String notificationUrs = "";
      if (notificationData.containsKey("uid")) {
        notificationUrs = notificationData["uid"];
      }
      //print("URL IS $url");
      //print(notificationData);
      
    }); */
  }

  parseMe(String url, String notificationUrs,
      Map<String, dynamic> notificationData) async {
    if (url.isNotEmpty && url.startsWith("journal://")) {
      String parsed = url.substring(24, url.length);
      print('the parsed is ${parsed}');
      // if(notificationData.containsKey('membersIds')){
      //   Navigator.push(context, MaterialPageRoute(builder: (context){
      //     return ForgotPasswordScreen();
      //   }));
      // }
      handleNotificationRouting(parsed, notificationData);
    }
  }

  Future handleNotificationRouting(
      String parsedUrl, Map<String, dynamic> notificationData) async {
    print('handle notification parsed is ${parsedUrl}');
    if (parsedUrl != "") {
      switch (parsedUrl) {
        case 'groupMessage':
          String channelId = notificationData['channelId'];
          String channelName = notificationData['channelName'];
          List<String> membersIds =
              List.castFrom(notificationData['membersIds']);
          String senderOrgId = notificationData['organizationId'];
          await MyApp.navigatorKey.currentState
              ?.push(MaterialPageRoute(builder: (context) {
            return GroupChatScreen(
                channelId: channelId,
                channelName: channelName,
                membersIds: membersIds,
                currentOrgId: senderOrgId,
                currentUid: widget.currentUserData.uid,
                currentUserName: Utils.getUserName(
                    widget.currentUserData.userName,
                    widget.currentUserData.userSurname));
          }));
          break;
        case 'directMessage':
          String senderId = notificationData['senderId'];
          String url = notificationData['url'];
          String userName = notificationData['senderName'];
          String roomName =
              Utils.generateRoomName(widget.currentUserData.uid, senderId);
          String senderOrgId = notificationData['senderOrgId'];
          // print('sender org id $senderOrgId');
          // print(" sender id $senderId");
          // print('$url');
          await MyApp.navigatorKey.currentState
              ?.push(MaterialPageRoute(builder: (context) {
            return ChatScreen(
              senderOrgId: senderOrgId,
              currentUserData: widget.currentUserData,
              roomName: roomName,
              chattedUserUid: senderId,
              url: url,
              userName: userName,
            );
          }));
          break;
        case 'adminPanel':
          final userRole = Utils.getUserRole(
              widget.currentUserData.userOrganizations,
              widget.currentUserData.currentOrganizationId);
          if (userRole == '4') {
            await MyApp.navigatorKey.currentState
                ?.push(MaterialPageRoute(builder: (context) {
              return AdminPanel(
                  currentUserData: widget.currentUserData, subLevel: 'premium');
            }));
          } else {
            Utils.showErrorToast();
          }
          break;
        case 'adminPanelBooking':
          final userRole = Utils.getUserRole(
              widget.currentUserData.userOrganizations,
              widget.currentUserData.currentOrganizationId);
          if (userRole == '4') {
            await MyApp.navigatorKey.currentState
                ?.push(MaterialPageRoute(builder: (context) {
              return AdminPanel(
                  currentUserData: widget.currentUserData,
                  subLevel: 'premium',
                  notificationPage: 'new bookings');
            }));
          } else {
            Utils.showErrorToast();
          }
          break;
        case 'roomBooking':
          await MyApp.navigatorKey.currentState
              ?.push(MaterialPageRoute(builder: (context) {
            return RoomAndBookingHistory(
                currentUserData: widget.currentUserData,
                userRole: widget.userRole);
          }));
          break;
        case 'announcement':
          String announcementId = notificationData['announcementId'];
          String announcementTitle = notificationData['announcementTitle'];
          String announcement = notificationData['announcement'];
          String createdBy = notificationData['createdBy'];
          String organizationId = notificationData['organizationId'];
          // String documentUrl=notificationData['documentUrl'];
          String documentUrl = '';
          final announcementToBeUsed = Announcement(
              announcementId: announcementId,
              announcementTitle: announcementTitle,
              announcement: announcement,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              organizationId: organizationId,
              createdBy: createdBy,
              priority: 1,
              toWho: [],
              seenBy: [],
              documentUrl: documentUrl);
          await MyApp.navigatorKey.currentState
              ?.push(MaterialPageRoute(builder: (context) {
            return AnnouncementDetailScreen(
                uid: widget.currentUserData.uid,
                announcement: announcementToBeUsed);
          }));
          break;
      }
    }
  }

  @override
  void initState() {
    onNotificationOpened();
    countService = CountService(
        organizationId: widget.currentUserData.currentOrganizationId);
    countService.init();
    getCount = countService.getBadgeCount(widget.currentUserData.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder<BadgeCount>(
        stream: getCount,
        builder: (context, snapshot) {
          int totalMessageCount = 0;
          int unseenAnnouncementCount = 0;
          int totalDrawerCount = 0;
          int surveyCount = 0;
          int pollCount = 0;
          //int taskCount = 0;
          if (snapshot.hasData) {
            final count = snapshot.data!;
            totalMessageCount = count.groupChatCount + count.messageCount;
            unseenAnnouncementCount = count.announcementCount;
            totalDrawerCount = count.pollCount + count.surveyCount;
            surveyCount = count.surveyCount;
            pollCount = count.pollCount;
          }
          return MainScreenBaseScaffold(
            endDrawer: SideDrawer(
                currentUserData: widget.currentUserData,
                userRole: widget.userRole,
                subLevel: widget.subLevel,
                pollCount: pollCount,
                surveyCount: surveyCount,
                countService: countService),
            appBar: appBar(totalDrawerCount),
            body: buildBody(0, 0, [], [], []),
            drawer: EndDrawer(currentUserData: widget.currentUserData),
            bottomNavBar:
                buildBottomNavBar(totalMessageCount, unseenAnnouncementCount),
            size: size,
            scaffoldKey: scaffoldKey,
          );
        });
  }

  Widget appBar(int drawerCount) {
    String orgName = Utils.getOrgNameAndImage(
        widget.currentUserData.currentOrganizationId,
        widget.currentUserData.userOrganizations)[0];
    String orgUrl = Utils.getOrgNameAndImage(
        widget.currentUserData.currentOrganizationId,
        widget.currentUserData.userOrganizations)[1];
    return ListTile(
        leading: GestureDetector(
          onTap: () {
            scaffoldKey.currentState?.openDrawer();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              imageUrl: orgUrl,
              placeholder: (context, url) =>
                  Center(child: new CircularProgressIndicator()),
              errorWidget: (context, url, error) => new Icon(Icons.error),
            ),
          ),
        ),
        title: Text(
          orgName,
          style: appTextStyle.copyWith(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: drawerCount == 0
            ? Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                child: IconButton(
                  onPressed: () => scaffoldKey.currentState!.openEndDrawer(),
                  icon: Icon(Icons.view_sidebar_rounded,
                      color: Constants.BACKGROUND_COLOR),
                ),
              )
            : Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5)),
                    child: IconButton(
                      onPressed: () =>
                          scaffoldKey.currentState!.openEndDrawer(),
                      icon: Icon(Icons.view_sidebar_rounded,
                          color: Constants.BACKGROUND_COLOR),
                    ),
                  ),
                  new Positioned(
                    right: -5,
                    top: -5,
                    child: new Container(
                      padding: EdgeInsets.all(1),
                      decoration: new BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: new Text(
                        drawerCount.toString(),
                        style: new TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ));
  }

  Widget buildBody(
      int totalPrivateMessage,
      int totalGroupMessage,
      List<CreatedChats> createdChats,
      List<StartedGroupChat> startedGroupChats,
      List<Announcement> announcements) {
    final screens = [
      EventMainScreen(
          currentUserData: widget.currentUserData,
          userRole: widget.userRole,
          subLevel: widget.subLevel),
      Announcements(
          userData: widget.currentUserData,
          userRole: widget.userRole,
          announcements: announcements),
      Messages(
          userdata: widget.currentUserData,
          userRole: widget.userRole,
          totalPrivateChatUnseenMessage: totalPrivateMessage,
          totalChannelUnseenMessage: totalGroupMessage,
          createdChats: createdChats,
          startedGroupChats: startedGroupChats),
      TasksScreen(
          currentUserData: widget.currentUserData, userRole: widget.userRole),
      Profile(userData: widget.currentUserData, userRole: widget.userRole)
    ];
    return screens[currentIndex];
  }

  Widget buildBottomNavBar(int totalMessageCount, int unseenAnnouncementCount) {
    return BottomNavigationBar(
        elevation: 0,
        backgroundColor: Constants.CONTAINER_COLOR,
        selectedItemColor: Constants.BUTTON_COLOR,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 3 &&
              (widget.subLevel == '' || widget.subLevel == 'freemium')) {
            return;
          }
          if (index == 1) {
            if (unseenAnnouncementCount != 0) {
              countService
                  .resetCountForAnnouncement(widget.currentUserData.uid);
            }
          } else if (index == 2) {
            if (totalMessageCount != 0) {
              countService.resetCountForMessages(widget.currentUserData.uid);
            }
          }
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              label: Strings.EVENTS.tr(),
              icon: Icon(
                Icons.event,
                key: Key('events'),
              )),
          BottomNavigationBarItem(
              label: Strings.ANNOUNCEMENT.tr(),
              icon: unseenAnnouncementCount == 0
                  ? Icon(Icons.campaign, key: Key('announcements'))
                  : Stack(
                      children: [
                        new Icon(Icons.campaign),
                        new Positioned(
                          right: 0,
                          child: new Container(
                            padding: EdgeInsets.all(1),
                            decoration: new BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: new Text(
                              unseenAnnouncementCount.toString(),
                              style: new TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    )),
          BottomNavigationBarItem(
            label: Strings.MESSAGES.tr(),
            icon: totalMessageCount == 0
                ? Icon(Icons.message, key: Key('messages'))
                : Stack(
                    children: <Widget>[
                      new Icon(Icons.message),
                      new Positioned(
                        right: 0,
                        child: new Container(
                          padding: EdgeInsets.all(1),
                          decoration: new BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: new Text(
                            totalMessageCount.toString(),
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  ),
          ),
          BottomNavigationBarItem(
              label: 'Tasks',
              icon: widget.subLevel == '' || widget.subLevel == 'freemium'
                  ? Stack(
                      children: [
                        Icon(FontAwesomeIcons.tasks, key: Key('tasks')),
                        Positioned(
                            top: 0,
                            child: Icon(
                              Icons.lock,
                              color: Constants.CANCEL_COLOR,
                            ))
                      ],
                    )
                  : Icon(FontAwesomeIcons.tasks, key: Key('tasks'))),
        ]);
  }
}
