// ignore_for_file: avoid_print, must_be_immutable, file_names, non_constant_identifier_names
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:planit/main/home.dart';
import 'package:planit/main/shared_prefs.dart';
import 'package:planit/main/utils/AppString.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planit/authentication/Login.dart';
import 'package:planit/main/utils/AppColors.dart';
import 'package:planit/main/utils/AppConstant.dart';
import 'package:planit/main/utils/AppWidget.dart';
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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    // getAppLink();
  }

  Future<void> getAppLink() async {
    await FirebaseFirestore.instance.collection("appData").doc("AppLink").get().then((value){
      setState(() {
        link = value.data()!["link"];
      });
    });
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
    return Scaffold(
      backgroundColor: app_Background,
      drawer: Drawer(
        child: Container(),
      ),
      appBar: AppBar(
        backgroundColor: app_Background,
        automaticallyImplyLeading: false,
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
      floatingActionButton: FloatingActionButton(
        foregroundColor: appColorPrimary,
        backgroundColor: appWhite,
        onPressed:(){},
        tooltip: 'Create New Itinerary',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(overflow: TextOverflow.visible),
          unselectedLabelStyle: const TextStyle(overflow: TextOverflow.visible),
          iconSize: 25,
          selectedFontSize: 12.0,
          backgroundColor: appColorPrimary,
          unselectedItemColor: appWhite,
          fixedColor: appWhite,
          elevation: 10.0,
          onTap: (index) => setState(() => {
            _currentIndex = index,
          }),
          items: NavigationBarScreen.pages.map((p) {
            return BottomNavigationBarItem(
                icon: p.icon,
                activeIcon: Column(
                  children: <Widget>[
                    if (_currentIndex == p.index)
                      Container(height: 2, width: 50, color: appColorPrimary),
                    const SizedBox(height: 5),
                    p.activeIcon,
                  ],
                ),
                label: p.title);
          }).toList()),
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
              text("Hello")
            ],
          ),
        ),
      ),
    );
  }
}
