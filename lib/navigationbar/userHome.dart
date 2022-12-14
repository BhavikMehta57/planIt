// ignore_for_file: avoid_print, must_be_immutable, file_names, non_constant_identifier_names, prefer_const_constructors
import 'dart:async';
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

class UserHome extends StatefulWidget {

  int currentIndex;

  UserHome({Key? key, required this.currentIndex}) : super(key: key);

  @override
  UserHomeState createState() => UserHomeState();
}

class UserHomeState extends State<UserHome> {
  int _currentIndex = 1;
  String? phoneNumber;
  String? fullName;
  String? email;
  String downloadUrl = "";
  String link = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isPlanning = false;
  String destination = "";
  String selectedStartDate = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 1)));
  String selectedEndDate = "";
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  String numberOfTravellers = "";
  String budget = "";
  List<String> areasOfInterest = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    // getAppLink();
  }

  signUserOut() {
    //redirect
    // SharedPrefs.saveUserLoggedInSharedPreference(false);
    // SharedPrefs.savePhoneSharedPreference("");
    FirebaseAuth.instance.signOut().then((value) => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        MainHome()), (Route<dynamic> route) => false));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: app_Background,
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: appColorPrimary,
          dividerColor: Colors.transparent,
        ),
        child: SizedBox(
          width: deviceWidth * 0.70,
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.02),
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: appColorPrimary,
                  ), //BoxDecoration
                  child: UserAccountsDrawerHeader(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(color: appColorPrimary),
                    accountName: text("Bhavik Mehta",),
                    accountEmail: text(FirebaseAuth.instance.currentUser!.email.toString()),
                    currentAccountPictureSize: Size.square(deviceWidth * 0.1),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: appWhite,
                      child: text(
                        "B",
                        isBold: true,
                        fontSize: 24.0,
                        isCentered: true,
                      ), //Text
                    ), //circleAvatar
                  ), //UserAccountDrawerHeader
                ), //DrawerHeader
                ListTile(
                  horizontalTitleGap: 0.0,
                  leading: const Icon(Icons.person),
                  title: text('Profile', fontSize: 20.0),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  horizontalTitleGap: 0.0,
                  leading: const Icon(Icons.bookmark_added_rounded),
                  title: text('Bookmarks', fontSize: 20.0),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  horizontalTitleGap: 0.0,
                  leading: const Icon(Icons.settings),
                  title: text('Settings', fontSize: 20.0),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  horizontalTitleGap: 0.0,
                  leading: const Icon(Icons.mark_chat_read_rounded),
                  title: text('FAQ', fontSize: 20.0),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  horizontalTitleGap: 0.0,
                  leading: const Icon(Icons.logout),
                  title: text('LogOut', fontSize: 20.0),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: appWhite),
        backgroundColor: app_Background,
        title: text("PlanIt", textColor: appWhite, fontSize: textSizeLarge),
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () async {
              try {
                await signUserOut();
              } catch(err) {
                return;
              }
            },
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: text("Logout", textColor: appWhite),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.small(
        splashColor: appWhite,
        foregroundColor: appColorPrimary,
        backgroundColor: appWhite,
        onPressed:() async {
          setState(() {
            _currentIndex = 2;
          });
        },
        tooltip: 'Create New Itinerary',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(overflow: TextOverflow.visible),
            unselectedLabelStyle: const TextStyle(overflow: TextOverflow.visible),
            showUnselectedLabels: false,
            iconSize: 25,
            selectedFontSize: 12.0,
            backgroundColor: appBlack,
            unselectedItemColor: appWhite,
            fixedColor: appWhite,
            elevation: 0.0,
            onTap: (index) => setState(() => {
              _currentIndex = index,
            }),
            items: NavigationBarScreen.pages.map((p) {
              return BottomNavigationBarItem(
                  icon: p.icon,
                  activeIcon: Column(
                    children: <Widget>[
                      // if (_currentIndex == p.index)
                      //   Container(height: 2, width: 50, color: appColorPrimary),
                      const SizedBox(height: 5),
                      p.activeIcon,
                    ],
                  ),
                  label: p.title);
            }).toList()
        ),
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
            index: _currentIndex,
            children: NavigationBarScreen.pages.map((p) => p.page).toList()
        ),
      ),
    );
  }
}
