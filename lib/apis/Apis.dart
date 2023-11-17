import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chatapp/models/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  // for notification
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;

  // to return current user
  static User get user => auth.currentUser!;

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
    pushToken: '',
  );

// for get push token
  static Future<void> getFirebaseMessagingToken() async {
    await fmessaging.requestPermission();

    await fmessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });
// foreground notificaion
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

// check user existance
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // adding selected chat user
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

      return false;
    }
  }

  // selecteed chat user
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for pushing notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name,
          "body": msg,
          "android_channel_id": "Chats",
        },
        "data": {
          "some_data": "user id : ${me.id}",
        },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAA-pgxvbI:APA91bHY45r9UrdF9GTa9X47ebaNyOR4HLoFsCO-z8Fxs182jB6nRmg-b3QTlZ9cNZnMV75h63Y_ULtDEnXpRiL8IJaCLl5LyRVNt-lG2W35yfBVGK4o3uLg9LJzdXsOsC1hqts2eyB4'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using chatWith",
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // get all users for displaying it into home screen

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // update user self information
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  // get user information

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // user online/offiline  feature

  static Future<void> updateActiveStatus(bool isOnline) async {
    print("status updated");
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  // updating current user profile picture

  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  ///************** Chat Screen Related APIs **************

  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    print(getConversationID(user.id));
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    print("#CreateChat");
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Messages message = Messages(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);
    final messageJson = message.toJson();
    print(messageJson);
    print("id  : ${getConversationID(chatUser.id)}");
    await firestore
        .collection("chats/${getConversationID(chatUser.id)}/messages/")
        .doc("$time")
        .set(messageJson)
        .then((value) =>
            sendPushNotification(chatUser, type == Type.text ? msg : "image"));

    print("#ChatAdded");
  }

  // if messsage read them update read time

  static Future<void> updateMessageReadStatus(Messages messages) async {
    firestore
        .collection("chats/${getConversationID(messages.fromId)}/messages/")
        .doc(messages.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get last message for displaying it in home screen

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // count unread message for displaying it in home screen

  static Future<int> countUnreadMessages(ChatUser chatUser) async {
    final conversationID = getConversationID(chatUser.id);

    final messages = await firestore
        .collection('chats/$conversationID/messages')
        .where('read', isEqualTo: '')
        .get();

    return messages.docs.length;
  }

  // sending image and store it into firebase storage

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((po) {
      print("Data send}");
    });

    final imageUrl = await ref.getDownloadURL();
    await Api.sendMessage(chatUser, imageUrl, Type.image);
  }

  // for delete message from char

  static Future<void> deleteMessage(Messages message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  // for updateting message

  static Future<void> updateMessage(Messages message,String updatedMessage) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({"msg":updatedMessage});
  }
}
