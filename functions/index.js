
//const functions = require("firebase-functions");
//
//const admin = require("firebase-admin");
//
//
//admin.initializeApp();
//
//
//exports.sendNotification = functions.firestore.
//document("/chats/{chatId}/messages/{messageId}").onCreate((snap, context) => {
//console.log("message: ", snap.data().message);
//console.log("receiverId: ", snap.data().receiverId);
//const receiverId=snap.data().receiverId;
//const receiverRef=admin.firestore().collection("users").doc(receiverId);
//
//const notificationContent = {
//    notification: {
//       title: "you have a new notification",
//       body: snap.data().message,
//       icon: "default",
//    },
//};
//receiverRef.get().then((doc)=>{
//console.log("token", doc.data().messageToken);
//
//return admin.messaging().
//sendToDevice(doc.data().messageToken, notificationContent).then((result) => {
//console.log("Notification sent!");
//return 0;
//});
//});
//});
