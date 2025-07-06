import 'package:chat_me/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Me',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 19),
      backgroundColor: Colors.white,
        )
      ),
      home: HomeScreen(),
    );
  }
}

