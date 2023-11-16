import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/effects/transition4.dart';
import 'package:chatapp/models/chat_user.dart';
import 'package:chatapp/screens/view_profile.dart';
import 'package:chatapp/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' ;

import '../main.dart';

class ProfileDialog extends StatelessWidget {
  final ChatUser user;

  const ProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size ;
    return AlertDialog(
      backgroundColor:AppColors.theme['backgroundColor'],
      icon: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: mq.width*0.15,),
            Text(user.name,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: AppColors.theme['primaryTextColor'])),
            SizedBox(width: mq.width*0.06,),
           IconButton(
             onPressed: (){
               Navigator.push(context, SizeTransition4(ViewProfile(user: user,))) ;
             },
             icon: Icon(Icons.info_outline,color: AppColors.theme['primaryTextColor'],),
           )
          ],
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        height: mq.height*0.25,
        width: mq.width*.6,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .25),
                child: CachedNetworkImage(
                  width: mq.height * .23,
                  height: mq.height * .23,
                  fit: BoxFit.cover,
                  imageUrl:user.image,
                  errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(CupertinoIcons.person)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
