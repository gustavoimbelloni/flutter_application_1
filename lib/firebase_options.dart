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
    apiKey: 'AIzaSyA1arix8sj-8PaK73JDYqEUZ2n2J7_iMUU',
    appId: '1:654183373660:web:aa8b68fe3dbf0e34793f99',
    messagingSenderId: '654183373660',
    projectId: 'sos-pets-7f1eb',
    authDomain: 'sos-pets-7f1eb.firebaseapp.com',
    storageBucket: 'sos-pets-7f1eb.appspot.com',
    measurementId: 'G-BQG2MMG7XT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBag9zT46JugMg_pq2Zy_SE1yK5HQuUr1M',
    appId: '1:654183373660:android:da263089b3d82413793f99',
    messagingSenderId: '654183373660',
    projectId: 'sos-pets-7f1eb',
    storageBucket: 'sos-pets-7f1eb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDFrsBpsK43uoytx6e9EuiVx0n6c6a6Km8',
    appId: '1:654183373660:ios:87c983a6793e564e793f99',
    messagingSenderId: '654183373660',
    projectId: 'sos-pets-7f1eb',
    storageBucket: 'sos-pets-7f1eb.appspot.com',
    iosClientId: '654183373660-tadf9e0l6ivvutds1rggaj6rptjr0hrh.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDFrsBpsK43uoytx6e9EuiVx0n6c6a6Km8',
    appId: '1:654183373660:ios:87c983a6793e564e793f99',
    messagingSenderId: '654183373660',
    projectId: 'sos-pets-7f1eb',
    storageBucket: 'sos-pets-7f1eb.appspot.com',
    iosClientId: '654183373660-tadf9e0l6ivvutds1rggaj6rptjr0hrh.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA1arix8sj-8PaK73JDYqEUZ2n2J7_iMUU',
    appId: '1:654183373660:web:891b4ff239d18e05793f99',
    messagingSenderId: '654183373660',
    projectId: 'sos-pets-7f1eb',
    authDomain: 'sos-pets-7f1eb.firebaseapp.com',
    storageBucket: 'sos-pets-7f1eb.appspot.com',
    measurementId: 'G-T46R1ZQR09',
  );
}