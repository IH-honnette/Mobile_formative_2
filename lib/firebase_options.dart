

// ignore_for_file: constant_identifier_names

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform. '
          'Run `flutterfire configure` to generate them.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-pjQdpPv8lnegHIgN3FWfFrOvMHTenEg',
    appId: '1:626921373428:android:65a8130c4e76ce172368a1',
    messagingSenderId: '626921373428',
    projectId: 'formative2-42a33',
    storageBucket: 'formative2-42a33.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATHSYuLU5S9PSdx53Z0QtRrvtYswNZVCI',
    appId: '1:626921373428:ios:35501ee3c405cf3f2368a1',
    messagingSenderId: '626921373428',
    projectId: 'formative2-42a33',
    storageBucket: 'formative2-42a33.firebasestorage.app',
    iosBundleId: 'com.alu.launchpad',
  );
}
