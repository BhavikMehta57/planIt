import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planit/authentication/Login.dart';
import 'package:planit/main/appHome.dart';
import 'package:planit/main/utils/AppColors.dart';
import 'package:planit/main/utils/AppConstant.dart';
import 'package:planit/main/utils/AppWidget.dart';
import 'package:planit/main/utils/dots_indicator/dots_indicator.dart';

class WalkThrough extends StatefulWidget {
  static String tag = '/WalkThrough';

  const WalkThrough({Key? key});

  @override
  WalkThroughState createState() => WalkThroughState();
}

class WalkThroughState extends State<WalkThrough> {
  final PageController controller = PageController();
  var currentPage = 0;

  @override
  Widget build(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: appWhite,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                child: PageView(children: [
                  WalkThroughWidget(
                    image: "assets/images/walkthrough/1.png",
                  ),
                  WalkThroughWidget(
                    image: "assets/images/walkthrough/2.png",
                  ),
                  WalkThroughWidget(
                    image: "assets/images/walkthrough/3.png",
                  ),
                  WalkThroughWidget(
                    image: "assets/images/walkthrough/4.png",
                  ),
                  WalkThroughWidget(
                    image: "assets/images/walkthrough/5.png",
                  ),
                  WalkThroughWidget(
                    image: "assets/images/walkthrough/6.png",
                  ),
                ], controller: controller, onPageChanged: _onPageChanged),
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: deviceHeight * 0.02),
                  child: DotsIndicator(
                    dotsCount: 6,
                    position: currentPage,
                    decorator: DotsDecorator(
                        color: appColorSecondary.withOpacity(0.15),
                        activeColor: appColorSecondary,
                        activeSize: const Size.square(spacing_middle),
                        spacing: const EdgeInsets.all(3)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: deviceHeight * 0.01),
                  child: shadowButton(
                      currentPage == 5 ? "Proceed" : "Next",
                          () {
                            if (currentPage == 5)
                            {
                              if (FirebaseAuth.instance.currentUser != null) {
                                if(FirebaseAuth.instance.currentUser!.email != null) {
                                  Navigator.pop(context);
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
                            else
                            {
                              setState(() {
                                currentPage++;
                                controller.animateToPage(currentPage,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.ease);
                              });
                            }
                          }, appColorPrimary, deviceHeight
                      ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: deviceHeight * 0.01),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentPage = 5;
                        controller.animateToPage(currentPage,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease);
                      });
                    },
                    child: text(currentPage != 5 ? "Skip Now" : "",
                        textColor: TextColorSecondary, lineThrough: true),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
  }
}

class WalkThroughWidget extends StatelessWidget {
  var title;
  var image;
  var subTitle;

  WalkThroughWidget({Key? key, this.title, this.image, this.subTitle});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: height * 0.1,
        ),
        Expanded(
          child: Image.asset(
            image,
            height: height * 0.7,
          ),
        ),
      ],
    );
  }
}
