import 'dart:io';
import 'package:chatapp/effects/transition4.dart';
import 'package:chatapp/helper/dialogs.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/screens/home_screen.dart';
import 'package:chatapp/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chatapp/apis/Apis.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  _handlegooglebutton(){
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);

      if (user != null) {
        bool userExists = await Api.userExists();
        if (userExists) {
          Navigator.pushReplacement(context, SizeTransition4(HomeScreen()));
        } else {
          await Api.createUser().then((value) => Navigator.pushReplacement(context, SizeTransition4(HomeScreen()))) ;

        }
      }
    });

  }

  Future<UserCredential?> _signInWithGoogle() async {
    try{

      await InternetAddress.lookup("google.com");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await Api.auth.signInWithCredential(credential);
    }catch(e){
      print('_signInWithGoogle ${e}') ;
      print('please check internet') ;
      Dialogs.showSnackbar(context, "Something Went Wrong Please Check Internet");
      return null ;
    }
  }

  //  sing out funciton......................
 //  _Signout() async {
 //    await FirebaseAuth.instance.signOut() ;
 //    await GoogleSignIn().signOut() ;
 //
 // }
  //...................................
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size ;
    return Scaffold(
      backgroundColor: AppColors.theme['backgroundColor'],
      appBar: AppBar(
        // backgroundColor: ,
        title: Text("Welcome to ChatWith"),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Positioned(
            top: mq.height * .15,
              width: mq.width *0.5,
              left:mq.width *0.25,
              child: Image.asset("assets/images/chat.png")
          ),
          Positioned(
              bottom: mq.height * .15,
              height: mq.height *0.058,
              width: mq.width *0.9,
              left: mq.width *.05,
              child:ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.theme['appbarColor'],
                  shape: StadiumBorder(),
                ),
                  icon: Padding(
                    padding:  EdgeInsets.all(8.0),
                    child: Image.asset("assets/images/google.png"),
                  ),
                onPressed: () {
                  _handlegooglebutton() ;
                },
                label: Padding(
                  padding:  EdgeInsets.only(left: 4.0),
                  child: Text("Continue with Google",style: TextStyle(fontSize: 17),),
                ),
              ),

          ),
        ],
      ),
    );
  }
}

