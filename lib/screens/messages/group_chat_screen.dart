import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/dialog/edit_group_message.dart';
import 'package:firebase_calendar/dialog/select_image_dialog.dart';
import 'package:firebase_calendar/helper/save_file_mobile.dart';
import 'package:firebase_calendar/models/group_message.dart';
import 'package:firebase_calendar/services/count_service.dart';
import 'package:firebase_calendar/services/messages_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/sized_box.dart';
import '../../dialog/reply_dialog.dart';
import '../../models/channel.dart';

class GroupChatScreen extends StatefulWidget {
  final String channelId;
  final String channelName;
  final List<String> membersIds;
  final String currentUserName;
  final String currentUid;
  final String currentOrgId;
  List<RemovedUser>? removedUsers;

  GroupChatScreen(
      {Key? key,
      this.removedUsers,
      required this.channelId,
      required this.channelName,
      required this.membersIds,
      required this.currentUid,
      required this.currentOrgId,
      required this.currentUserName})
      : super(key: key);

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen>
    with WidgetsBindingObserver {
  //photo related fields
  File? imageFile;

  //file related fields
  Uint8List? fileBytes;
  String? fileDescription;
  int fileSize = 0;

  //message related fields
  final messageService = MessageService();
  late CountService countService;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String message = '';
  String lastMessage = 'last message';
  late Stream<List<GroupMessage>> getGroupMessages;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    final senderName = widget.currentUserName;
    if (lastMessage != 'last message') {
      messageService.uploadStartedGroupChat(
          widget.currentOrgId,
          widget.channelId,
          widget.channelName,
          lastMessage,
          widget.currentUid,
          senderName,
          widget.membersIds,
          countService);
    }

    super.dispose();
  }

