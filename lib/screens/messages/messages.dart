import 'package:badges/badges.dart' as Badge;
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/anim/bouncy_page_route.dart';
import 'package:firebase_calendar/anim/slide_in_right.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_with_title.dart';
import 'package:firebase_calendar/models/created_chats.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/started_group_chat.dart';
import 'package:firebase_calendar/screens/messages/chat_screen.dart';
import 'package:firebase_calendar/services/count_service.dart';
import 'package:firebase_calendar/services/messages_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';

//ignore:must_be_immutable
class StartedChats extends StatefulWidget {
  final CurrentUserData userData;
  final MessageService messageService;
  final int totalPrivateChatUnseenMessage;
  final int totalChannelUnseenMessage;
  final List<CreatedChats> createdChats;
  final List<StartedGroupChat> startedGroupChats;

  StartedChats(
      {Key? key,
      required this.userData,
      required this.messageService,
      required this.totalPrivateChatUnseenMessage,
      required this.totalChannelUnseenMessage,
      required this.createdChats,
      required this.startedGroupChats})
      : super(key: key);

  @override
  State<StartedChats> createState() => _StartedChatsState();
}

class _StartedChatsState extends State<StartedChats> {
  List<String> items = ['Direct messages'.tr(), 'Channels'.tr()];

  late Stream<List<CreatedChats>> getCreatedChats;
  late Stream<List<StartedGroupChat>> getStartedChats;
  late CountService countService;

  @override
  void initState() {
    countService =
        CountService(organizationId: widget.userData.currentOrganizationId);
    countService.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int totalPrivateChatUnseenMessage = widget.totalPrivateChatUnseenMessage;
    int totalChannelUnseenMessage = widget.totalChannelUnseenMessage;
    List<CreatedChats> createdChats = widget.createdChats;
    List<StartedGroupChat> createdGroupChats = widget.startedGroupChats;
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ExpansionPanelList.radio(
              children: items
                  .map((e) => ExpansionPanelRadio(
                      value: e.length,
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          title: Text(
                            e.tr(),
                            style: appTextStyle,
                          ),
                          trailing: e == 'Direct messages'.tr()
                              ? Badge.Badge(
                                  badgeContent: Text(
                                    totalPrivateChatUnseenMessage.toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : Badge.Badge(
                                  badgeContent: Text(
                                    totalChannelUnseenMessage.toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                        );
                      },
                      body: e == 'Direct messages'.tr()
                          ? buildPrivateChats(createdChats)
                          : buildChannelChats(context, createdGroupChats)))
                  .toList()),
        ),
      ),
    );
  }

  Widget buildPrivateChats(List<CreatedChats> chats) {
    //final chats = createdChats;
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: chats.length,
        itemBuilder: (context, index) {
          return PersonTile(
            currentUserData: widget.userData,
            chat: chats[index],
            service: widget.messageService,
            countService: countService,
          );
        });
  }

  Widget buildChannelChats(BuildContext context, List<StartedGroupChat> chats) {
    //final chats=startedGroupChats;
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: chats.length,
        itemBuilder: (_, index) {
          final startedChat = chats[index];
          return buildChannels(startedChat, context);
        });
  }

  Widget buildChannels(StartedGroupChat chat, BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return BlurryDialogWithTitle(
                  title: 'Delete this inbox chat?'.tr(),
                  content: 'Your messages will not be deleted'.tr(),
                  continueCallBack: () {
                    Navigator.pop(context);
                    widget.messageService.deleteInboxGroupChat(
                        widget.userData.uid,
                        widget.userData.currentOrganizationId,
                        chat.channelId,
                        countService);
                  });
            });
      },
      onTap: () {
        Navigation.navigateToGroupChatScreen(context, chat.channelName,
            chat.channelId, chat.membersIds, widget.userData);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        color: Constants.CONTAINER_COLOR,
        child: ListTile(
          title: Text(chat.channelName,
              style: appTextStyle.copyWith(
                  fontWeight: FontWeight.bold, fontSize: 20)),
          subtitle: Text(
            '${chat.senderName}: ${chat.lastMessage}',
            style: appTextStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                Text(Utils.toTime(chat.createdAt),
                    style: appTextStyle.copyWith(
                        fontSize: 12,
                        color: chat.unseenMessageCount == 0
                            ? Colors.black
                            : Constants.CANCEL_COLOR)),
                SizedBox(
                  height: 5,
                ),
                Badge.Badge(
                  badgeContent: Text(
                    chat.unseenMessageCount.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///people tile
class PersonTile extends StatelessWidget {
  final CurrentUserData currentUserData;
  final CreatedChats chat;
  final MessageService service;
  final CountService countService;
  const PersonTile(
      {Key? key,
      required this.chat,
      required this.currentUserData,
      required this.service,
      required this.countService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context);
    int messageCount = chat.unseenMessageCount;
    final chattedUserData = provider.getUserById(chat.chattedUserUid);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      color: Constants.CONTAINER_COLOR,
      child: ListTile(
          onLongPress: () {
            showDialog(
                context: context,
                builder: (context) {
                  return BlurryDialogWithTitle(
                      title: 'Delete this inbox chat?'.tr(),
                      content: 'Your messages will not be deleted'.tr(),
                      continueCallBack: () {
                        Navigator.pop(context);
                        service.deleteInboxMessage(
                            currentUserData.currentOrganizationId,
                            currentUserData.uid,
                            chat.roomId,
                            countService);
                      });
                });
          },
          onTap: () {
            Navigator.push(
                context,
                SlideInRight(ChatScreen(
                  senderOrgId: currentUserData.currentOrganizationId,
                  currentUserData: currentUserData,
                  roomName: chat.roomId,
                  chattedUserUid: chat.chattedUserUid,
                  url: chattedUserData.userUrl,
                  userName: Utils.getUserName(
                      chattedUserData.userName, chattedUserData.userSurname),
                )));
          },
          leading: CircleAvatar(
            backgroundImage: NetworkImage(chattedUserData.userUrl),
          ),
          title: Text(
            '${Utils.getUserName(chattedUserData.userName, chattedUserData.userSurname)}',
            style: appTextStyle.copyWith(
                fontWeight: FontWeight.bold, fontSize: 20),
          ),
          subtitle: Text(
            '${chat.lastMessage}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: messageCount != 0
              ? Badge.Badge(
                  badgeContent: Text(
                    messageCount.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : null),
    );
  }
}
