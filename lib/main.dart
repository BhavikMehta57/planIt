import 'package:planit/main/appHome.dart';
import 'package:planit/main/shared_prefs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:planit/navigationbar/userHome.dart';
import 'package:planit/splashScreen.dart';

import 'main/store/AppStore.dart';
import 'main/utils/AppTheme.dart';

/// This variable is used to get dynamic colors when theme mode is changed
AppStore appStore = AppStore();

void main() async{
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: true,
      // systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      // systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,)
  );
  //Setting SystemUIMode
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top]);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyApp(),
        theme: AppThemeData.darkTheme,
      )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SDSplashScreen(),
        theme: AppThemeData.darkTheme,
      );
  }
}
