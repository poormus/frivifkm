

import 'package:flutter/services.dart';

class NotificationHelper{

  static const MethodChannel _platformCall = MethodChannel('notificationAndroid');


  static sendNotification(){
     _platformCall.invokeMethod('onReceived');
  }

}