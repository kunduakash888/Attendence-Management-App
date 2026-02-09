import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Auth/AuthScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: Platform.isAndroid
          ? const FirebaseOptions(
        apiKey: "AIzaSyDcCbUNfOhaXCG3UEA5EviqSHjEVWGRGJA",
        authDomain: "",
        projectId: "attendencemanagement-36f7e",
        storageBucket: "attendencemanagement-36f7e.appspot.com",
        messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
        appId: "YOUR_APP_ID",
        measurementId: "YOUR_MEASUREMENT_ID",
      )
          : null,
    );
    debugPrint("Firebase initialized successfully");
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:AuthScreen(),
    );
  }
}