// ignore_for_file: avoid_print, must_be_immutable, file_names, non_constant_identifier_names, prefer_const_constructors
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:planit/main/appHome.dart';
import 'package:planit/main/shared_prefs.dart';
import 'package:planit/main/utils/AppString.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planit/authentication/Login.dart';
import 'package:planit/main/utils/AppColors.dart';
import 'package:planit/main/utils/AppConstant.dart';
import 'package:planit/main/utils/AppWidget.dart';
import 'package:planit/main/utils/Slider.dart';
import 'package:planit/main/utils/animation/fadeAnimation.dart';
import 'package:planit/main/utils/navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  static String tag = '/HomePage';

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String phone = '';
  String userName = '';
  String currIndustry = '';
  String prevIndustry1 = '';
  String prevIndustry2 = '';
  bool eligible = false;
  String gmailUsername = "planit.platform@gmail.com";
  String gmailPassword = "eyfnfmclgrylsaqj";
  bool isApplicationLoading = false;
  bool isGuideLoading = false;
  String shareJobLink = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  showSuccessfulApplicationDialog(String title, String message){
    AwesomeDialog(
        dismissOnTouchOutside:false,
        context: _scaffoldKey.currentContext!,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.SUCCES,
        title: title,
        desc: message,
        btnOkOnPress: () {
          // Navigator.pop(context);
        },
        btnOkIcon: Icons.check_circle,
        btnCancelIcon: Icons.cancel,
        onDismissCallback: (type) {
          debugPrint('Dialog Dismiss from callback');
        }).show();
  }

  // Future createJobDynamicLink() async {
  //   var parameters = DynamicLinkParameters(
  //     uriPrefix: 'https://planite.page.link',
  //     link: Uri.parse('https://planit/share?page=job'),
  //     androidParameters: AndroidParameters(
  //       packageName: "com.project.planit",
  //     ),
  //     // iosParameters: const IOSParameters(
  //     //   bundleId: "com.project.planit",
  //     //   appStoreId: '1498909115',
  //     // ),
  //   );
  //   // final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
  //   // final Uri shortUrl = shortLink.shortUrl;
  //   final Uri dynamicUrl = await parameters.buildUrl();
  //   final ShortDynamicLink shortLink = await parameters.buildShortLink();
  //   final Uri shortUrl = shortLink.shortUrl;
  //   setState(() {
  //     shareJobLink = shortUrl.toString();
  //     print(shareJobLink);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: app_Background,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HomeSlider(),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: text(
                      "GET YOURSELF A PERSONALIZED VACATION",
                      maxLine: 2,
                      isCentered: true,
                      fontSize: 20.0
                  )
              ),
              SizedBox(height: deviceHeight * 0.01,),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: deviceWidth * 0.4,
                        height: deviceHeight * 0.2,
                        decoration: BoxDecoration(
                          // border: Border.all(color: appWhite),
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/images/Delhi.jpg"),
                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                          ),
                        ),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              text(
                                  "DELHI",
                                  maxLine: 2
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Transform.rotate(
                                    angle: 90 * pi / 180,
                                    child: Icon(Icons.arrow_circle_up_rounded, size: deviceWidth * 0.1,),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: deviceWidth * 0.4,
                        height: deviceHeight * 0.2,
                        decoration: BoxDecoration(
                          // border: Border.all(color: appWhite),
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/images/Hyderabad.jpg"),
                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                          ),
                        ),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              text(
                                  "HYDERABAD",
                                  maxLine: 2
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Transform.rotate(
                                    angle: 90 * pi / 180,
                                    child: Icon(Icons.arrow_circle_up_rounded, size: deviceWidth * 0.1,),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
              ),
              SizedBox(height: deviceHeight * 0.01,),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: deviceWidth * 0.4,
                        height: deviceHeight * 0.2,
                        decoration: BoxDecoration(
                          // border: Border.all(color: appWhite),
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/images/Mumbai.jpg"),
                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                          ),
                        ),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              text(
                                  "MUMBAI",
                                  maxLine: 2
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Transform.rotate(
                                    angle: 90 * pi / 180,
                                    child: Icon(Icons.arrow_circle_up_rounded, size: deviceWidth * 0.1,),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: deviceWidth * 0.4,
                        height: deviceHeight * 0.2,
                        decoration: BoxDecoration(
                          // border: Border.all(color: appWhite),
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/images/Chennai.jpg"),
                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                          ),
                        ),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              text(
                                  "CHENNAI",
                                  maxLine: 2
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Transform.rotate(
                                    angle: 90 * pi / 180,
                                    child: Icon(Icons.arrow_circle_up_rounded, size: deviceWidth * 0.1,),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}