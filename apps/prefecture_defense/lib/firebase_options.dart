import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'dart:io';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) {
      return android;
    }
    if (Platform.isIOS) {
      return ios;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdIuk0UifwgliMGDdU-06TwUsvkJESPc0',
    appId: '1:250444577503:android:a09c016319d25f05c1476a',
    messagingSenderId: '250444577503',
    projectId: 'petit-works-games',
    databaseURL: 'https://petit-works-games-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC4gaFcLxN8iT7xm6JeIM7Iou-efE5g5SM',
    appId: '1:946448575860:ios:e59a3ae6f5fba47237d021',
    messagingSenderId: '946448575860',
    projectId: 'apps2-752cb',
    storageBucket: 'apps2-752cb.firebasestorage.app',
    iosBundleId: 'com.yourwish.nihonryoudodefence',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBLU_example_key_REPLACE_WITH_REAL_KEY',
    appId: '1:123456789:web:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'geography-puzzle-king',
    authDomain: 'geography-puzzle-king.firebaseapp.com',
    databaseURL: 'https://geography-puzzle-king.firebaseio.com',
    storageBucket: 'geography-puzzle-king.appspot.com',
  );
}
