import 'package:chatapp/apis/Apis.dart';
import 'package:chatapp/effects/transition5.dart';
import 'package:chatapp/helper/my_date.dart';
import 'package:chatapp/models/chat_user.dart';
import 'package:chatapp/models/messages.dart';
import 'package:chatapp/screens/chat_screen.dart';
import 'package:chatapp/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserCard extends StatefulWidget {
  final ChatUser user;
  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  Messages? _message;
  int? unreadCount  ;

  @override
  void initState() {
    super.initState();
    fetchUnreadMessageCount();
  }

  void fetchUnreadMessageCount() {
    Api.countUnreadMessages(widget.user).then((count) {
      setState(() {
        unreadCount = count;
      });
    }).catchError((error) {

    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.03, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: AppColors.theme['cardColor'],
      elevation: 0.5,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context, SizeTransition5(ChatScreen(user: widget.user)));
        },
        child: StreamBuilder(
          stream: Api.getLastMessages(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Messages.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) {
              _message = list[0];
            }
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white30,
                backgroundImage: NetworkImage(widget.user.image),
              ),
              title: Text(
                widget.user.name,
                style: TextStyle(color: AppColors.theme['primaryTextColor']),
              ),
              subtitle: _message != null
                  ? Row(
                      children: [
                        _message!.type == Type.text
                            ? Text(
                                _message!.msg.length <= 19
                                    ? _message!.msg
                                    : _message!.msg.substring(0, 19) + '...',
                                style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        AppColors.theme['secondaryTextColor']),
                              )
                            : Row(
                                children: [
                                  Icon(Icons.image,
                                      color: AppColors
                                          .theme['secondaryTextColor']),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  Text("Image",
                                      style: TextStyle(
                                          color: AppColors
                                              .theme['secondaryTextColor'])),
                                ],
                              ),
                      ],
                    )
                  : Text(
                      "Say Hii! 👋",
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.theme['secondaryTextColor']),
                    ),
              trailing: _message == null
                  ? null
                  : _message!.read.isEmpty && _message!.fromId != Api.user.uid
                      ? Container(
                          height: 20,
                          width: 20,
                          child: Center(
                            child: Text(
                              unreadCount.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.theme['appbarColor'],
                            borderRadius: BorderRadius.circular(25),
                          ),
                        )
                      : Text(
                          MyDateUtil.getLastMessageTime(
                              context: context, time: _message!.sent),
                          style: TextStyle(
                              color: AppColors.theme['secondaryTextColor']),
                        ),
            );
          },
        ),
      ),
    );
  }
}
