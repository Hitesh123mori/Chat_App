import 'package:flutter/material.dart' ;

import '../main.dart';
import '../theme/colors.dart';

class MessageDetailCard extends StatelessWidget {
  final String text ;
  final Icon icon ;
  final VoidCallback ontap ;


  const MessageDetailCard({super.key, required this.text, required this.icon, required this.ontap});

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size ;

    return Container(
      child: Padding(

        padding: EdgeInsets.only(left: mq.width*0.1,top: mq.height*0.02,bottom: mq.height*0.02),
        child: Row(
          children: [
            icon,
            SizedBox(width: 20,),
            Text(text,style: TextStyle(fontSize: 18,color: AppColors.theme['primaryTextColor'],fontWeight: FontWeight.w400),),
          ],
        ),
      ),

    );
  }
}
