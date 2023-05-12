// ignore_for_file: avoid_print, must_be_immutable, file_names, non_constant_identifier_names, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:planit/main/appHome.dart';
import 'package:planit/main/utils/AppColors.dart';
import 'package:planit/main/utils/AppConstant.dart';
import 'package:planit/main/utils/AppWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:planit/screens/bookmarks.dart';
import 'package:planit/screens/walkthrough.dart';

class Profile extends StatefulWidget {
  static String tag = '/Profile';

  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  signUserOut() {
    //redirect
    // SharedPrefs.saveUserLoggedInSharedPreference(false);
    // SharedPrefs.savePhoneSharedPreference("");
    FirebaseAuth.instance.signOut().then((value) => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        MainHome()), (Route<dynamic> route) => false));
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: app_Background,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // UserAccountsDrawerHeader(
            //   margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            //   decoration: BoxDecoration(color: appColorPrimary),
            //   accountName: text("Bhavik Mehta",),
            //   accountEmail: text(FirebaseAuth.instance.currentUser!.email.toString()),
            //   // currentAccountPictureSize: Size.square(deviceWidth * 0.2),
            //   currentAccountPicture: CircleAvatar(
            //     backgroundColor: appWhite,
            //     child: text(
            //       "B",
            //       isBold: true,
            //       fontSize: 24.0,
            //       isCentered: true,
            //     ), //Text
            //   ), //circleAvatar
            // ),
            CircleAvatar(
              radius: deviceWidth * 0.1,
              backgroundColor: appWhite,
              child: text(
                FirebaseAuth.instance.currentUser!.displayName![0].toString(),
                isBold: true,
                fontSize: 24.0,
                isCentered: true,
              ), //Text
            ), //circleAvatar
            SizedBox(height: deviceHeight * 0.02,),
            text("Bhavik Mehta",),
            SizedBox(height: deviceHeight * 0.01,),
            text(FirebaseAuth.instance.currentUser!.email.toString()),
            SizedBox(height: deviceHeight * 0.02,),
            Divider(height: 5, color: appShadowColor,),
            SizedBox(height: deviceHeight * 0.02,),
            ListTile(
              horizontalTitleGap: 0.0,
              leading: const Icon(Icons.bookmark_added_rounded),
              title: text('Bookmarks', fontSize: 20.0),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Bookmarks()));
              },
            ),
            ListTile(
              horizontalTitleGap: 0.0,
              leading: const Icon(Icons.settings),
              title: text('Settings', fontSize: 20.0),
              onTap: () {

              },
            ),
            ListTile(
              horizontalTitleGap: 0.0,
              leading: const Icon(Icons.mark_chat_read_rounded),
              title: text('Walkthrough', fontSize: 20.0),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => WalkThrough()));
              },
            ),
            ListTile(
              horizontalTitleGap: 0.0,
              leading: const Icon(Icons.sticky_note_2_rounded),
              title: text('Privacy Policy', fontSize: 20.0),
              onTap: () {

              },
            ),
            ListTile(
              horizontalTitleGap: 0.0,
              leading: const Icon(Icons.sticky_note_2_rounded),
              title: text('Terms & Conditions', fontSize: 20.0),
              onTap: () {

              },
            ),
            ListTile(
              horizontalTitleGap: 0.0,
              leading: const Icon(Icons.logout),
              title: text('Logout', fontSize: 20.0),
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0))
                        ),
                        title: text('Please Confirm', fontSize: textSizeNormal),
                        content: text('Are you sure you want to logout?', fontSize: textSizeSmall, maxLine: 2),
                        actions: [
                          Row(
                            children: [
                              Expanded(
                                child: filterButton("No", () {
                                  Navigator.pop(context);
                                }, appWhite, deviceHeight),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: filterButton("Yes", () async {
                                  Navigator.pop(context);
                                  await signUserOut();
                                }, appWhite, deviceHeight),
                              ),
                            ],
                          ),
                        ],
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}