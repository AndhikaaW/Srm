// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC5fig-UmpIW110k1iRZ4KDWKdINYRro3c',
    appId: '1:78903768048:web:561fec3e0f2dd78ddba335',
    messagingSenderId: '78903768048',
    projectId: 'srmmotor-4e708',
    authDomain: 'srmmotor-4e708.firebaseapp.com',
    storageBucket: 'srmmotor-4e708.appspot.com',
    measurementId: 'G-D72N5221M1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_-9WGRrR2AYaqmBweFt_vOlhdE97Oyp8',
    appId: '1:78903768048:android:7fcbe9677ae1265edba335',
    messagingSenderId: '78903768048',
    projectId: 'srmmotor-4e708',
    storageBucket: 'srmmotor-4e708.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB7QRGYYzISFd6OHWwedtSYeJLpp2d4zK8',
    appId: '1:78903768048:ios:2e0effec7b2d45addba335',
    messagingSenderId: '78903768048',
    projectId: 'srmmotor-4e708',
    storageBucket: 'srmmotor-4e708.appspot.com',
    iosBundleId: 'com.example.srmV1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB7QRGYYzISFd6OHWwedtSYeJLpp2d4zK8',
    appId: '1:78903768048:ios:2e0effec7b2d45addba335',
    messagingSenderId: '78903768048',
    projectId: 'srmmotor-4e708',
    storageBucket: 'srmmotor-4e708.appspot.com',
    iosBundleId: 'com.example.srmV1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC5fig-UmpIW110k1iRZ4KDWKdINYRro3c',
    appId: '1:78903768048:web:62c2edfdd0348dabdba335',
    messagingSenderId: '78903768048',
    projectId: 'srmmotor-4e708',
    authDomain: 'srmmotor-4e708.firebaseapp.com',
    storageBucket: 'srmmotor-4e708.appspot.com',
    measurementId: 'G-4GHHX28MQY',
  );

}