// ignore_for_file: file_names, prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:planit/main.dart';
import 'package:planit/main/utils/AppColors.dart';
import 'package:planit/main/utils/AppConstant.dart';
import 'package:planit/main/utils/dots_indicator/src/dots_decorator.dart';
import 'package:planit/main/utils/dots_indicator/src/dots_indicator.dart';

class HomeSlider extends StatefulWidget {
  const HomeSlider({Key? key}) : super(key: key);

  @override
  _HomeSliderState createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {
  int currentPage = 0;
  List<String> imgList = [];

  Future<void> setImages() async {
    //Get images from Firebase
    DocumentSnapshot imagesDoc = await FirebaseFirestore.instance.collection('app').doc('Slider').get();
    setState(() {
      imgList = List<String>.from(imagesDoc.data()!["homeSlider"]);
    });
    print("Set images");
  }

  @override
  void initState(){
    super.initState();
    setImages();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double h = size.height;
    double w = size.width;
    return
      imgList.isEmpty
          ?
      Container(
        height: h*0.25,
        margin: EdgeInsets.only(top: h*0.013),
        color: appStore.scaffoldBackground,
        child: Center(
          child: CircularProgressIndicator(color: appWhite),
        ),
      )
          :
      Container(
        height: h*0.25,
        margin: EdgeInsets.only(top: h*0.013),
        color: appStore.scaffoldBackground,
        child: Column(
          children: <Widget>[
            Expanded(
              child: CarouselSlider(
                options: CarouselOptions(
                    height: h*0.25,
                    initialPage: 0,
                    enlargeCenterPage: false,
                    autoPlay: true,
                    reverse: false,
                    enableInfiniteScroll: true,
                    autoPlayInterval: Duration(seconds: 6),
                    autoPlayAnimationDuration: Duration(milliseconds: 2000),
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentPage = index;
                      });
                    }),
                items: imgList
                    .map((item) => Container(
                  margin: EdgeInsets.symmetric(horizontal: w*0.025),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            Center(
                              child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(color: appWhite,value: downloadProgress.progress)
                              ),
                            ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        imageUrl:item,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width),
                  ),
                ))
                    .toList(),
              ),
            ),
            SizedBox(
              height: h*0.012,
            ),
            DotsIndicator(
              dotsCount: imgList.length,
              position: currentPage,
              decorator: DotsDecorator(
                  color: appWhite.withOpacity(0.15),
                  activeColor: appWhite,
                  activeSize: Size.square(spacing_middle),
                  spacing: EdgeInsets.all(3)),
            )
          ],
        ),
      );
  }
}
