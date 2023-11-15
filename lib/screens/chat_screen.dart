import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/apis/Apis.dart';
import 'package:chatapp/effects/transition4.dart';
import 'package:chatapp/helper/my_date.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_user.dart';
import 'package:chatapp/models/messages.dart';
import 'package:chatapp/screens/home_screen.dart';
import 'package:chatapp/theme/colors.dart';
import 'package:chatapp/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  double _textFieldMaxHeight = 130.0;
  FocusNode _messageFocusNode = FocusNode();
  bool _isMessageTextFieldFocused = false;
  final _textController = TextEditingController();
  bool _showEmoji = false;
  bool _isUploading = false ;


  List<Messages> _list = []; // Store messages here


  @override
  void dispose() {
    _messageFocusNode.dispose(); // Dispose of the ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: (){
          if(_showEmoji){
            setState(() {
              _showEmoji = !_showEmoji ;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }

        },
        child: SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.theme['backgroundColor'],
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: buildAppbar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: Api.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          // return const SizedBox();
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                              ?.map((e) => Messages.fromJson(e.data()))
                              .toList() ??
                              [];
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              // controller: _scrollController,
                              reverse:  true ,
                              itemCount: _list.length,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(messages: _list[index], user: widget.user);
                              },
                            );
                          } else {
                            return Center(
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Say Hii! 👋",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),
                if(_isUploading)
                  Center(child: Padding(
                    padding:  EdgeInsets.only(left: mq.width*0.23),
                    child: Container(
                       decoration: BoxDecoration(
                         color: AppColors.theme['appbarColor'],
                         borderRadius: BorderRadius.circular(20).copyWith(
                           topRight: Radius.circular(0),

                         )
                       ),
                        width: mq.width*0.7,
                        height: mq.height*0.18,

                        child: Center(child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            CircularProgressIndicator(color: AppColors.theme['primaryTextColor'],),
                            SizedBox(width: 10,),
                            Text("Uploading Image",style: TextStyle(color: AppColors.theme['primaryTextColor']),)
                          ],
                        ))
                    ),
                  )) ,
                buildChatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * 0.35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                          bgColor: AppColors.theme['backgroundColor'],
                          indicatorColor: Colors.white,
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget buildAppbar() {
    return InkWell(
        onTap: () {
        },
        child: StreamBuilder(
            stream: Api.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [] ;
              return Row(
                children: [
                  //back button
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                       Icon(Icons.arrow_back, color:AppColors.theme['primaryTextColor'])),

                  //user profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: CachedNetworkImage(
                      width: mq.height * .05,
                      height: mq.height * .05,
                      imageUrl:
                      list.isNotEmpty ? list[0].image : widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),

                  //for adding some space
                  const SizedBox(width: 10),

                  //user name & last seen time
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //user name
                      Text(list.isNotEmpty ? list[0].name : widget.user.name,
                          style:  TextStyle(
                              fontSize: 16,
                              color: AppColors.theme['primaryTextColor'],
                              fontWeight: FontWeight.w500)),

                      //for adding some space
                      const SizedBox(height: 2),

                      //last seen time of user
                      Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: list[0].lastActive)
                              : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: widget.user.lastActive),
                          style:  TextStyle(
                              fontSize: 13, color: AppColors.theme['primaryTextColor'])),
                    ],
                  )
                ],
              );
            }));
  }


  Widget buildChatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: mq.width * 0.01,
        vertical: mq.height * 0.01,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              elevation: 34,
              color: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: mq.width * 0.03),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        FocusScope.of(context).unfocus() ;
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: Icon(
                      Icons.emoji_emotions,
                      color: AppColors.theme['iconColor'],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(maxHeight: _textFieldMaxHeight),
                      child: SingleChildScrollView(
                        child: TextField(
                          controller: _textController,
                          focusNode: _messageFocusNode,
                          onChanged: (text) {
                            setState(() {

                              _isMessageTextFieldFocused = _messageFocusNode.hasFocus;
                            });
                          },
                          onTap: () {
                            setState(() {
                              _isMessageTextFieldFocused = _messageFocusNode.hasFocus;

                            });
                            if(_showEmoji)setState(() {
                              _showEmoji =!_showEmoji ;
                            });
                          },
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          cursorColor: Colors.white,
                          style: TextStyle(
                            color: AppColors.theme['primaryTextColor'],
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type Message...",
                            hintStyle: TextStyle(
                              color: AppColors.theme['secondaryTextColor'],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!_isMessageTextFieldFocused)
                    IconButton(
                      onPressed: () async{
                        final ImagePicker picker  = ImagePicker() ;

                        final XFile ?image =  await picker.pickImage(source:ImageSource.camera,imageQuality: 100) ;
                        if(image!=null){
                          print("Image path : ${image.path}") ;
                          setState(() {
                            _isUploading = true ;
                          });
                          await Api.sendChatImage(widget.user, File(image.path)) ;
                          setState(() {
                            _isUploading = false ;
                          });
                        }

                      },
                      icon: Icon(
                        Icons.camera_alt,
                        color: AppColors.theme['iconColor'],
                      ),
                    ),
                  if (!_isMessageTextFieldFocused)
                    IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> image = await picker.pickMultiImage();
                        for(var i in image){
                          setState(() {
                            _isUploading = true ;
                          });
                            print("path : " + i.name + "   Mime type : ${i.mimeType}") ;
                            await Api.sendChatImage(widget.user, File(i.path)) ;
                            setState(() {
                              _isUploading = false ;
                            });
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        color: AppColors.theme['iconColor'],
                      ),
                    ),
                  SizedBox(width: mq.width * 0.03),
                ],
              ),
            ),
          ),
          MaterialButton(
            minWidth: 0,
            shape: CircleBorder(),
            onPressed: () {
              setState(() {
                _isMessageTextFieldFocused = false;
              });
              if (_textController.text.isNotEmpty) {
                Api.sendMessage(widget.user, _textController.text,Type.text);
                _textController.text = "";
              }
              // Handle sending a message
            },
            color: AppColors.theme['appbarColor'],
            child: Icon(Icons.send),
            padding: EdgeInsets.all(10),
          ),
        ],
      ),
    );
  }
}
