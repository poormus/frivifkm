import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/models/current_user.dart';
import 'package:firebase_calendar/screens/auth/register_new.dart';
import 'package:firebase_calendar/screens/how_to/how_to_screen.dart';
import 'package:firebase_calendar/screens/wrapper.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/shared/loading.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_app_check/firebase_app_check.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseAppCheck appCheck = await FirebaseAppCheck.instance;

  await EasyLocalization.ensureInitialized();
  appCheck.activate();
  //appCheck.getToken().then((value) => print('token is this: ${value}'));

  runApp(EasyLocalization(
      child: MyApp(),
      supportedLocales: [
        Locale('en'),
        Locale('no'),
      ],
      fallbackLocale: Locale('en'),
      startLocale: Locale('en'),
      path: 'assets/translations'));
}

//ignore: must_be_immutable
class MyApp extends StatefulWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late Future<bool> isSkipped;

  @override
  void initState() {
    isSkipped = _prefs.then((SharedPreferences prefs) {
      return (prefs.getBool('isSkipped') ?? false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return MultiProvider(
      providers: [
        StreamProvider<CurrentUser?>.value(
            value: AuthService().user, initialData: null),
        ChangeNotifierProvider(create: (context) => MyProvider())
      ],
      child: FutureBuilder<bool>(
        future: isSkipped,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MaterialApp(
              scaffoldMessengerKey: MyApp.scaffoldMessengerKey,
              navigatorKey: MyApp.navigatorKey,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              routes: {
                '/home': (context) => Wrapper(),
                '/register': (context) => RegisterNew()
              },
              title: 'Frivi App',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: snapshot.data! ? Wrapper() : HowTo(),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
                debugShowCheckedModeBanner: false, home: Loading());
          } else {
            return MaterialApp(
                debugShowCheckedModeBanner: false, home: Loading());
          }
        },
      ),
    );
  }
}
