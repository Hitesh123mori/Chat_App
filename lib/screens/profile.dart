import 'dart:io';
import 'package:chatapp/apis/Apis.dart';
import 'package:chatapp/effects/transition4.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_user.dart';
import 'package:chatapp/screens/auth/login_screen.dart';
import 'package:chatapp/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chatapp/helper/dialogs.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user ;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);



  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final _formkey =  GlobalKey<FormState>() ;
  String? _image ;
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size ;
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.theme['backgroundColor'],
        appBar: AppBar(
          title: Text("Profile"),
        ),

        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.logout),
          label: Text("LOGOUT"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: AppColors.theme['appbarColor'],
          onPressed: () async {
            Dialogs.showProgressBar(context);
            await Api.auth.signOut().then((value) async {
              await GoogleSignIn().signOut().then((value){
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushReplacement(context,SizeTransition4(LoginScreen())) ;
                Dialogs.showSnackbar(context, "Logout Successfully done") ;
              });
            }) ;

            // Navigator.pushReplacement(context, SizeTransition4(LoginScreen()));
          },
        ),

        body:Form(
          key: _formkey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 23.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children : [
                  SizedBox(height: mq.height*.05,width: mq.width*1,),
                  Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      _image!=null ?
                          ClipRRect(
                            borderRadius: BorderRadius.circular(90),
                            child: Image.file(
                              File(_image!),
                              width: mq.width*0.4,
                              height: mq.width*0.4,
                              fit: BoxFit.cover,
                            ),
                          ):

                      CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.white30,
                      backgroundImage: NetworkImage(widget.user.image),
                    ),
                      InkWell(
                        onTap: (){
                          showBottomSheet() ;
                        },
                        child: CircleAvatar(
                          child: Icon(Icons.edit),
                          backgroundColor: AppColors.theme['appbarColor'],
                        ),
                      )
                  ]
                  ),
                  SizedBox(height: mq.height*.05),
                  Text(widget.user.email,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: AppColors.theme['primaryTextColor']),),
                  SizedBox(height: mq.height*.05),
                  TextFormField(
                    style: TextStyle(color: AppColors.theme['primaryTextColor']),
                    cursorColor:Colors.white,
                    initialValue: widget.user.name,
                    onSaved: (val)=> Api.me.name = val ?? '',
                    validator: (val)=> val!=null &&  val.isNotEmpty ? null :  "Required Field",
                    decoration:InputDecoration(
                      label:Text("Name"),
                      hintText: "eg. John",
                      labelStyle: TextStyle(color: AppColors.theme['secondaryTextColor']),
                      hintStyle: TextStyle(color: AppColors.theme['secondaryTextColor']),
                      prefixIcon: Icon(Icons.person,color: AppColors.theme['iconColor'],),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.theme['appbarColor']),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: AppColors.theme['appbarColor']), // Unfocused border color
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.green), // Focused border color
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.red), // Error border color
                      ),
                    ),
                  ),
                  SizedBox(height: mq.height*.02),
                  TextFormField(
                    style: TextStyle(color: AppColors.theme['primaryTextColor']),
                    cursorColor:Colors.white,
                    initialValue: widget.user.about,
                    onSaved: (val)=> Api.me.about = val ?? '',
                    validator: (val)=> val!=null &&  val.isNotEmpty ? null :  "Required Field",
                    decoration:InputDecoration(
                      labelStyle: TextStyle(color: AppColors.theme['secondaryTextColor']),
                      hintStyle: TextStyle(color: AppColors.theme['secondaryTextColor']),
                        label:Text("About"),
                        hintText: "eg. Hey I'm using chatWith!",
                        prefixIcon: Icon(Icons.info,color: AppColors.theme['iconColor'],),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: AppColors.theme['appbarColor']), // Unfocused border color
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.green), // Focused border color
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.red), // Error border color
                      ),
                    ),
                  ),
                  SizedBox(height: mq.height*.05),
                  ElevatedButton.icon(
                    icon: Icon(Icons.update,size: 25,),
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: AppColors.theme['appbarColor'],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18), // Adjust the values to increase the size
                    ),
                    onPressed: () {
                        if(_formkey.currentState!.validate()){
                          _formkey.currentState!.save() ;
                          Api.updateUserInfo().then((value) {
                            Dialogs.showSnackbar(context, "Profile Updated") ;
                          }) ;
                          print("inside validator") ;

                        }
                    },
                    label: Text("Update",style: TextStyle(fontSize: 18),),
                  ) ,
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showBottomSheet(){
    showModalBottomSheet(
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
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Text("Pick Profile picture",
                      style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: AppColors.theme['primaryTextColor']),
                    ),
                  ),
                ),
                Padding(
                  padding:EdgeInsets.all(28.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Material(
                            elevation: 28,
                            child: InkWell(
                              onTap: ()async{
                                final ImagePicker picker = ImagePicker();
                                final XFile? image = await picker.pickImage(source: ImageSource.camera);
                                if(image!=null){
                                  print("path : " + image.name + "   Mime type : ${image.mimeType}") ;
                                  Navigator.pop(context);

                                  setState(() {
                                    _image = image.path;
                                  });
                                }

                              },
                              child: Image.asset("assets/images/camara.png",width: 70,height: 70,),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text("Camara",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: AppColors.theme['primaryTextColor']),)
                        ],
                      ),

                      SizedBox(width: mq.height*0.07,),
                      Column(
                        children: [
                          Material(
                            elevation: 28,
                            child: InkWell(
                              onTap: ()async{
                                final ImagePicker picker = ImagePicker();
                                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                if(image!=null){
                                  print("path : " + image.name + "   Mime type : ${image.mimeType}") ;
                                  Navigator.pop(context);

                                  setState(() {
                                    _image = image.path;
                                  });
                                }

                              },
                              child: Image.asset("assets/images/gallary.png",width: 70,height: 70,),
                            ),

                          ),
                          SizedBox(height: 10,),
                          Text("Gallary",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: AppColors.theme['primaryTextColor']),)
                        ],
                      )
                    ],
                  ),
                )

              ],
            ),
          ) ;
    }

    );
  }
}
