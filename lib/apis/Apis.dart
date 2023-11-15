import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chatapp/models/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

import '../models/chat_user.dart';


class Api {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self information
  static ChatUser me = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using We Chat!",
      image: user.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',

  );

  // to return current user
  static User get user => auth.currentUser!;


  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I'm using We Chat!",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {


    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }


  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }


  ///************** Chat Screen Related APIs **************

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {

    print(getConversationID(user.id)) ;
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .snapshots();

  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg,Type type) async {
    //message sending time (also used as id)
    print("#CreateChat");
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Messages message = Messages(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type:type,
        fromId: user.uid,
        sent: time
    );
    final messageJson = message.toJson();
    print(messageJson) ;
   print("id  : ${getConversationID(chatUser.id)}") ;
    // final ref = firestore.collection("chats/${getConversationID(chatUser.id)}/messages/");
    await firestore.collection("chats/${getConversationID(chatUser.id)}/messages/").doc("$time").set(messageJson).onError((e, _) => print("Error writing document: $e"));
    // await firestore.collection("chats").doc("${getConversationID(chatUser.id)}").collection("messages").doc("$time").set(message.toJson());

    print("#ChatAdded");
  }


  static Future<void> updateMessageReadStatus(Messages messages) async{
    firestore.collection("chats/${getConversationID(messages.fromId)}/messages/").doc(messages.sent).update({'read': DateTime.now().millisecondsSinceEpoch.toString() }) ;
  }



  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent',descending: true)
        .limit(1)
        .snapshots();

  }


  static Future<int> countUnreadMessages(ChatUser chatUser) async {
    final conversationID = getConversationID(chatUser.id);

    final messages = await firestore
        .collection('chats/$conversationID/messages')
        .where('read', isEqualTo: '')
        .get();

    return messages.docs.length;
  }


  static Future<void> sendChatImage(ChatUser chatUser,File file)async{
    final ext  = file.path.split('.').last ;
    final ref = storage.ref().child('images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext') ;

    await ref.putFile(file,SettableMetadata(contentType: 'image/$ext')).then((po){
      print("Data send}") ;
    }) ;


    final imageUrl = await ref.getDownloadURL() ;
    await Api.sendMessage(chatUser, imageUrl, Type.image) ;




  }


}