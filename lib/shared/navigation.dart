import 'package:firebase_calendar/anim/bouncy_page_route.dart';
import 'package:firebase_calendar/anim/slide_in_right.dart';
import 'package:firebase_calendar/models/announcement.dart';
import 'package:firebase_calendar/models/channel.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/document.dart';
import 'package:firebase_calendar/models/event.dart';
import 'package:firebase_calendar/models/faq.dart';
import 'package:firebase_calendar/models/group.dart';
import 'package:firebase_calendar/models/room.dart';
import 'package:firebase_calendar/models/work_time.dart';
import 'package:firebase_calendar/screens/admin_panel/admin_panel_screen.dart';
import 'package:firebase_calendar/screens/admin_panel/edit_member_screen.dart';
import 'package:firebase_calendar/screens/admin_panel/view_recent_user_activity.dart';
import 'package:firebase_calendar/screens/announcements/add_edit_announcement.dart';
import 'package:firebase_calendar/screens/announcements/announcement_detail.dart';
import 'package:firebase_calendar/screens/announcements/announcement_screen.dart';
import 'package:firebase_calendar/screens/announcements/view_seenby_members.dart';
import 'package:firebase_calendar/screens/auth/forget_password_screen.dart';
import 'package:firebase_calendar/screens/auth/register_as_admin_screen.dart';
import 'package:firebase_calendar/screens/events/add_edit_event.dart';
import 'package:firebase_calendar/screens/events/declined_attending_user_list.dart';
import 'package:firebase_calendar/screens/events/event_chat_widget.dart';
import 'package:firebase_calendar/screens/events/event_chat_widget_navigated.dart';
import 'package:firebase_calendar/screens/events/event_main_screen.dart';
import 'package:firebase_calendar/screens/events/view_event_detail.dart';
import 'package:firebase_calendar/screens/faq/add_edit_faq.dart';
import 'package:firebase_calendar/screens/faq/faq_screen.dart';
import 'package:firebase_calendar/screens/groups/add_edit_group.dart';
import 'package:firebase_calendar/screens/groups/groups_screen.dart';
import 'package:firebase_calendar/screens/groups/view_group_members.dart';
import 'package:firebase_calendar/screens/how_to/how_to_screen_no_skip.dart';
import 'package:firebase_calendar/screens/language/select_language_screen.dart';
import 'package:firebase_calendar/screens/messages/add_edit_channel.dart';
import 'package:firebase_calendar/screens/messages/group_chat_screen.dart';
import 'package:firebase_calendar/screens/messages/messages_screen.dart';
import 'package:firebase_calendar/screens/messages/view_channel_members.dart';
import 'package:firebase_calendar/screens/messages/view_photo_screen.dart';
import 'package:firebase_calendar/screens/polls_screen/view_polls.dart';
import 'package:firebase_calendar/screens/profile/edit_profile_screen.dart';
import 'package:firebase_calendar/screens/profile/profile_screen.dart';
import 'package:firebase_calendar/screens/profile/use_code_to_add_organization.dart';
import 'package:firebase_calendar/screens/qr_scan/qr_scanner_screen.dart';
import 'package:firebase_calendar/screens/resources/add_document_screen.dart';
import 'package:firebase_calendar/screens/resources/resources_screen.dart';
import 'package:firebase_calendar/screens/resources/view_pdf.dart';
import 'package:firebase_calendar/screens/rooms_screen/add_edit_room_screen.dart';
import 'package:firebase_calendar/screens/rooms_screen/booking_calendar.dart';
import 'package:firebase_calendar/screens/rooms_screen/room_and_booking_history.dart';
import 'package:firebase_calendar/screens/rooms_screen/view_room_screen.dart';
import 'package:firebase_calendar/screens/settings/settings_screen.dart';
import 'package:firebase_calendar/screens/surveys_screen/view_surveys_screen.dart';
import 'package:firebase_calendar/screens/tasks/task_detail.dart';
import 'package:firebase_calendar/screens/tasks/tasks_screen_main.dart';
import 'package:firebase_calendar/screens/voluntary_work/add_work_time_screen.dart';
import 'package:firebase_calendar/screens/voluntary_work/view_work_time.dart';
import 'package:firebase_calendar/services/task_services.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/external_user.dart';
import '../models/task.dart';
import '../screens/tasks/add_edit_task_screen.dart';

