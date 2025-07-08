import 'package:chat_me/api/apis.dart';
import 'package:chat_me/main.dart';
import 'package:chat_me/models/chat_user.dart';
import 'package:chat_me/screens/profile_screen.dart';
import 'package:chat_me/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: Icon(CupertinoIcons.home),
        title: Text('Chat Me'),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen(user: list[0],)),
              );
            },
            icon: Icon(Icons.more_vert_sharp),
          ),
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
          switch (snapshot.connectionState) {
            //This switch block handles the various connection states of a StreamBuilder
            // if data is loading
            case ConnectionState
                .waiting: //This means the Stream or Future has not received any data yet — it is still loading.
            case ConnectionState
                .done: // it means the Future has completed that may be data
              return Center(child: CircularProgressIndicator());

            // if some or all data loaded then show it
            case ConnectionState
                .active: //This is used in StreamBuilder and means the stream is actively providing data
            case ConnectionState
                .none: //Means no connection was made to the Stream or Future.

              final data = snapshot
                  .data
                  ?.docs; //This gets the list of documents from Firestore if snapshot.data is not null.
              list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              if (list.isNotEmpty) {
                return ListView.builder(
                  itemCount: list.length,
                  padding: EdgeInsets.only(top: mq.height * .01),
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChatUserCard(user: list[index]);
                    //return Text('Name: ${list[index]}');
                  },
                );
              } else {
                return Center(
                  child: Text(
                    "No connection found",
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
