import 'package:chat_me/api/apis.dart';
import 'package:chat_me/main.dart';
import 'package:chat_me/widgets/chat_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: Icon(CupertinoIcons.home),
        title: Text('Chat Me'),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_sharp)),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await APIs.auth
              .signOut(); // FirebaseAuth.signOut(): Logs out the user from Firebase.
          await GoogleSignIn()
              .signOut(); //Logs out the user from their Google account (used in sign-in).
        },
        child: Icon(Icons.add_comment_rounded),
      ),

      body: ListView.builder(
        itemCount: 50,
        padding: EdgeInsets.only(top: mq.height * .01),
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, int) {
          return ChatUserCard();
        },
      ),
    );
  }
}
