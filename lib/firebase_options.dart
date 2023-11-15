// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAaHjIr_jo0FQR3AJ05necU8Eypx6IHA7I',
    appId: '1:1076295220658:android:3088fe4d14a55b199978ab',
    messagingSenderId: '1076295220658',
    projectId: 'chatwith-f392c',
    storageBucket: 'chatwith-f392c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB0K9W_wmJ6ETOHFQqEUfOBykzSq1dhDNo',
    appId: '1:1076295220658:ios:9656469b69b9bfe39978ab',
    messagingSenderId: '1076295220658',
    projectId: 'chatwith-f392c',
    storageBucket: 'chatwith-f392c.appspot.com',
    androidClientId: '1076295220658-lvg4hskrg8gtccm92mua8cpncpkbqmss.apps.googleusercontent.com',
    iosClientId: '1076295220658-9b729bvcldbvfphgjobg4optutagk0fc.apps.googleusercontent.com',
    iosBundleId: 'com.example.chatapp',
  );
}
