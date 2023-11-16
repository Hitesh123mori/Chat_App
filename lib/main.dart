import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/screens/auth/splash_screen.dart';
import 'package:chatapp/theme/colors.dart';
import 'package:flutter/material.dart' ;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';

late Size mq ;


void main(){
  WidgetsFlutterBinding.ensureInitialized() ;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]).then((value){
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky) ;
        _intializeFirebase() ;
        runApp(chatApp()) ;
  });


}

class chatApp extends StatefulWidget {
  const chatApp({super.key});

  @override
  State<chatApp> createState() => _chatAppState();
}

class _chatAppState extends State<chatApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
            color: AppColors.theme['iconColor'],
          ),
          backgroundColor:AppColors.theme['appbarColor'],
          elevation: 1,
          centerTitle: true,
          titleTextStyle:  TextStyle(color: AppColors.theme['primaryTextColor'],fontSize: 20,fontWeight: FontWeight.bold),
        )
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen() ,
    );
  }
}


_intializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'show chat messages',
    id: 'Chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
    visibility: NotificationVisibility.VISIBILITY_PUBLIC,
    allowBubbles: true,
    enableVibration: true,
    enableSound: true,
    showBadge: true,
  );
  print(result);

}