class Navigation {

  static navigateToRoomAndBookingHistoryScreen(
      BuildContext context, CurrentUserData currentUserData, String userRole) {
    Navigator.of(context).push(SlideInRight(Dismissible(
      direction: DismissDirection.startToEnd,
      key: const Key('bookingHistory'),
      onDismissed: (_) => Navigator.of(context).pop(),
      child: RoomAndBookingHistory(
          currentUserData: currentUserData, userRole: userRole),
    )));
  }

  static navigateToAddEditRoomScreen(BuildContext context, Room? room,
      String organizationId, String userRole,CurrentUserData currentUserData) {
    if (room == null) {
      Navigator.of(context).push(SlideInRight(Dismissible(
        direction: DismissDirection.startToEnd,
        key: const Key('addRoom'),
        onDismissed: (_) => Navigator.of(context).pop(),
        child: AddEditRoom(
          companyId: organizationId,
          userRole: userRole,
          currentUserData: currentUserData,
        ),
      )));
    } else {
      Navigator.of(context).push(SlideInRight(Dismissible(
        direction: DismissDirection.startToEnd,
        key: const Key('addRoom'),
        onDismissed: (_) => Navigator.of(context).pop(),
        child: AddEditRoom(
          currentUserData: currentUserData,
          companyId: organizationId,
          room: room,
          userRole: userRole,
        ),
      )));
    }
  }

  static navigateToAddEditAnnouncementScreen(BuildContext context,
      CurrentUserData currentUserData, Announcement? announcement) {
    if (announcement == null) {
      Navigator.of(context).push(SlideInRight(Dismissible(
        direction: DismissDirection.startToEnd,
        key: const Key('announcement'),
        onDismissed: (_) => Navigator.of(context).pop(),
        child: AddEditAnnouncement(
            currentUserData: currentUserData, announcement: announcement),
      )));
    } else {
      Navigator.of(context).push(SlideInRight(Dismissible(
        direction: DismissDirection.startToEnd,
        key: const Key('announcement'),
        onDismissed: (_) => Navigator.of(context).pop(),
        child: AddEditAnnouncement(
            currentUserData: currentUserData, announcement: announcement),
      )));
    }
  }

  static navigateToAddEditFaqScreen(
      BuildContext context, String organizationId, FAQ? faq,String uid) {
    if (faq == null) {
      Navigator.of(context)
          .push(SlideInRight(Dismissible(
          direction: DismissDirection.startToEnd,
          onDismissed: (_) => Navigator.of(context).pop(),
          key: const Key('addFaq'),
          child: AddEditFAQ(organizationId: organizationId ,uid: uid,))));
    } else {
      Navigator.of(context).push(SlideInRight(
          Dismissible(
              onDismissed: (_) => Navigator.of(context).pop(),
              direction: DismissDirection.startToEnd,
              key: const Key('addFaq'),
              child: AddEditFAQ(organizationId: organizationId, faq: faq,uid: uid,))));
    }
  }

  static navigateToAnnouncementScreen(
      BuildContext context, CurrentUserData currentUserData, String userRole) {
    Navigator.of(context)
        .push(SlideInRight(Announcements(userData: currentUserData,userRole: userRole,announcements: [],)));
  }



  static navigateToProfile(
      BuildContext context, CurrentUserData currentUserData,String userRole) {
    Navigator.push(
        context, SlideInRight(Dismissible(
        onDismissed: (_) => Navigator.of(context).pop(),
        direction: DismissDirection.startToEnd,
        key: const Key('Profile'),
        child: Profile(userData: currentUserData,userRole: userRole))));
  }

  static navigateToQr(BuildContext context, CurrentUserData currentUserData, String userRole) {
    Navigator.push(context,
        SlideInRight(Dismissible(
            onDismissed: (_) => Navigator.of(context).pop(),
            direction: DismissDirection.startToEnd,
            key: const Key('qrScreen'),
            child: QrScannerScreen(currentUserData: currentUserData,userRole: userRole,))));
  }

