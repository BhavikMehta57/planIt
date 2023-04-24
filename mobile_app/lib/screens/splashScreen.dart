// ignore_for_file: file_names

import 'dart:async';
import 'package:planit/main/appHome.dart';
import 'package:planit/main/shared_prefs.dart';
import 'package:planit/main/utils/AppColors.dart';
import 'package:planit/main/utils/AppConstant.dart';
import 'package:planit/main/utils/AppWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:planit/navigationbar/userHome.dart';

class SDSplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  _SDSplashScreenState createState() => _SDSplashScreenState();
}

class _SDSplashScreenState extends State<SDSplashScreen>
    with SingleTickerProviderStateMixin {
  startTime() async {
    var _duration = const Duration(seconds: 3);
    return Timer(_duration, navigate);
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  void navigate() async {
    if (FirebaseAuth.instance.currentUser != null) {
      if(FirebaseAuth.instance.currentUser!.email != null) {
        print("Splash screen, employer found!");
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => UserHome(currentIndex: 0,),
            ),
                (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MainHome(),
            ),
                (Route<dynamic> route) => false);
      }
    }
    else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainHome(),
          ),
              (Route<dynamic> route) => false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: app_Background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Image.asset("assets/images/logo.png", height: deviceHeight * 0.25),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: text("Welcome to PlanIt",textColor: appWhite, fontSize: 30.0, fontFamily: fontBold),
            ),
          ],
        ),
      ),
    );
  }
}
