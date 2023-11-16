import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/apis/Apis.dart';
import 'package:chatapp/helper/my_date.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_user.dart';
import 'package:chatapp/models/messages.dart';
import 'package:chatapp/theme/colors.dart';
import 'package:chatapp/widgets/view_message_details_card.dart';
import 'package:flutter/material.dart' ;



class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.messages, required this.user});

  final Messages messages ;
  final ChatUser user;


  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size ;
    bool isMe = Api.user.uid == widget.messages.fromId ;
    return InkWell(
      onLongPress: (){
        _showModelSheet();
      },
      child: isMe ? _SentMessage() : _ReceiveMessage(),

    ) ;
  }

  Widget _ReceiveMessage(){
    if(widget.messages.read.isEmpty){
      Api.updateMessageReadStatus(widget.messages) ;
      print("Read Time Updated") ;
    }
    return Row(
      children: [
        Flexible(
          child: Container(
            width: mq.width*0.7,
            padding: EdgeInsets.only(top: 12,left: 16),
            margin: EdgeInsets.symmetric(horizontal:mq.width*0.01,vertical: mq.height*0.005),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: Colors.black54,
            ),
            child: widget.messages.type  == Type.text ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                     widget.messages.msg ,
                  style: TextStyle(color:AppColors.theme['primaryTextColor'],fontSize: 16),
                ),
                Padding(
                  padding: EdgeInsets.only(left: mq.width*0.49,top: 3,bottom: 10,right: mq.width*0.03),
                  child: Text(MyDateUtil.getFormattedTime(context: context,time:widget.messages.sent),style: TextStyle(color: AppColors.theme['secondaryTextColor'],fontSize: 13),),
                ),
              ],
            ) :Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 13.0,vertical: 13.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: widget.messages.msg,
                        placeholder: (context, url) =>Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child:  Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: AppColors.theme['primaryTextColor'],),
                              SizedBox(width: 10,),
                              Text("Loading Image",style: TextStyle(color: AppColors.theme['primaryTextColor']),)
                            ],
                          )),
                        ),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.image, size: 70),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: mq.width*0.49,top: 3,bottom: 10,right: mq.width*0.03),
                  child: Text(MyDateUtil.getFormattedTime(context: context,time:widget.messages.sent),style: TextStyle(color: AppColors.theme['secondaryTextColor'],fontSize: 13),),
                ),
              ],
            ) ,
          ),
        ),
      ],
    ) ;
  }

  Widget _SentMessage() {

    bool isOnline = false;

    if(widget.user.lastActive == DateTime.now().millisecondsSinceEpoch){
       isOnline = true;
    }
    else{

      isOnline = false;

    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            width: mq.width*0.7,
            padding: EdgeInsets.only(top: 12, left: 16),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.03, vertical: mq.height * 0.004),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              color: AppColors.theme['appbarColor'],
            ),
            child: widget.messages.type == Type.text ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:10.0,right: 10),
                  child: Text(
                    widget.messages.msg,
                    style: TextStyle(
                        color: AppColors.theme['primaryTextColor'], fontSize: 16),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        MyDateUtil.getFormattedTime(
                            context: context, time: widget.messages.sent),
                        style: TextStyle(
                            color: AppColors.theme['secondaryTextColor'],
                            fontSize: 13),
                      ),
                    ),
                    if (widget.messages.read.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(right: mq.width*0.05),
                        child: Icon(
                          Icons.done_all,
                          size: 21,
                          color: Colors.blue,
                        ),
                      )
                    else if (isOnline ==true && widget.messages.read.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(right: mq.width*0.05),
                        child: Icon(
                          Icons.done_all,
                          size: 21,
                          color: AppColors.theme['secondaryTextColor'],
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.only(right: mq.width*0.05),
                        child: Icon(
                          Icons.done,
                          size: 21,
                          color: AppColors.theme['secondaryTextColor'],
                        ),
                      ),
                  ],
                ),
              ],
         )  :Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.messages.msg,
                      placeholder: (context, url) =>  Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child:  Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: AppColors.theme['primaryTextColor'],),
                              SizedBox(width: 10,),
                              Text("Loading Image",style: TextStyle(color: AppColors.theme['primaryTextColor']),)
                            ],
                          ),
                        )),
                      ),
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.image, size: 70),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        MyDateUtil.getFormattedTime(
                            context: context, time: widget.messages.sent),
                        style: TextStyle(
                            color: AppColors.theme['secondaryTextColor'],
                            fontSize: 13),
                      ),
                    ),
                    if (widget.messages.read.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(right: mq.width*0.05),
                        child: Icon(
                          Icons.done_all,
                          size: 21,
                          color: Colors.blue,
                        ),
                      )
                    else if (isOnline ==true && widget.messages.read.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(right: mq.width*0.05),
                        child: Icon(
                          Icons.done_all,
                          size: 21,
                          color: AppColors.theme['secondaryTextColor'],
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.only(right: mq.width*0.05),
                        child: Icon(
                          Icons.done,
                          size: 21,
                          color: AppColors.theme['secondaryTextColor'],
                        ),
                      ),
                  ],
                ),
              ],
            ) ,
          ),
        ),

      ],
    );
  }

  Future _showModelSheet(){
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            )
        ),
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.theme['backgroundColor'],
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(height: 20,),
                Center(child: Text("Message Details",style: TextStyle(fontSize: 18,color: AppColors.theme['primaryTextColor'],fontWeight: FontWeight.w400),)),
                SizedBox(height: 20,),
                widget.messages.type == Type.text  ?
                MessageDetailCard(text: 'Copy Text', icon: Icon(Icons.copy,color: AppColors.theme['primaryTextColor'],), ontap: () {  },) :
                MessageDetailCard(text: 'Save image', icon: Icon(Icons.download,color: AppColors.theme['primaryTextColor'],), ontap: () {  },),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Divider(height: 30,thickness:2,),
                ),
                if(widget.messages.type==Type.text && Api.user.uid == widget.messages.fromId)
                    MessageDetailCard(text: 'Edit Text', icon: Icon(Icons.edit,color: AppColors.theme['primaryTextColor'],), ontap: () {  },),
                if(widget.messages.type==Type.text && Api.user.uid == widget.messages.fromId)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Divider(height: 30,thickness: 2,),
                    ),


                Row(
                  children: [
                    MessageDetailCard(text: 'Read Time : ', icon: Icon(Icons.done_all,color: Colors.blue), ontap: () {  },),
                    Text(widget.messages.read.isNotEmpty ? MyDateUtil.getMessageTime(context: context, time: widget.messages.read) : "Haven't seen it yet",style: TextStyle(fontSize: 18,color:AppColors.theme['secondaryTextColor'],fontWeight: FontWeight.w400),),
                  ],
                ),
                Row(
                  children: [
                    MessageDetailCard(text: 'Sent Time : ', icon: Icon(Icons.done_all,color: AppColors.theme['secondaryTextColor']), ontap: () {  },),
                    Text(MyDateUtil.getMessageTime(context: context, time: widget.messages.sent),style: TextStyle(fontSize: 18,color:AppColors.theme['secondaryTextColor'],fontWeight: FontWeight.w400),),
                  ],
                ),


              ],

            ),
          ) ;



        }

    ) ;
  }

}