  static navigateToAdmin(
      BuildContext context, CurrentUserData currentUserData,String subLevel) {
    Navigator.push(
        context, SlideInRight(Dismissible(
        onDismissed: (_) => Navigator.of(context).pop(),
        direction: DismissDirection.startToEnd,
        key: const Key('adminPanel'),
        child: AdminPanel(currentUserData: currentUserData,subLevel: subLevel,))));
  }

  static navigateToFaq(BuildContext context, CurrentUserData currentUserData) {
    Navigator.push(
        context, SlideInRight(Dismissible(
        direction: DismissDirection.startToEnd,
        onDismissed: (_) => Navigator.of(context).pop(),
        key: const Key('navigateFaq'),
        child: FaqScreen(currentUserData: currentUserData))));
  }

  static navigateToRegisterOrganizationAsAnAdmin(BuildContext context) {
    Navigator.push(context, SlideInRight(Dismissible(
        onDismissed: (_) => Navigator.of(context).pop(),
        direction: DismissDirection.startToEnd,
        key: const Key('registerAsAdmin'),
        child: RegisterOrganizationAsAnAdmin())));
  }

  static navigateToRoomCalendar(BuildContext context, String roomId,
      CurrentUserData currentUserData, String roomName) {
    Navigator.push(
        context,
        SlideInRight(Dismissible(
          onDismissed: (_) => Navigator.of(context).pop(),
          direction: DismissDirection.startToEnd,
          key: const Key('bookingCalendar'),
          child: BookingCalendar(
            roomId: roomId,
            userData: currentUserData,
            roomName: roomName,
          ),
        )));
  }

  static navigateToEditMemberScreen(BuildContext context,
      CurrentUserData userToManage, CurrentUserData admin) {
    Navigator.push(
        context,
        SlideInRight(
            Dismissible(
                onDismissed: (_) => Navigator.of(context).pop(),
                direction: DismissDirection.startToEnd,
                key: const Key('editMemberScreen'),
                child: EditMemberScreen(userToManage: userToManage, admin: admin))));
  }

  static navigateToForgotPasswordScreen(BuildContext context) {
    Navigator.push(context, SlideInRight(Dismissible(
        onDismissed: (_) => Navigator.of(context).pop(),
        direction: DismissDirection.startToEnd,
        key: const Key('forgotPassword'),
        child: ForgotPasswordScreen())));
  }

  static navigateToViewRoomScreen(
      BuildContext context, Room room, String companyId, String userRole,CurrentUserData currentUserData) {
    Navigator.push(
        context,
        SlideInRight(Dismissible(
          onDismissed: (_) => Navigator.of(context).pop(),
          direction: DismissDirection.startToEnd,
          key: const Key('viewRoomScreen'),
          child: ViewRoomScreen(
            currentUserData: currentUserData,
            room: room,
            companyId: companyId,
            userRole: userRole,
          ),
        )));
  }

  static navigateToHowToScreen(BuildContext context) {
    Navigator.push(context, SlideInRight(Dismissible(
        onDismissed: (_) => Navigator.of(context).pop(),
        direction: DismissDirection.startToEnd,
        key: const Key('howToNoSkip'),
        child: HowToNoSkip())));
  }

  static navigateToCreateGroupScreen(BuildContext context,
      String organizationId, String userRole, String appUserId,CurrentUserData currentUserData) {
    Navigator.push(
        context,
        SlideInRight(Dismissible(
          onDismissed: (_) => Navigator.of(context).pop(),
          direction: DismissDirection.startToEnd,
          key: const Key('createGroupScreen'),
          child: CreateGroupScreen(
              organizationId: organizationId,
              userRole: userRole,
              appUserId: appUserId,
              currentUserData: currentUserData,
          ),
        )));
  }

