import 'package:BillingueApp/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'core/theme.dart';
import 'screens/auth/splash_screen.dart';
import 'firebase_options.dart';

/// `flutter run --dart-define=USE_EMULATORS=true` pour tester en local
/// avec `firebase emulators:start` (voir README).
const bool kUseEmulators = bool.fromEnvironment('USE_EMULATORS');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kUseEmulators
        // Projet "demo-" : 100 % local, aucune donnée réelle touchée.
        ? DefaultFirebaseOptions.currentPlatform
            .copyWith(projectId: 'demo-billingue')
        : DefaultFirebaseOptions.currentPlatform,
  );
  if (kUseEmulators) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseFunctions.instanceFor(region: 'europe-west1')
        .useFunctionsEmulator('localhost', 5001);
  }
  // Init notifications
  await NotificationService().init();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const BillingueApp());
}
class BillingueApp extends StatelessWidget {
  const BillingueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billingue',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}