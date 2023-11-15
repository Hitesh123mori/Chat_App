
import 'package:chatapp/apis/Apis.dart';
import 'package:chatapp/effects/transition5.dart';
import 'package:chatapp/models/chat_user.dart';
import 'package:chatapp/screens/profile.dart';
import 'package:chatapp/theme/colors.dart';
import 'package:chatapp/widgets/user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<ChatUser> _list = [] ;

  final List<ChatUser> _searchList = [] ;

  bool _isSearching = true;


  @override
  void initState(){
    super.initState();
    Api.getSelfInfo();

    SystemChannels.lifecycle.setMessageHandler((message) {
      print('Message: $message');

      if (Api.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          Api.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          Api.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });

  }
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: (){
          if(!_isSearching){
            setState(() {
              _isSearching = !_isSearching ;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }

        },
        child: Scaffold(
          backgroundColor: AppColors.theme['backgroundColor'],
          appBar: AppBar(
            leading: Icon(CupertinoIcons.home),
            actions: [
              IconButton(
                onPressed: () {

                  setState(() {
                    _isSearching = !_isSearching;
                  });

                },
                icon: _isSearching ? Icon(Icons.search) : Icon(CupertinoIcons.clear_circled),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context, SizeTransition5(ProfileScreen(user:Api.me))) ;
                },
                icon: Icon(Icons.more_vert),
              ),
            ],
            title: _isSearching ? Text("ChatWith"):  Center(
              child: Container(
                // width: 300,
                height: 40,
                child: TextField(
                  onChanged: (val){
                    _searchList.clear();
                    for (var i in _list){
                      if(i.name.toLowerCase().contains(val.toLowerCase())||i.email.toLowerCase().contains(val.toLowerCase())){
                        _searchList.add(i) ;
                      }
                      setState(() {
                        _searchList;
                      });
                    }


                  },
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: AppColors.theme['secondaryTextColor']), // Unfocused border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.green), // Focused border color
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.red), // Error border color
                    ),
                    hintText: "Search Here...",
                    prefixIcon: Icon(Icons.search),
                    prefixIconColor: Colors.white,
                    hintStyle: TextStyle(color:AppColors.theme['secondaryTextColor']),
                    alignLabelWithHint: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),// Set text alignment to center
                  ),
                  autocorrect: true,
                  autofocus: true,
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: AppColors.theme['appbarColor'],
           onPressed: (){},
            child: Icon(Icons.comment_rounded),
          ),
          body: StreamBuilder(
            stream: Api.getAllUsers(),
            builder: (context, snapshot) {
              switch(snapshot.connectionState){
                case ConnectionState.waiting :
                case ConnectionState.none :
                  return const Center(child: CircularProgressIndicator(),) ;
                case ConnectionState.active:
                case ConnectionState.done:
                   final data = snapshot.data?.docs ;
                  _list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [] ;
                  if(_list.isNotEmpty){
                    return ListView.builder(
                        itemCount:_isSearching ? _list.length : _searchList.length,
                        physics:  BouncingScrollPhysics(),
                        itemBuilder: (context,index){
                          return UserCard(user: _isSearching ? _list[index] :_searchList[index]) ;
                        }) ;
                  }
                  return Center(
                    child: Container(
                      child:Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("No user found",style: TextStyle(color: Colors.grey,fontSize: 35),) ,
                        ],
                      )

                    ),
                  ) ;

              }
            },
          ),
        ),
      ),
    );
  }
}