  static navigateToAddEditGroupScreen(
      BuildContext context, String organizationId, Group? group,CurrentUserData currentUserData) {
    if (group == null) {
      Navigator.push(context,
          SlideInRight(Dismissible(
              onDismissed: (_) => Navigator.of(context).pop(),
              direction: DismissDirection.startToEnd,
              key: const Key('AddEditGroupScreen'),
              child: AddEditGroupScreen(organizationId: organizationId, currentUserData: currentUserData,))));
    } else {
      Navigator.push(
          context,
          SlideInRight(Dismissible(
            onDismissed: (_) => Navigator.of(context).pop(),
            direction: DismissDirection.startToEnd,
            key: const Key('AddEditGroupScreen'),
            child: AddEditGroupScreen(
                organizationId: organizationId, group: group, currentUserData: currentUserData,),
          )));
    }
  }

  static void navigateToViewGroupMembersScreen(
      List<String> memberUids, Group group, BuildContext context) {
    Navigator.push(
        context,
        SlideInRight(Dismissible(
            onDismissed: (_) => Navigator.of(context).pop(),
            direction: DismissDirection.startToEnd,
            key: const Key('viewGroupMembers'),
            child: ViewGroupMembers(memberUids: memberUids, group: group))));
  }

  static void navigateToEventMainScreen(
      BuildContext context, CurrentUserData currentUserData, String userRole) {
    Navigator.push(
        context,
        SlideInRight(EventMainScreen(

            currentUserData: currentUserData, userRole: userRole,subLevel: '',)));
  }

  static void navigateToAddEditEventScreen(BuildContext context,
      CurrentUserData currentUserData, String userRole, Event? event,String subLevel) {
    Navigator.push(
        context,
        SlideInRight(Dismissible(
          onDismissed: (_) => Navigator.of(context).pop(),
          direction: DismissDirection.startToEnd,
          key: const Key('AddEditEvent'),
          child: AddEditEventScreen(
              currentUserData: currentUserData,
              userRole: userRole,
              event: event,subLevel: subLevel),
        )));
  }

  static void navigateToEventDetail(
      BuildContext context,
      String userRole,
      Event event,
      String currentOrganizationId,
      CurrentUserData currentUserData,
      String subLevel,
      String? guestId
      ) {
    Navigator.push(
        context,
        SlideInRight(Dismissible(
          onDismissed: (_) => Navigator.of(context).pop(),
          direction: DismissDirection.startToEnd,
          key: const Key('eventDetail'),
          child: EventDetailScreen(
            event: event,
            userRole: userRole,
            currentOrganizationId: currentOrganizationId,
            currentUserData: currentUserData,
            subLevel: subLevel,
            guestId: guestId,
          ),
        )));
  }

  static void navigateToDeclineAttendUserListScreen(
      BuildContext context,
      List<String> declinedUids,
      List<String> attendingUids,
      List<ExternalUser> externalUsers,
      String currentOrganizationId,String eventId,CurrentUserData currentUserData) {
    Navigator.push(
        context,
        SlideInRight(Dismissible(
          onDismissed: (_) => Navigator.of(context).pop(),
          direction: DismissDirection.startToEnd,
          key: const Key('declineAttendUserList'),
          child: DeclineAttendUserListScreen(
            attendingUids: attendingUids,
            declinedUids: declinedUids,
            externalUsers: externalUsers,
            currentOrganizationId: currentOrganizationId,
            eventId: eventId,
            currentUserData: currentUserData,
          ),
        )));
  }

  static void navigateToEditProfile(
      BuildContext context, CurrentUserData userData) {
    Navigator.push(context, SlideInRight(Dismissible(

        key: Key('EditProfile'),
        direction: DismissDirection.startToEnd,
        onDismissed: (_) => Navigator.pop(context),
        child: EditProfile(userData: userData))));
  }

  static void navigateToAnnouncementDetail(
      BuildContext context, Announcement announcement,String uid) {
    Navigator.push(context,
        SlideInRight(Dismissible(

            key: Key('AnnouncementDetailScreen'),
            direction: DismissDirection.startToEnd,
            onDismissed: (_) => Navigator.pop(context),
            child: AnnouncementDetailScreen(announcement: announcement,uid: uid,))));
  }

