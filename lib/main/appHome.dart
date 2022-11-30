// ignore_for_file: avoid_print, must_be_immutable, file_names
import 'package:planit/authentication/Login.dart';
import 'package:planit/authentication/SignUp.dart';
import 'package:planit/main/utils/AppColors.dart';
import 'package:planit/main/utils/AppConstant.dart';
import 'package:planit/main/utils/AppWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:nb_utils/nb_utils.dart';

class MainHome extends StatefulWidget {
  static String tag = '/MainHome';

  const MainHome({Key? key}) : super(key: key);

  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: appWhite,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image(
                  image: AssetImage("assets/images/MainHomeImage.png"),
                  height: deviceHeight * 0.75,
                  width: double.infinity,
                ),
                shadowButton("Login", () {
                  Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Login()),
                      );
                }, appColorPrimary, deviceHeight),
                SizedBox(height: deviceHeight * 0.02,),
                MaterialButton(
                  height: deviceHeight * 0.06,
                  minWidth: double.infinity,
                  child: text("Register",
                      fontSize: textSizeLargeMedium,
                      textColor: appBlack,
                      fontFamily: fontMedium),
                  textColor: whiteColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: BorderSide(color: appColorPrimary),
                  ),
                  color: appWhite,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => Signup()),
                    );
                  },
                ),
                SizedBox(height: deviceHeight * 0.05,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
