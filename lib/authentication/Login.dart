// ignore_for_file: file_names, avoid_print

import 'package:planit/authentication/ForgotPassword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planit/authentication/SignUp.dart';
import 'package:planit/main/utils/AppColors.dart';
import 'package:planit/main/utils/AppConstant.dart';
import 'package:planit/main/utils/AppString.dart';
import 'package:planit/main/utils/AppWidget.dart';
import 'package:planit/main/utils/animation/fadeAnimation.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:planit/navigationbar/userHome.dart';

class Login extends StatefulWidget {
  static var tag = "/Login";

  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String userEmail = '';
  String userPassword = '';
  bool? hasLoggedIn;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  Future<void> loginUser(BuildContext context) async {
    try {
      print("Getting ds...");
      DocumentSnapshot ds = await _firestore.collection("users").doc(userEmail).get();
      print("Got ds...");
      if (!ds.exists) {
        const snackBar = SnackBar(
          content: Text('User does not exist !'),
          duration: Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          isLoading = false;
        });
        return;
      } else {
        //Check user type
        if(ds.data()!['Password'] == userPassword){
          final UserCredential userCreds = await FirebaseAuth.instance.signInWithEmailAndPassword(email: userEmail, password: userPassword);
          final User? currentUser = FirebaseAuth.instance.currentUser;

          print("Adding to firestore");
          //await sendEmail();
          assert(userCreds.user!.uid == currentUser!.uid);

          if (userCreds.user != null) {
            print("User Not Null, Signing In, Redirecting To Home");
            setState(() {
              isLoading = false;
            });
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => UserHome(currentIndex: 0,),
                ),
                    (Route<dynamic> route) => false);
          } else {
            print("Auth Failed! (Login, from verify callback)");
            setState(() {
              isLoading = false;
            });
            const snackBar = SnackBar(
              content: Text('SignIn Failed!\nPlease Check your internet connection and try again'),
              duration: Duration(seconds: 10),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          const snackBar = SnackBar(
            content:
            Text('Incorrect Password.'),
            duration: Duration(seconds: 5),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print(e);
      const snackBar = SnackBar(
        content:
        Text('Some error occurred! Please check you internet connection.'),
        duration: Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        isLoading = false;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: appWhite,
      appBar: AppBar(
        backgroundColor: appWhite,
        elevation: 0.0,
        leading: TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Container(
                height: deviceHeight * 0.04,
                width: deviceWidth * 0.08,
                decoration: BoxDecoration(
                    color: appWhite,
                    border: Border.all(color: border_colour),
                    borderRadius: BorderRadius.all(Radius.circular(5.0))
                ),
                child: Icon(Icons.chevron_left, color: appColorPrimary)
            )
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // FadeAnimation(
              //     0.4,
              //     commonCacheImageWidget(SignLogo, 100,
              //         width: 100, fit: BoxFit.fill)),
              // SizedBox(height: 16),
              SizedBox(height: deviceHeight * 0.05,),
              FadeAnimation(0.4, formHeading("Welcome Back! Glad to see you, Again!", TextColorPrimary)),
              SizedBox(height: deviceHeight * 0.05),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    FadeAnimation(
                      0.6,
                      EditText(
                        onPressed: (value) {
                          userEmail = value;
                        },
                        hintText: hint_email,
                        prefixIcon: emailIcon,
                        isPassword: false,
                        isPhone: false,
                        keyboardType: TextInputType.emailAddress,
                        validatefunc: (String? value) {
                          String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                          RegExp regExp = RegExp(pattern);
                          if (value!.isEmpty) {
                            return 'Please enter email address';
                          } else if (!regExp.hasMatch(value)) {
                            return 'Please enter valid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: deviceHeight * 0.02),
                    FadeAnimation(
                      0.8,
                      EditText(
                        onPressed: (value) {
                          userPassword = value;
                        },
                        hintText: hint_password,
                        prefixIcon: passwordIcon,
                        isPassword: true,
                        isPhone: false,
                        validatefunc: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          } else if (value.length < 6) {
                            return 'Password must consist atleast 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: deviceHeight * 0.02),
                    Container(
                      margin: EdgeInsets.only(right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FadeAnimation(
                            1.0,
                            GestureDetector(
                              onTap: () {
                                ForgotPassword().launch(context);
                              },
                              child: text(forgot_passwordText, textColor: TextColorLinks, fontFamily: fontMedium),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: deviceHeight * 0.02,),
                    isLoading
                        ?
                    const CircularProgressIndicator(color: appColorPrimary,)
                        :
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: FadeAnimation(
                        1.2,
                        shadowButton(
                          sign_inText,
                              () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              await loginUser(context);
                            }
                          }, appColorPrimary, deviceHeight
                        ),
                      ),
                    ),
                    SizedBox(height: deviceHeight * 0.02,),
                  ],
                ),
              ),
              SizedBox(height: deviceHeight * 0.02,),
              FadeAnimation(
                1.6,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    text(not_have_account,
                        textColor: textSecondaryColor,
                        fontSize: textSizeLargeMedium),
                    SizedBox(width: deviceWidth * 0.02),
                    GestureDetector(
                      onTap: () {
                        Signup().launch(context);
                      },
                      child: text("Register Now",
                          fontFamily: fontMedium,
                          textColor: TextColorLinks),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