  static void navigateToLanguageScreen(BuildContext context,Function updateUi) {
    Navigator.push(context, SlideInRight(Dismissible(
        key: Key('SelectLanguageScreen'),
        direction: DismissDirection.startToEnd,
        onDismissed: (_) => Navigator.pop(context),
        child: SelectLanguageScreen()))).then((value){
      updateUi();
    });
  }

  static void navigateToAddChannel(
      BuildContext context, String organizationId, Channel? channel) {
    Navigator.push(
        context,
        SlideInRight(
            Dismissible(
                key: Key('AddEditChannel'),
                direction: DismissDirection.startToEnd,
                onDismissed: (_) => Navigator.pop(context),
                child: AddEditChannel(organizationId: organizationId, channel: channel))));
  }

  static void navigateToGroupChatScreen(BuildContext context,
      String channelName,  String channelId,List<String> membersIds,CurrentUserData currentUserData) {
    final username=Utils.getUserName(currentUserData.userName, currentUserData.userSurname);
    final orgId=currentUserData.currentOrganizationId;
    final uid=currentUserData.uid;
    Navigator.push(context, SlideInRight(
        Dismissible(
          key: Key('GroupChatScreen'),
          direction: DismissDirection.startToEnd,
          onDismissed: (_) => Navigator.pop(context),
          child: GroupChatScreen(
              channelId: channelId, channelName: channelName,
          membersIds: membersIds,currentOrgId: orgId,currentUid: uid,currentUserName: username),
        )));
  }
  static void navigateToAddDocumentScreen(BuildContext context, CurrentUserData currentUserData) {
    Navigator.push(context, SlideInRight(Dismissible(
        key: Key('AddDocument'),
        direction: DismissDirection.startToEnd,
        onDismissed: (_) => Navigator.pop(context),
        child: AddDocument(currentUserData: currentUserData))));
  }

  static void navigateToResources(BuildContext context, CurrentUserData currentUserData, String userRole) {
    Navigator.push(context, SlideInRight(Dismissible(
        key: Key('OnlineLibrary'),
        direction: DismissDirection.startToEnd,
        onDismissed: (_) => Navigator.pop(context),
        child: OnlineLibrary(currentUserData: currentUserData,userRole: userRole))));
  }

  static void navigateToViewPdf(BuildContext context,Document document) {
    Navigator.push(context, SlideInRight(Dismissible(
        key: Key('ViewPdf'),
        direction: DismissDirection.startToEnd,
        onDismissed: (_) => Navigator.pop(context),
        child: ViewPdf(document: document))));
  }

  static void navigateToChannelMembersScreen(BuildContext context, List<String> membersIds, String currentOrganizationId) {
    Navigator.push(context, SlideInRight(Dismissible(
        key: Key('ViewChannelMembers'),
        direction: DismissDirection.startToEnd,
        onDismissed: (_) => Navigator.pop(context),
        child: ViewChannelMembers(memberUids: membersIds,organizationId: currentOrganizationId))));
  }

  static void navigateToSeenByScreen(BuildContext context, List<String> seenBy, String organizationId) {
    Navigator.push(context, SlideInRight(Dismissible(
        key: Key('ViewSeenByMembers'),
        direction: DismissDirection.startToEnd,
        onDismissed: (_) => Navigator.pop(context),
        child: ViewSeenByMembers(memberUids: seenBy,organizationId: organizationId))));

  }

  static void navigateToAddWorkTimeScreen(BuildContext context, CurrentUserData currentUserData) {
    Navigator.push(context, SlideInRight(Dismissible(
        key: Key('AddWorkTimeScreen'),
        direction: DismissDirection.startToEnd,
        onDismissed: (_) => Navigator.pop(context),
        child: AddWorkTimeScreen(currentUserData: currentUserData))));
  }

  static void navigateToGroupWorkTime(List<WorkTime> workTimes, BuildContext context,String groupName,String uid,String organizationId) {
    Navigator.push(context, SlideInRight(Dismissible(
        key: Key('ViewWorkTimeScreen'),
        direction: DismissDirection.startToEnd,
        onDismissed: (_) => Navigator.pop(context),
        child: ViewWorkTimeScreen(workTimes: workTimes,groupName: groupName,uid: uid,organizationId: organizationId,))));
  }

