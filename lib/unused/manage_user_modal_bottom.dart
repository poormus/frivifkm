// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_calendar/components/primary_button.dart';
// import 'package:firebase_calendar/components/secondary_button.dart';
// import 'package:firebase_calendar/dialog/update_role.dart';
// import 'package:firebase_calendar/models/current_user_data.dart';
// import 'package:firebase_calendar/screens/messages/chat_screen.dart';
// import 'package:firebase_calendar/services/admin_services.dart';
// import 'package:firebase_calendar/shared/constants.dart';
// import 'package:flutter/material.dart';
//
// import '../shared/utils.dart';
// import 'blurry_dialog.dart';
//
// class ManageUserModalBottom extends StatefulWidget {
//   final CurrentUserData userToManage;
//   final CurrentUserData admin;
//
//   const ManageUserModalBottom(
//       {Key? key, required this.userToManage, required this.admin})
//       : super(key: key);
//
//   @override
//   _ManageUserModalBottomState createState() => _ManageUserModalBottomState();
// }
//
// class _ManageUserModalBottomState extends State<ManageUserModalBottom> {
//   final adminService = AdminServices();
//   late  String userRole;
//
//   String getUserCurrentRoleWithinCompany() {
//     String userRole = '';
//     widget.userToManage.userOrganizations.forEach((element) {
//       if (element.organizationId == widget.admin.currentOrganizationId) {
//         userRole = element.userRole;
//       }
//     });
//     return userRole;
//   }
//
//   //functions
//   showRemoveDialog() {
//     BlurryDialog alert = BlurryDialog(
//       title: "Remove!",
//       content: "Are you sure you want to remove this user?",
//       continueCallBack: removeUser,
//     );
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
//
//   Future removeUser() async {
//     Navigator.pop(context);
//     Navigator.pop(context);
//     await adminService.removeUserFromOrganizationManage(
//         widget.admin.currentOrganizationId!, widget.userToManage);
//   }
//
//   String generateRoomName() {
//     String user1 = widget.admin.uid;
//     String user2 = widget.userToManage.uid;
//     return 'chat_' +
//         (user1.hashCode < user2.hashCode
//             ? user1 + '_' + user2
//             : user2 + '_' + user1);
//   }
//
//   void messageUser() {
//     Navigator.push(context, MaterialPageRoute(builder: (context) {
//       return ChatScreen(
//         currentUserData: widget.admin,
//         chattedUserUrl: widget.userToManage.userUrl,
//         chattedUserName: widget.userToManage.userName,
//         roomName: generateRoomName(),
//         chattedUserUid: widget.userToManage.uid,
//       );
//     }));
//   }
//
//   showUpdateRoleDialog() {
//     UpdateRole alert =
//         UpdateRole(title: 'update user role',userData: widget.userToManage,admin: widget.admin);
//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return alert;
//         });
//   }
//
//
//
//   viewLogs(){
//     Utils.showToast(context, 'TO-D0');
//   }
//
//   //functions
// @override
//   void initState() {
//     userRole=Utils.getUserRole(widget.userToManage.userOrganizations, widget.admin.currentOrganizationId!);
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     String userName = widget.userToManage.userName;
//     String userSurname = widget.userToManage.userSurname;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Stack(
//           children: [
//             CachedNetworkImage(
//               width: size.width,
//               fit: BoxFit.cover,
//               height: size.height*0.3,
//               imageUrl: widget.userToManage.userUrl!,
//               placeholder: (context, url) => Align(child: new CircularProgressIndicator()),
//               errorWidget: (context, url, error) => new Icon(Icons.error),
//             ),
//             Positioned(
//               bottom: 20,
//               left: 20,
//               child: Container(
//                 decoration: BoxDecoration(
//                     color: Colors.green[300],
//                     borderRadius: BorderRadius.circular(5)
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Text(
//                     "$userName $userSurname",
//                     style: TextStyle(color: Colors.white, fontSize: 20),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(
//           height: 5,
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             SizedBox(
//               width: 5,
//             ),
//             SecondaryButton(
//               color: Colors.blue,
//               text: 'update role',
//               hasIcon: false,
//               press: showUpdateRoleDialog,
//             ),
//             SecondaryButton(
//               color: Colors.red,
//               text: 'remove',
//               hasIcon: false,
//               press: showRemoveDialog,
//             ),
//             SecondaryButton(
//               color: Colors.green,
//               text: 'message',
//               hasIcon: false,
//               press: messageUser,
//             ),
//             SizedBox(
//               width: 5,
//             ),
//           ],
//         ),
//         SizedBox(
//           height: 5,
//         ),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Divider(color: Colors.black12, thickness: 1, height: 4),
//               Text('email:',style: TextStyle(color: Colors.black54)),
//               Text('${widget.userToManage.email}'),
//               SizedBox(height: 5),
//               Divider(color: Colors.black12, thickness: 1, height: 4),
//               Text('phone:',style: TextStyle(color: Colors.black54)),
//               Text('${widget.userToManage.userPhone ?? 'not given'}'),
//               SizedBox(height: 5),
//               Divider(color: Colors.black12, thickness: 1, height: 4),
//               Text('current role:',style: TextStyle(color: Colors.black54),),
//               Text('$userRole'),
//               SizedBox(height: 10),
//
//               SizedBox(height: 10),
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }
