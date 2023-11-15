import 'package:chatapp/apis/Apis.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/screens/auth/login_screen.dart';
import 'package:chatapp/screens/home_screen.dart';
import 'package:chatapp/theme/colors.dart';
import 'package:flutter/material.dart' ;
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override

  void initState(){
    super.initState() ;
    Future.delayed(Duration(milliseconds: 2500),(){
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge) ;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: AppColors.theme['appbarColor'],systemNavigationBarColor: Colors.transparent));
      if(Api.auth != null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeScreen())) ;
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen())) ;
      }
    }) ;
  }


  @override
  Widget build(BuildContext context) {

    mq = MediaQuery.of(context).size ;
    return Scaffold(
      backgroundColor: AppColors.theme['backgroundColor'],
      body:  Stack(
        children: [
          Positioned(
              top: mq.height * .35,
              width: mq.width *0.5,
              left:mq.width *0.25,
              child: Image.asset("assets/images/chat.png")
          ),
        ],
      ),
    );
  }
}
