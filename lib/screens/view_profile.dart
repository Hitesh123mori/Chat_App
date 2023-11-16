import 'package:chatapp/helper/my_date.dart';
import 'package:flutter/material.dart' ;

import '../main.dart';
import '../models/chat_user.dart';
import '../theme/colors.dart';
import '../widgets/view_profile_card.dart';

class ViewProfile extends StatefulWidget {
  final ChatUser user ;
  const ViewProfile({super.key, required this.user});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size ;
    return  Scaffold(
        backgroundColor: AppColors.theme['backgroundColor'],
        appBar: AppBar(
          title: Text("${widget.user.name}'s Profile"),
        ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: mq.height*0.03,),

            CircleAvatar(
              radius: 75,
              backgroundColor: Colors.white30,
              backgroundImage: NetworkImage(widget.user.image),
            ),

            SizedBox(height: mq.height*0.03,),

            Text(widget.user.email,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: AppColors.theme['primaryTextColor']),),

            SizedBox(height: mq.height*0.03,),

            CustomUserInfoCard(title: 'Name : ', text: widget.user.name,),

            SizedBox(height: mq.height*0.001,),

            CustomUserInfoCard(title: 'About : ', text: widget.user.about,),


            SizedBox(height: mq.height*0.001,),

            Padding(
              padding:  EdgeInsets.symmetric(horizontal: mq.width*0.28,vertical: 18),
              child: Row(
                children: [
                  Text("Joined On ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:Colors.green),),
                  Text(MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: AppColors.theme['primaryTextColor']),),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
