import 'package:chatapp/theme/colors.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class CustomUserInfoCard extends StatelessWidget {
  final String title ;
  final String text;
  const CustomUserInfoCard({super.key, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size ;
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 30.0,vertical: 10),
      child: Container(
        child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: AppColors.theme['primaryTextColor']),) ,
            Text(text,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: AppColors.theme['primaryTextColor']),) ,
          ],
        ),
        height: mq.height*0.08,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:AppColors.theme['appbarColor'],
            ),
         color: AppColors.theme['backgroundColor']
        ),
      ),
    );
  }
}