  static void navigateToViewPhotoScreen(BuildContext context, String message,String senderId) {
    Navigator.push(context, SlideInRight(Dismissible(
        key: Key('ViewPhotoScreen'),
        direction: DismissDirection.startToEnd,
        onDismissed: (_) => Navigator.pop(context),
        child: ViewPhotoScreen(photoUrl:message ,senderId: senderId))));
  }

  static void navigateToEventChatScreen(BuildContext context,CurrentUserData currentUserData,String eventId,String eventName) {
    Navigator.push(context, SlideInRight(Dismissible(
        onDismissed: (_) => Navigator.of(context).pop(),
        direction: DismissDirection.startToEnd,
        key: Key('ViewRecentUserActivity'),
        child: EventChatScreenNavigated(currentUserData: currentUserData,eventId: eventId,eventName: eventName,))));
  }

  static void navigateToRecentUserActivity(BuildContext context, CurrentUserData userToManage,String adminOrgId) {
    Navigator.push(context, SlideInRight(Dismissible(
        onDismissed: (_) => Navigator.of(context).pop(),
        direction: DismissDirection.startToEnd,
        key: Key('ViewRecentUserActivity'),
        child: ViewRecentUserActivity(adminOrgId: adminOrgId,userToManage: userToManage))));
  }

  static navigateToUseCodeScreen(BuildContext context, CurrentUserData currentUserData) {
    Navigator.push(context, SlideInRight(Dismissible(
        onDismissed: (_) => Navigator.of(context).pop(),
        direction: DismissDirection.startToEnd,
        key: Key('UseCodeToAddOrganization'),
        child: UseCodeToAddOrganization(currentUserData: currentUserData))));
  }

  static void navigateToSettings(BuildContext context, CurrentUserData currentUserData) {
    Navigator.push(context, SlideInRight(Dismissible(
        onDismissed: (_) => Navigator.of(context).pop(),
        direction: DismissDirection.startToEnd,
        key: Key('Settings'),
        child: Settings(currentUserData: currentUserData)))).then((value) => null);
  }

  static void navigateToPolls(BuildContext context, CurrentUserData currentUserData, String userRole) {
    Navigator.push(context, SlideInRight(Dismissible(
        onDismissed: (_) => Navigator.of(context).pop(),
        direction: DismissDirection.startToEnd,
        key: Key('ViewPollsScreen'),
        child: ViewPollsScreen(userRole: userRole,currentUserData: currentUserData))));
  }

  static void navigateToSurveys(BuildContext context, CurrentUserData currentUserData, String userRole) {
    Navigator.push(context, SlideInRight(Dismissible(
        onDismissed: (_) => Navigator.of(context).pop(),
        direction: DismissDirection.startToEnd,
        key: Key('ViewSurveysScreen'),
        child: ViewSurveysScreen(userRole: userRole,currentUserData: currentUserData))));

  }

  static void navigateToTasks(BuildContext context, CurrentUserData currentUserData, String userRole) {
    Navigator.push(context, SlideInRight(Dismissible(
        onDismissed: (_) => Navigator.of(context).pop(),
        direction: DismissDirection.startToEnd,
        key: Key('Task_screen'),
        child: TasksScreen(userRole: userRole,currentUserData: currentUserData))));
  }

  static void navigateToTaskDetail(BuildContext context, CurrentUserData currentUserData, Task task,TaskServices taskServices) {
    Navigator.push(context, SlideInRight(Dismissible(
        onDismissed: (_) => Navigator.of(context).pop(),
        direction: DismissDirection.startToEnd,
        key: Key('Task_detail'),
        child: TaskDetail(task: task,currentUserData: currentUserData,taskServices: taskServices,))));
  }

  static void navigateToAddEditTask(BuildContext context,CurrentUserData currentUserData, Task? task){
    Navigator.push(context, SlideInRight(
        Dismissible(
            onDismissed: (_) => Navigator.of(context).pop(),
            direction: DismissDirection.startToEnd,
            key: Key('Task_add_edit'),
            child: AddEditTaskScreen(currentUserData: currentUserData,task: task))));
  }

}