  @override
  void initState() {
    countService = CountService(organizationId: widget.currentOrgId);
    countService.init();

    getGroupMessages = messageService.getGroupMessages(widget.channelId);
    messageService.setUnseenMessageToZeroForAGroup(
        widget.currentUid, widget.channelId, countService);
    Timer(
        Duration(milliseconds: 300),
        () => _scrollController.hasClients
            ? _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent)
            : null);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // --
        print('Resumed');
        break;
      case AppLifecycleState.inactive:
        // --
        print('Inactive');
        break;
      case AppLifecycleState.paused:
        final senderName = widget.currentUserName;
        if (lastMessage != 'last message') {
          messageService.uploadStartedGroupChat(
              widget.currentOrgId,
              widget.channelId,
              widget.channelName,
              lastMessage,
              widget.currentUid,
              senderName,
              widget.membersIds,
              countService);
        }
        print('Paused');
        break;
      case AppLifecycleState.detached:
        // --
        print('Detached');
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<MyProvider>(context);
    return BaseScaffold(
      appBarName: widget.channelName,
      body: buildBody(size, provider),
      shouldScroll: true,
    );
    //return buildScaffoldForChannels(widget.channelName, context, buildBody(), null);
  }

  Widget buildBody(Size size, MyProvider provider) {
    return StreamBuilder<List<GroupMessage>>(
      stream: getGroupMessages,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.length == 0) {
            return Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10),
                  height: size.height * 0.1,
                  width: size.width * 0.8,
                  decoration: BoxDecoration(
                      color: Constants.BACKGROUND_COLOR,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Center(
                    child: Text('This is the very beginning of your chat'.tr()),
                  ),
                ),
                Spacer(),
                chatInputWidget(context),
                SizedBoxWidget()
              ],
            );
          } else {
            final messages = snapshot.data;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController
                    .jumpTo(_scrollController.position.maxScrollExtent);
              } else {
                setState(() => null);
              }
            });
            return Column(
              children: [
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: groupedMessageView(messages!, provider)
                      // child:ListView.builder(
                      //       controller: _scrollController,
                      //       shrinkWrap: true,
                      //       physics: BouncingScrollPhysics(),
                      //       itemCount: messages!.length,
                      //       itemBuilder: (context, index) {
                      //         final message = messages[index];
                      //         final bool isNew = !message.isRead;
                      //         final bool toMe = message.senderId != widget.currentUid;
                      //         if (isNew && toMe) {
                      //           messageService.markGroupChatMessageAsRead(widget.channelId, message.messageId);
                      //         }
                      //         final bool isMe =
                      //             message.senderId == widget.currentUid;
                      //         return MessageTile(message: message, isMe: isMe, channelId: widget.channelId);
                      //       }),
                      ),
                ),
                chatInputWidget(context),
                SizedBoxWidget()
              ],
            );
          }
        } else if (snapshot.hasError) {
          return noDataWidget(snapshot.error.toString(), false);
        } else {
          return noDataWidget(null, true);
        }
      },
    );
  }

  bool isRemoved() {
    bool isRemoved = false;
    return isRemoved;
  }

  Widget groupedMessageView(List<GroupMessage> messages, MyProvider provider) {
    return GroupedListView<GroupMessage, String>(
        elements: messages,
        useStickyGroupSeparators: true,
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        floatingHeader: true,
        order: GroupedListOrder.ASC,
        itemComparator: (GroupMessage m1, GroupMessage m2) =>
            m1.createdAt.compareTo(m2.createdAt),
        groupBy: (GroupMessage element) => DateTime(element.createdAt.year,
                element.createdAt.month, element.createdAt.day)
            .toString(),
        groupHeaderBuilder: (element) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 30,
                    width: 140,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Constants.BACKGROUND_COLOR),
                    child: Center(
                        child: Text(
                      Utils.toDate(element.createdAt),
                      style:
                          appTextStyle.copyWith(color: Constants.BUTTON_COLOR),
                    ))),
              ],
            ),
        indexedItemBuilder: (context, _, index) {
          final message = messages[index];
          final bool isNew = !message.isRead;
          final bool toMe = message.senderId != widget.currentUid;
          if (isNew && toMe) {
            messageService.markGroupChatMessageAsRead(
                widget.channelId, message.messageId);
          }
          final bool isMe = message.senderId == widget.currentUid;
          return SwipeTo(
              onRightSwipe: (_) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return ReplyDialog(
                          messageToReply: message,
                          channelId: widget.channelId,
                          senderId: widget.currentUid,
                          senderName: widget.currentUserName);
                    });
              },
              child: MessageTile(
                message: message,
                isMe: isMe,
                channelId: widget.channelId,
                provider: provider,
              ));
        });
  }

  Future sendGroupMessage() async {
    final senderName = widget.currentUserName;
    await messageService.uploadGroupChat(
        widget.channelId, widget.currentUid, senderName, message);
    _controller.clear();
    lastMessage = message;
    setState(() {
      message = '';
    });
    Timer(
        Duration(milliseconds: 300),
        () => _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent));
  }

  Future sendPhoto() async {
    final senderName = widget.currentUserName;
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SelectImageSourceDialog(
              selectedImage: (onImageSelected onSelected) async {
            messageService.uploadPhotoGroupMessage(widget.channelId,
                widget.currentUid, senderName, onSelected.imageFile!);
          });
        }).then((value) => null);
  }

  Future sendFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(withData: true);

    if (result != null) {
      fileBytes = result.files.first.bytes;
      PlatformFile file = result.files.first;
      fileSize = file.size;
      fileDescription = file.name;

      print(fileBytes);
      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
    } else {
      Utils.showToastWithoutContext('No file selected'.tr());
      return;
    }
    if (fileSize >= 1000000) {
      Utils.showSnackBar(context, 'Max file size allowed is 1 Mb'.tr());
      return;
    } else {
      Utils.showToastWithoutContext('Sending'.tr());
      await messageService.sendFile(widget.channelId, fileDescription!,
          fileBytes!, widget.currentUserName, widget.currentUid);
    }
  }

  ///bottom send message bar
  Widget chatInputWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20 * 0.75),
        decoration: BoxDecoration(
          border: Border.all(
            color: Constants.BACKGROUND_COLOR,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(40),
          // boxShadow: [
          //   BoxShadow(
          //       offset: Offset(0, 4),
          //       blurRadius: 32,
          //       color: Colors.black.withOpacity(0.1))
          // ]
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(width: 5),
            Expanded(
                child: TextField(
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 8,
              textInputAction: TextInputAction.newline,
              controller: _controller,
              onChanged: (value) {
                if (value.trim().length <= 1) {
                  setState(() {
                    message = value;
                  });
                } else {
                  message = value;
                }
              },
              decoration: InputDecoration(
                  hintText: 'Type message'.tr(), border: InputBorder.none),
            )),
            IconButton(
              onPressed: message.trim().isEmpty ? null : sendGroupMessage,
              icon: Icon(Icons.send),
              color: Constants.BUTTON_COLOR,
            ),
            IconButton(
              onPressed: sendPhoto,
              icon: Icon(Icons.photo),
              color: Constants.BUTTON_COLOR,
            ),
            IconButton(
              onPressed: sendFile,
              icon: Icon(Icons.attach_file),
              color: Constants.BUTTON_COLOR,
            )
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final GroupMessage message;
  final bool isMe;
  final String channelId;
  final MyProvider provider;
  const MessageTile(
      {Key? key,
      required this.message,
      required this.isMe,
      required this.channelId,
      required this.provider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final url = provider.getUserById(message.senderId).userUrl;
    String time = Utils.toTime(message.createdAt);
    final leftPadding = size.width * 0.1;
    Widget widget = Container();
    final radius = !isMe
        ? BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          );

    if (message.repliedMessage != '') {
      if (message.repliedMessage
          .startsWith('https://firebasestorage.googleapis.com')) {
        widget = Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisAlignment:
                    isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if (!isMe) ...[
                    Container(
                        margin: EdgeInsets.only(top: 20),
                        child:
                            CircleAvatar(backgroundImage: NetworkImage(url))),
                  ],
                  SizedBox(width: 5),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(top: 20),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                          color: isMe
                              ? Constants.BUTTON_COLOR
                              : Constants.BACKGROUND_COLOR,
                          borderRadius: radius),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            Text(message.senderName,
                                style:
                                    appTextStyle.copyWith(color: Colors.cyan))
                          ],
                          SizedBox(height: 3),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                                color: Constants.CONTAINER_COLOR,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                VerticalDivider(
                                    width: 30,
                                    thickness: 5,
                                    color: Constants.CANCEL_COLOR),
                                ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    child: CachedNetworkImage(
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      imageUrl: message.repliedMessage,
                                      placeholder: (context, url) => Align(
                                          child:
                                              new CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          new Icon(Icons.error),
                                    )),
                                Icon(Icons.photo),
                                Text(
                                  'Photo'.tr(),
                                  style: appTextStyle,
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Linkify(
                            linkStyle: TextStyle(
                                color: isMe ? Colors.white : Colors.black87),
                            onOpen: (link) async {
                              if (await canLaunch(link.url)) {
                                await launch(link.url);
                              } else {
                                throw 'Could not launch';
                              }
                            },
                            text: message.message,
                            style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87),
                            maxLines: 10,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment:
                    isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: isMe
                        ? const EdgeInsets.only(right: 5.0)
                        : EdgeInsets.only(left: leftPadding),
                    child: Text(
                      time,
                      style: appTextStyle.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      } else {
        widget = Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisAlignment:
                    isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if (!isMe) ...[
                    Container(
                        margin: EdgeInsets.only(top: 20),
                        child:
                            CircleAvatar(backgroundImage: NetworkImage(url))),
                  ],
                  SizedBox(width: 5),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(top: 20),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                          color: isMe
                              ? Constants.BUTTON_COLOR
                              : Constants.BACKGROUND_COLOR,
                          borderRadius: radius),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            Text(message.senderName,
                                style:
                                    appTextStyle.copyWith(color: Colors.cyan))
                          ],
                          SizedBox(height: 3),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                                color: Constants.CONTAINER_COLOR,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                VerticalDivider(
                                    width: 30,
                                    thickness: 5,
                                    color: Constants.CANCEL_COLOR),
                                Container(
                                    width: size.width * 0.6,
                                    height: 60,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(message.repliedMessage,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Linkify(
                            linkStyle: TextStyle(
                                color: isMe ? Colors.white : Colors.black87),
                            onOpen: (link) async {
                              if (await canLaunch(link.url)) {
                                await launch(link.url);
                              } else {
                                throw 'Could not launch';
                              }
                            },
                            text: message.message,
                            style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87),
                            maxLines: 10,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment:
                    isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: isMe
                        ? const EdgeInsets.only(right: 5.0)
                        : EdgeInsets.only(left: leftPadding),
                    child: Text(
                      time,
                      style: appTextStyle.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }
    } else
      switch (message.messageType) {
        case 'text':
          widget = Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isMe) ...[
                      Container(
                          margin: EdgeInsets.only(top: 20),
                          child:
                              CircleAvatar(backgroundImage: NetworkImage(url))),
                    ],
                    SizedBox(width: 5),
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                            color: isMe
                                ? Constants.BUTTON_COLOR
                                : Constants.BACKGROUND_COLOR,
                            borderRadius: radius),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe) ...[
                              Text(message.senderName,
                                  style:
                                      appTextStyle.copyWith(color: Colors.cyan))
                            ],
                            SizedBox(height: 5),
                            Linkify(
                              linkStyle: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87),
                              onOpen: (link) async {
                                if (await canLaunch(link.url)) {
                                  await launch(link.url);
                                } else {
                                  throw 'Could not launch';
                                }
                              },
                              text: message.message,
                              style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87),
                              maxLines: 10,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: isMe
                          ? const EdgeInsets.only(right: 5.0)
                          : EdgeInsets.only(left: leftPadding),
                      child: Text(
                        time,
                        style: appTextStyle.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
          break;
        case 'photo':
          widget = Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isMe) ...[
                      CircleAvatar(backgroundImage: NetworkImage(url)),
                    ],
                    SizedBox(width: 5),
                    Container(
                      height: 220,
                      width: size.width * 0.7,
                      decoration: BoxDecoration(
                          color: isMe
                              ? Constants.BUTTON_COLOR
                              : Constants.BACKGROUND_COLOR,
                          borderRadius: radius),
                      child: GestureDetector(
                        onTap: () {
                          Navigation.navigateToViewPhotoScreen(
                              context, message.message, message.senderId);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: message.message,
                                placeholder: (context, url) => Align(
                                    child: new CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    new Icon(Icons.error),
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: isMe
                          ? const EdgeInsets.only(right: 5.0)
                          : EdgeInsets.only(left: leftPadding),
                      child: Text(
                        time,
                        style: appTextStyle.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
          break;
        case 'file':
          widget = Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isMe) ...[
                      CircleAvatar(backgroundImage: NetworkImage(url)),
                    ],
                    SizedBox(width: 5),
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                            color: isMe
                                ? Constants.BUTTON_COLOR
                                : Constants.BACKGROUND_COLOR,
                            borderRadius: radius),
                        child: GestureDetector(
                            onTap: () {
                              Utils.showToastWithoutContext('Downloading'.tr());
                              Utils.downloadFileForGroupMessage(message.message,
                                      message.messageDescription)
                                  .then((value) async {
                                await FileSaveHelper.saveAndLaunchFile(
                                    value, message.messageDescription);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.file_download,
                                    size: 30,
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                  Text(
                                    message.messageDescription,
                                    style: appTextStyle.copyWith(
                                        color:
                                            isMe ? Colors.white : Colors.black),
                                  )
                                ],
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: isMe
                          ? const EdgeInsets.only(right: 5.0)
                          : EdgeInsets.only(left: leftPadding),
                      child: Text(
                        time,
                        style: appTextStyle.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
      }
    return GestureDetector(
        onLongPress: isMe && message.message != 'Deleted'
            ? () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return EditGroupMessageBottomSheet(
                        groupMessage: message,
                        channelId: channelId,
                      );
                    });
              }
            : () {},
        child: widget);
  }
}

class CustomChatBubble extends CustomPainter {
  final Color bgColor;

  CustomChatBubble(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;

    var path = Path();
    path.lineTo(-5, 0);
    path.lineTo(0, 10);
    path.lineTo(5, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
