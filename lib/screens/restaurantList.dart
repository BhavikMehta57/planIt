// ignore_for_file: avoid_print, must_be_immutable, file_names, non_constant_identifier_names, prefer_const_constructors
import 'dart:convert';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/gestures.dart';
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
import 'package:planit/screens/itinerary.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class RestaurantList extends StatefulWidget {
  static String tag = '/RestaurantList';
  final List restaurantList;
  const RestaurantList({Key? key, required this.restaurantList}) : super(key: key);

  @override
  _RestaurantListState createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantList> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? selected;
  String? searchRestaurant;
  List allRestaurantsList = [];
  List filteredrestaurantsList = [];

  @override
  void initState() {
    super.initState();
    allRestaurantsList = List.from(widget.restaurantList);
    filteredrestaurantsList = List.from(widget.restaurantList);
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

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: app_Background,
      appBar: AppBar(
        iconTheme: IconThemeData(color: appWhite),
        backgroundColor: app_Background,
        title: text("Restaurants", textColor: appWhite, fontSize: textSizeLarge),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: text(
                  "Select a restaurant of your choice",
                  maxLine: 2,
                  isCentered: true,
                  fontSize: 16.0
              )
          ),
          SizedBox(height: deviceHeight * 0.02,),
          EditText(
            isPrefixIcon: false,
            onPressed: (value) {
              searchRestaurant = value;
            },
            hintText: "Search Restaurant by Name",
            prefixIcon: fullnameIcon,
            isPassword: false,
            isPhone: false,
            validatefunc: (String? value) {
              return null;
            },
            suffixIcon: Icons.search_outlined,
            suffixIconColor: appBlack,
            suffixIconOnTap: () async {

            },
          ),
          SizedBox(height: deviceHeight * 0.03,),
          Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: filteredrestaurantsList.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            selected = index;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          height: deviceHeight * 0.20,
                          decoration: selected == index ? BoxDecoration(
                            border: Border.all(color: appColorAccent, width: 3.0),
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ) : BoxDecoration(
                            border: Border.all(color: appWhite),
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: text(
                                          filteredrestaurantsList[index]['name'][0],
                                          isBold: true,
                                          maxLine: 2
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          text(filteredrestaurantsList[index]['aggregate_rating'][0].toString()),
                                          SizedBox(width: deviceWidth * 0.01),
                                          Icon(Icons.star, color: Colors.yellow, size: 15.0,),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: deviceHeight * 0.15 * 0.01,),
                                GestureDetector(
                                  onTap: () async {
                                    String googleMapslocationUrl = "https://www.google.com/maps/search/?api=1&query=${filteredrestaurantsList[index]['address'][0]}";
                                    Uri encodedURl = Uri.parse(googleMapslocationUrl);
                                    await launchUrl(encodedURl);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on, size: 25.0,),
                                      SizedBox(width: deviceWidth * 0.01),
                                      Flexible(
                                        child: text(
                                          filteredrestaurantsList[index]['address'][0],
                                          isBold: true,
                                          maxLine: 2,
                                          fontSize: textSizeSmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: deviceHeight * 0.15 * 0.01,),
                                text(
                                  filteredrestaurantsList[index]['cuisines'][0],
                                  isBold: true,
                                  maxLine: 2,
                                  fontSize: textSizeSmall,
                                  textColor: appColorAccent,
                                ),
                                SizedBox(height: deviceHeight * 0.15 * 0.02,),
                                RichText(
                                  text: TextSpan(
                                      text: "$rupees ${filteredrestaurantsList[index]['average_cost_for_two'][0]} ",
                                      style: TextStyle(
                                          color: Colors.cyan,
                                          fontSize: 16.0
                                      ),
                                      children:[
                                        TextSpan(
                                          text: "(Cost for two)",
                                          style: TextStyle(
                                              color: appWhite,
                                              fontSize: 12.0
                                          ),
                                          recognizer: TapGestureRecognizer()..onTap = () {
                                            // final Uri toLaunch = Uri(scheme: 'https', host: 'docs.google.com', path: 'document/d/1Kym9trNo720_SX4TpY5IMdkIImOeH8YKw_jnGmnoJ9o/edit');
                                            // launchInWebViewOrVC(toLaunch);
                                          },
                                        ),
                                      ]
                                  ),
                                  maxLines: 3,
                                ),
                                SizedBox(height: deviceHeight * 0.15 * 0.02,)
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: deviceHeight * 0.02,),
                    ],
                  );
                },
              )
          ),
          SizedBox(height: deviceHeight * 0.02,),
        ],
      ),
    );
  }
}