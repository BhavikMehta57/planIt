// ignore_for_file: avoid_print, must_be_immutable, file_names, non_constant_identifier_names, prefer_const_constructors

import 'package:planit/main/utils/AppColors.dart';
import 'package:planit/main/utils/AppWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class Explore extends StatefulWidget {
  static String tag = '/Explore';

  const Explore({Key? key}) : super(key: key);

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: app_Background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: text(
                  "EXPLORE",
                  maxLine: 2,
                  isCentered: true,
                  fontSize: 16.0
              )
          ),
          SizedBox(height: deviceHeight * 0.02,),
        ],
      ),
    );
  }
}