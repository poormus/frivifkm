package com.fkm.frivifkm



import android.Manifest
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import androidx.core.content.PermissionChecker
import java.io.File
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

//notification imports
import android.app.NotificationManager
import androidx.core.content.ContextCompat.getSystemService
import android.app.NotificationChannel
import android.app.Application
import android.util.Log


//direct reply
import android.app.RemoteInput as input
import android.content.BroadcastReceiver
import android.content.Context
import com.onesignal.OneSignal
import com.onesignal.OSNotificationReceivedEvent

import android.app.PendingIntent
import androidx.core.app.NotificationCompat
import android.app.Notification
import androidx.core.app.NotificationManagerCompat
import android.graphics.Color
import androidx.core.app.RemoteInput

class MainActivity : FlutterActivity() {


//    override fun onCreate(savedInstanceState: Bundle?) {
////       // Enable verbose OneSignal logging to debug issues if needed.
////        OneSignal.setLogLevel(OneSignal.LOG_LEVEL.VERBOSE, OneSignal.LOG_LEVEL.NONE);
////        // OneSignal Initialization
////        OneSignal.initWithContext(this);
////        OneSignal.setAppId("");
//        super.onCreate(savedInstanceState)
//    }
//
//    companion object {
//        fun sendChannel1Notification(context: Context?) {
//            val activityIntent = Intent(context, MainActivity::class.java)
//            val contentIntent = PendingIntent.getActivity(
//                context,
//                0, activityIntent, 0
//            )
//            val remoteInput: RemoteInput? = RemoteInput.Builder("key_text_reply")
//                .setLabel("Your answer...")
//                .build()
//            val replyIntent: Intent
//            var replyPendingIntent: PendingIntent? = null
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
//                replyIntent = Intent(context, DirectReplyReceiver::class.java)
//                replyPendingIntent = PendingIntent.getBroadcast(
//                    context,
//                    0, replyIntent, 0
//                )
//            } else {
//                //start chat activity instead (PendingIntent.getActivity)
//                //cancel notification with notificationManagerCompat.cancel(id)
//            }
//            val replyAction: NotificationCompat.Action = NotificationCompat.Action.Builder(
//                R.drawable.launch_background,
//                "Reply",
//                replyPendingIntent
//            ).addRemoteInput(remoteInput).build()
//
//            val notification: Notification = NotificationCompat.Builder(context!!, App.CHANNEL_1_ID)
//                .setSmallIcon(R.drawable.ic_baseline_notifications)
//                .addAction(replyAction)
//                .setColor(Color.BLUE)
//                .setPriority(NotificationCompat.PRIORITY_HIGH)
//                .setCategory(NotificationCompat.CATEGORY_MESSAGE)
//                .setContentIntent(contentIntent)
//                .setAutoCancel(true)
//                .setOnlyAlertOnce(true)
//                .build()
//            val notificationManager = NotificationManagerCompat.from(context)
//            notificationManager.notify(1, notification)
//        }
//    }
    }



//class App : Application() {
//
//    override fun onCreate() {
//        super.onCreate()
//        createNotificationChannels()
//    }
//
//    private fun createNotificationChannels() {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            val channel1 = NotificationChannel(
//                CHANNEL_1_ID,
//                "Channel 1",
//                NotificationManager.IMPORTANCE_HIGH
//            )
//            channel1.description = "This is Channel 1"
//            val channel2 = NotificationChannel(
//                CHANNEL_2_ID,
//                "Channel 2",
//                NotificationManager.IMPORTANCE_LOW
//            )
//            channel2.description = "This is Channel 2"
//            val manager = getSystemService(
//                NotificationManager::class.java
//            )
//            manager.createNotificationChannel(channel1)
//            manager.createNotificationChannel(channel2)
//        }
//    }
//
//    companion object {
//        const val CHANNEL_1_ID = "channel1"
//        const val CHANNEL_2_ID = "channel2"
//    }
//}
//
//
//class DirectReplyReceiver : BroadcastReceiver(), OneSignal.OSRemoteNotificationReceivedHandler {
//
//    override fun onReceive(context: Context?, intent: Intent?) {
////        val remoteInput: Bundle = input.getResultsFromIntent(intent)
////        val replyText = remoteInput.getCharSequence("key_text_reply")
//////            val answer = Message(replyText, null)
//////            MainActivity.MESSAGES.add(answer)
////        MainActivity.sendChannel1Notification(context)
//    }
//
//    override fun remoteNotificationReceived(context: Context?, notification: OSNotificationReceivedEvent?) {
//       Log.d("received","notification received")
////        val intent = Intent(context,MainActivity::class.java)
////        val remoteInput: Bundle = input.getResultsFromIntent(intent)
////        val replyText = remoteInput.getCharSequence("key_text_reply")
//////            val answer = Message(replyText, null)
//////            MainActivity.MESSAGES.add(answer)
//        MainActivity.sendChannel1Notification(context)
//    }
//
//
//}




