import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/config/key_config.dart';
import 'package:firebase_calendar/models/channel.dart';
import 'package:firebase_calendar/models/created_chats.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/group_message.dart';
import 'package:firebase_calendar/models/message.dart';
import 'package:firebase_calendar/models/started_group_chat.dart';
import 'package:firebase_calendar/services/count_service.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:uuid/uuid.dart';

class MessageService {
  final userRef = Configuration.isProduction
      ? FirebaseFirestore.instance.collection('users')
      : FirebaseFirestore.instance.collection('users_test');
  final channelRef = Configuration.isProduction
      ? FirebaseFirestore.instance.collection('channels')
      : FirebaseFirestore.instance.collection('channels_test');

  //gets all the users
  List<CurrentUserData> _listAppUsersFromSnapShot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((e) {
      return CurrentUserData.fromMap(e.data());
    }).toList();
  }

  Stream<List<CurrentUserData>> getAllUsers(String organizationId) {
    return userRef
        .where('adminRegistry', arrayContains: {
          'organizationId': organizationId,
          'isApproved': true
        })
        .snapshots()
        .map(_listAppUsersFromSnapShot);
  }

  //gets messages for specific room
  List<Message> _messagesFromSnapShot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) {
      return Message.fromMap(doc.data());
    }).toList();
  }

  Stream<List<Message>> getMessages(String roomName,String orgId) {
    return Configuration.isProduction
        ? FirebaseFirestore.instance
            .collection('chats/$orgId/$roomName')
            .orderBy('createdAt', descending: false)
            .snapshots()
            .map(_messagesFromSnapShot)
        : FirebaseFirestore.instance
            .collection('chats_test/$orgId/$roomName')
            .orderBy('createdAt', descending: false)
            .snapshots()
            .map(_messagesFromSnapShot);
    ;
  }

  //streams started chats for specific user
  Stream<List<CreatedChats>> getCreatedChats(String uid, String orgId) {
    return Configuration.isProduction
        ? FirebaseFirestore.instance
            .collection('userRoom/$orgId/$uid')
            .where('organizationId', isEqualTo: orgId)
            .snapshots()
            .map((snapShots) {
            return snapShots.docs.map((e) {
              return CreatedChats.fromMap(e.data());
            }).toList();
          })
        : FirebaseFirestore.instance
            .collection('userRoom_test/$orgId/$uid')
            .where('organizationId', isEqualTo: orgId)
            .snapshots()
            .map((snapShots) {
            return snapShots.docs.map((e) {
              return CreatedChats.fromMap(e.data());
            }).toList();
          });
  }

  ///creates userRoom collection and saves started chats for specific user
  Future uploadStartedChat(
      String curUid,
      String? curUrl,
      String curName,
      String roomId,
      String chattedUid,
      String lastMessage,
      String orgId,CountService countService) async {
    final messageList = Configuration.isProduction
        ? await FirebaseFirestore.instance
        .collection('chats/$orgId/$roomId')
        .where('isRead', isEqualTo: false)
        .where('idUser', isEqualTo: curUid)
        .get()
        : await FirebaseFirestore.instance
        .collection('chats_test/$orgId/$roomId')
        .where('isRead', isEqualTo: false)
        .where('idUser', isEqualTo: curUid)
        .get();
    final length = messageList.docs.length;

    final curUserRoom = Configuration.isProduction
        ? FirebaseFirestore.instance.collection('userRoom/$orgId/$curUid/')
        : FirebaseFirestore.instance.collection('userRoom_test/$orgId/$curUid/');

    curUserRoom.doc(roomId).set({
      'chattedUserUid': chattedUid,
      'lastMessage': lastMessage,
      'chattedUserName': 'chattedName',
      'chattedUserUrl': 'chattedUrl',
      'roomId': roomId,
      'unseenMessageCount': 0,
      'organizationId': orgId
    });

    final chattedUserRom = Configuration.isProduction
        ? FirebaseFirestore.instance.collection('userRoom/$orgId/$chattedUid')
        : FirebaseFirestore.instance
        .collection('userRoom_test/$orgId/$chattedUid');



    ///this part is for count
    // final ref = Configuration.isProduction
    //     ? FirebaseFirestore.instance.collection('userRoom/$orgId/$chattedUid/')
    //     : FirebaseFirestore.instance.collection('userRoom_test/$orgId/$chattedUid/');


    final docForCount=await chattedUserRom.doc(roomId).get();
    int? messageCount=docForCount.data()?['unseenMessageCount'];

    int difference=messageCount==null ? length:(messageCount-length);

    if(difference==0){
      difference=1;
    }
    print('message count ${messageCount}');
    print('length is $length');
    print('difference is ${difference.abs()}');
    print('uid is $chattedUid');

    countService.updateMessageCountOnReceived(chattedUid, difference.abs());
    // //count

    chattedUserRom.doc(roomId).set({
      'chattedUserUid': curUid,
      'lastMessage': lastMessage,
      'chattedUserName': curName,
      'chattedUserUrl': curUrl,
      'roomId': roomId,
      'unseenMessageCount': length,
      'organizationId': orgId
    });

  }


  ///streams created group for specific user chats...
  Stream<List<StartedGroupChat>> getStartedGroupChats(
      String uid, String orgId) {
    return Configuration.isProduction
        ? FirebaseFirestore.instance
            .collection('userRoom/$uid/groupChat')
            .where('organizationId', isEqualTo: orgId)
            .snapshots()
            .map((event) {
            return event.docs.map((e) {
              return StartedGroupChat.fromMap(e.data());
            }).toList();
          })
        : FirebaseFirestore.instance
            .collection('userRoom_test/$uid/groupChat')
            .where('organizationId', isEqualTo: orgId)
            .snapshots()
            .map((event) {
            return event.docs.map((e) {
              return StartedGroupChat.fromMap(e.data());
            }).toList();
          });
  }

  ///streams group chat  for a specific channel based on channel id;
  List<GroupMessage> _groupChatFromSnapShot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) {
      return GroupMessage.fromMap(doc.data());
    }).toList();
  }

  Stream<List<GroupMessage>> getGroupMessages(String channelId) {
    return Configuration.isProduction
        ? FirebaseFirestore.instance
            .collection('groupChats/$channelId/messages')
            .orderBy('createdAt', descending: false)
            .snapshots()
            .map(_groupChatFromSnapShot)
        : FirebaseFirestore.instance
            .collection('groupChats_test/$channelId/messages')
            .orderBy('createdAt', descending: false)
            .snapshots()
            .map(_groupChatFromSnapShot);
  }




  ///uploads a group chat to specific user
  Future uploadStartedGroupChat(
      String organizationId,
      String channelId,
      String channelName,
      String lastMessage,
      String senderId,
      String senderName,
      List<String> memberUids,CountService countService) async {
    final messageList = Configuration.isProduction
        ? await FirebaseFirestore.instance
            .collection('groupChats/$channelId/messages')
            .where('isRead', isEqualTo: false)
            .where('senderId', isEqualTo: senderId)
            .get()
        : await FirebaseFirestore.instance
            .collection('groupChats_test/$channelId/messages')
            .where('isRead', isEqualTo: false)
            .where('senderId', isEqualTo: senderId)
            .get();

    final length = messageList.docs.length;

    memberUids.forEach((uid) async{
      if (uid == senderId) {
        final meRef = Configuration.isProduction
            ? FirebaseFirestore.instance.collection('userRoom/$uid/groupChat')
            : FirebaseFirestore.instance
                .collection('userRoom_test/$uid/groupChat');

        meRef.doc(channelId).set({
          'organizationId': organizationId,
          'channelId': channelId,
          'channelName': channelName,
          'lastMessage': lastMessage,
          'senderId': senderId,
          'senderName': senderName,
          'membersIds': memberUids,
          'unseenMessageCount': 0,
          'createdAt': DateTime.now(),
        });
      } else {
        final otherRef = Configuration.isProduction
            ? FirebaseFirestore.instance.collection('userRoom/$uid/groupChat')
            : FirebaseFirestore.instance
                .collection('userRoom_test/$uid/groupChat');

        ///this part is for count
        final docForCount=await otherRef.doc(channelId).get();
        int? messageCount=docForCount.data()?['unseenMessageCount'];
        int difference=messageCount==null?length:(messageCount-length);

        if(difference==0){
          difference=1;
        }
        print('message count $messageCount');
        print('length is $length');
        print('difference is ${difference.abs()}');
        print('uid is $uid');
        countService.updateGroupMessageCountOnReceived(uid, difference.abs());
        // //count

        otherRef.doc(channelId).set({
          'organizationId': organizationId,
          'channelId': channelId,
          'channelName': channelName,
          'lastMessage': lastMessage,
          'senderId': senderId,
          'senderName': senderName,
          'membersIds': memberUids,
          'unseenMessageCount': length,
          'createdAt': DateTime.now(),
        });


      }
    });
  }

  ///marks the specific message as isRead=true
  Future markAsRead(String roomName, String messageId,String orgId) async {
    final ref = Configuration.isProduction
        ? FirebaseFirestore.instance.collection('chats/$orgId/$roomName/')
        : FirebaseFirestore.instance
            .collection('chats_test/$orgId/$roomName/');
    ref.doc(messageId).update({'isRead': true});
  }

  ///marks the specific group chat message as isRead=true
  Future markGroupChatMessageAsRead(String channelId, String messageId) async {
    final ref = Configuration.isProduction
        ? FirebaseFirestore.instance
            .collection('groupChats/$channelId/messages')
        : FirebaseFirestore.instance
            .collection('groupChats_test/$channelId/messages');
    ref.doc(messageId).update({'isRead': true});
  }

  ///sets unseen message count to zero after chat screen is opened
  Future setUnseenMessageToZero(String idUser, String roomId,String orgId,CountService countService) async {
    final ref = Configuration.isProduction
        ? FirebaseFirestore.instance.collection('userRoom/$orgId/$idUser/')
        : FirebaseFirestore.instance.collection('userRoom_test/$orgId/$idUser/');
    //for count
    final docForCount=await ref.doc(roomId).get();
    int messageCount=docForCount.data()!['unseenMessageCount'];
    print('unseen message count ${messageCount}');
    countService.updateMessageCountOnRead(idUser, messageCount);
    //for count
    ref.doc(roomId).update({'unseenMessageCount': 0});

  }

  ///sets unseen message count to zero after chat screen is opened for group chat

  Future setUnseenMessageToZeroForAGroup(
      String idUser, String channelId,CountService countService) async {
    final ref = Configuration.isProduction
        ? FirebaseFirestore.instance.collection('userRoom/$idUser/groupChat/')
        : FirebaseFirestore.instance
            .collection('userRoom_test/$idUser/groupChat/');

    //for count
    final docForCount=await ref.doc(channelId).get();
    int messageCount=docForCount.data()!['unseenMessageCount'];
    print('unseen message count for group ${messageCount}');
    countService.updateGroupMessageCountOnRead(idUser, messageCount);
    //for count

    ref.doc(channelId).update({'unseenMessageCount': 0});

  }

  ///uploads a message to a specific chat room with current organization id..
  Future uploadMessage(String roomId, String message, String currentUserId,
      String messageBy, String chattedUserId,String orgId,String senderUrl) async {
    final refMessages = Configuration.isProduction
        ? FirebaseFirestore.instance.collection('chats/$orgId/$roomId')
        : FirebaseFirestore.instance.collection('chats_test/$orgId/$roomId');

    try {
      String messageId = Uuid().v1().toString();
      final newMessage = Message(
          messageId: messageId,
          idUser: currentUserId,
          receiverId: chattedUserId,
          senderId: senderUrl,
          username: messageBy,
          message: message,
          createdAt: DateTime.now(),
          isRead: false,
          senderOrgId: orgId
      );
      await refMessages.doc(messageId).set(newMessage.toMap());
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  ///uploads a group chat message...
  Future uploadGroupChat(String channelId, String senderId, String senderName,
      String message) async {
    final groupChatRef = Configuration.isProduction
        ? FirebaseFirestore.instance
            .collection('groupChats/$channelId/messages')
        : FirebaseFirestore.instance
            .collection('groupChats_test/$channelId/messages');

    try {
      String messageId = Uuid().v1().toString();
      final groupMessage = GroupMessage(
          messageId: messageId,
          message: message,
          senderId: senderId,
          senderName: senderName,
          isRead: false,
          createdAt: DateTime.now(),
          messageType: 'text',
          messageDescription: 'text uploaded',
          repliedMessage: ''
      );
      groupChatRef.doc(messageId).set(groupMessage.toMap());
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  Future uploadPhotoGroupMessage(
      String channelId, String senderId, String senderName, File file) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    final groupChatRef = Configuration.isProduction
        ? FirebaseFirestore.instance
            .collection('groupChats/$channelId/messages')
        : FirebaseFirestore.instance
            .collection('groupChats_test/$channelId/messages');

    Utils.showToastWithoutContext('Sending'.tr());
    String message = '';
    final messageId = Uuid().v4().toString();

    await uploadGroupMessagePhoto(messageId, file)
        .then((value) => message = value);
    final groupMessage = GroupMessage(
        messageId: messageId,
        message: message,
        senderId: senderId,
        senderName: senderName,
        isRead: false,
        createdAt: DateTime.now(),
        messageType: 'photo',
        messageDescription: 'photo uploaded',
        repliedMessage: ''
    );
    groupChatRef.doc(messageId).set(groupMessage.toMap());
  }

  Future<String> uploadGroupMessagePhoto(String messageId, File file) async {
    var reference = FirebaseStorage.instance
        .ref()
        .child('groupChatPhotos')
        .child('$messageId');
    final UploadTask uploadTask = reference.putFile(file);
    final TaskSnapshot downloadUrl = (await uploadTask);
    final url = await downloadUrl.ref.getDownloadURL();
    return url;
  }

  ///stream all created channel for specific organization
  Stream<List<Channel>> getChannels(String orgId) {
    return channelRef
        .where('organizationId', isEqualTo: orgId)
        .snapshots()
        .map((snapShots) {
      return snapShots.docs.map((e) {
        return Channel.fromMap(e.data());
      }).toList();
    });
  }

  ///creates a channel for a specific organization
  Future createChannel(String organizationId, String channelName,
      List<String> membersIds, BuildContext context) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    try {
      final String channelId = Uuid().v1().toString();
      final channel = Channel(
          organizationId: organizationId,
          channelId: channelId,
          channelName: channelName,
          membersIds: membersIds,
          createdAt: DateTime.now());
      channelRef.doc(channelId).set(channel.toMap());
      Navigator.pop(context);
      Utils.showToastWithoutContext('Channel created'.tr());
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  Future sendFile(String channelId, String messageDescription,
      Uint8List fileBytes, String senderName, String senderId) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    final groupChatRef = Configuration.isProduction
        ? FirebaseFirestore.instance
            .collection('groupChats/$channelId/messages')
        : FirebaseFirestore.instance
            .collection('groupChats_test/$channelId/messages');
    String message = '';
    final messageId = Uuid().v4().toString();
    await uploadFile(messageId, fileBytes).then((value) => message = value);
    final groupMessage = GroupMessage(
        messageId: messageId,
        message: message,
        senderId: senderId,
        senderName: senderName,
        isRead: false,
        createdAt: DateTime.now(),
        messageType: 'file',
        messageDescription: messageDescription,
        repliedMessage: ''
    );
    groupChatRef.doc(messageId).set(groupMessage.toMap());
  }

  Future<String> uploadFile(String messageId, Uint8List fileBytes) async {
    var reference = FirebaseStorage.instance
        .ref()
        .child('uploadedGroupChatDocuments')
        .child('$messageId');
    final UploadTask uploadTask = reference.putData(fileBytes);
    final TaskSnapshot downloadUrl = (await uploadTask);
    final String url = await downloadUrl.ref.getDownloadURL();
    return url;
  }

  Future deleteGroupMessage(
      String channelId, String messageId, String messageType) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    final groupChatRef = Configuration.isProduction
        ? FirebaseFirestore.instance
            .collection('groupChats/$channelId/messages')
        : FirebaseFirestore.instance
            .collection('groupChats_test/$channelId/messages');

    await groupChatRef
        .doc(messageId)
        .update({'message': 'Deleted', 'messageType': 'text'});
    if (messageType == 'photo') {
      var reference = FirebaseStorage.instance
          .ref()
          .child('groupChatPhotos')
          .child('$messageId');
      reference.delete();
    } else if (messageType == 'file') {
      var reference = FirebaseStorage.instance
          .ref()
          .child('uploadedGroupChatDocuments')
          .child('$messageId');
      reference.delete();
    }
  }

  Future updateGroupTextMessage(
      String channelId, String messageId, String text) async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    final groupChatRef = Configuration.isProduction
        ? FirebaseFirestore.instance
            .collection('groupChats/$channelId/messages')
        : FirebaseFirestore.instance
            .collection('groupChats_test/$channelId/messages');
    await groupChatRef.doc(messageId).update({'message': text});
  }


  Future updateDirectMessage(String roomId, String messageId, String messageToBeSent,String senderOrgId) async{
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }
    print(senderOrgId);
    print(roomId);
    print(messageId);
    final refMessages = Configuration.isProduction
        ? FirebaseFirestore.instance.collection('chats/$senderOrgId/$roomId/')
        : FirebaseFirestore.instance.collection('chats_test/$senderOrgId/$roomId/');
   await  refMessages.doc(messageId).update({
      'message':messageToBeSent,

    });
  }

  Future sendReply(String channelId, String senderId, String senderName,
      String message,String repliedMessage,String messageType) async{

    final groupChatRef = Configuration.isProduction
        ? FirebaseFirestore.instance
        .collection('groupChats/$channelId/messages')
        : FirebaseFirestore.instance
        .collection('groupChats_test/$channelId/messages');
    try {
      String messageId = Uuid().v1().toString();
      final groupMessage = GroupMessage(
          messageId: messageId,
          message: message,
          senderId: senderId,
          senderName: senderName,
          isRead: false,
          createdAt: DateTime.now(),
          messageType: 'text',
          messageDescription: 'text uploaded',
          repliedMessage: repliedMessage
      );
      groupChatRef.doc(messageId).set(groupMessage.toMap());
    } catch (e) {
      Utils.showErrorToast();
    }
  }

  Future deleteInboxMessage(String orgId,String curUid,
      String roomId,CountService countService) async{

    try {
      final curUserRoom = Configuration.isProduction
          ? FirebaseFirestore.instance.collection('userRoom/$orgId/$curUid')
          : FirebaseFirestore.instance.collection('userRoom_test/$orgId/$curUid');

      //for count
      final docForCount=await curUserRoom.doc(roomId).get();
      int messageCount=docForCount.data()!['unseenMessageCount'];
      print('unseen message count for group on delete ${messageCount}');
      countService.updateMessageCountOnDelete(curUid, messageCount);
      //for count

      await curUserRoom.doc(roomId).delete();
    } on Exception catch (e) {
    }
  }


  Future deleteInboxGroupChat(String uid,
      String currentOrganizationId, String channelId,CountService countService) async{
    try {
      final meRef = Configuration.isProduction
          ? FirebaseFirestore.instance.collection('userRoom/$uid/groupChat')
          : FirebaseFirestore.instance
          .collection('userRoom_test/$uid/groupChat');

      //for count
      final docForCount=await meRef.doc(channelId).get();
      int messageCount=docForCount.data()!['unseenMessageCount'];
      print('unseen message count for group on delete ${messageCount}');
      countService.updateGroupMessageCountOnDelete(uid, messageCount);
      //for count

      meRef.doc(channelId).delete();
    } on Exception catch (e) {

    }
  }

  Future updateChannel(String channelName, List<String> uidList,
      BuildContext context,String channelId,List<String> previousList) async{
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      Utils.showInternetErrorToast();
      return;
    }

    try {
      final difference=previousList.toSet().difference(uidList.toSet()).toList();
      List<RemovedUser> removedUsers=[];
      List<Map<String,dynamic>> removedUsersMap=[];
      difference.forEach((element) {
        final removedUser=RemovedUser(uid: element, removedAt: DateTime.now());
        removedUsers.add(removedUser);
      });
      removedUsers.forEach((element) {
        final removedUser=element.toMap();
        removedUsersMap.add(removedUser);
      });

      channelRef.doc(channelId).update({
        'channelName': channelName,
        'membersIds': uidList,
        'removedUsers':removedUsersMap
      });
      Navigator.pop(context);
    } catch (e) {
      Utils.showErrorToast();
    }
  }

}
