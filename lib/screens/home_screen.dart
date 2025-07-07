import 'package:chat_me/api/apis.dart';
import 'package:chat_me/main.dart';
import 'package:chat_me/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';

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

      body: StreamBuilder(
        //Used when you want to listen to real-time data (e.g., from Firebase, sockets, or any stream) and update the UI automatically when data changes.
        stream: APIs.firestore
            .collection('users')
            .snapshots(), //.snapshots(): Returns a stream of real-time updates for that collection
        builder: (context, snapshot) {
          final list = [];

          if (snapshot.hasData) {
            final data = snapshot.data?.docs;
            for (var i in data!) {
              log('Data: ${i.data()}');
              list.add(i.data()['Name']);
            }
          }

          return ListView.builder(
            itemCount: list.length,
            padding: EdgeInsets.only(top: mq.height * .01),
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              //return ChatUserCard();
              return Text('Name: ${list[index]}');

            },
          );
        },
      ),
    );
  }
}
