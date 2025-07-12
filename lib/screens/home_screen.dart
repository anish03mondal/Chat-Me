import 'package:chat_me/api/apis.dart';
import 'package:chat_me/helper/dialogs.dart';
import 'package:chat_me/main.dart';
import 'package:chat_me/models/chat_user.dart';
import 'package:chat_me/screens/profile_screen.dart';
import 'package:chat_me/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //for storing all users
  List<ChatUser> _list = [];

  //for storing searched items
  final List<ChatUser> _searchList = [];

  //for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initUserInfo();

    // for updating user active status according to lifecycle events
    // resume -- active or online
    // pause -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) async {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume'))
          await APIs.updateActiveStatus(true);
        if (message.toString().contains('pause'))
          await APIs.updateActiveStatus(false);
      }

      return Future.value(message);
    });
  }

  Future<void> _initUserInfo() async {
    await APIs.getSelfInfo();
    setState(() {}); // triggers rebuild after `me` is initialized
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return GestureDetector(
      //for hiding keyboard when tap is detected on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(CupertinoIcons.home),
            title: _isSearching
                ? TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name, Email....',
                    ),
                    autofocus: true,
                    style: TextStyle(fontSize: 17, letterSpacing: 0.5),
                    //when search text changes then updated search list
                    onChanged: (val) {
                      _searchList.clear();
                      //search logic
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : Text('Chat Me'),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(
                  _isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(user: APIs.me!),
                    ),
                  );
                },
                icon: Icon(Icons.more_vert_sharp),
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              _addChatUserDialog();
            },
            child: Icon(Icons.add_comment_rounded),
          ),

          body: StreamBuilder(
            stream: APIs.getMyUserId(),
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
                          .none:
                return StreamBuilder(
                  //Used when you want to listen to real-time data (e.g., from Firebase, sockets, or any stream) and update the UI automatically when data changes.
                  stream: APIs.getAllUsers(
                    snapshot.data?.docs.map((e) => e.id).toList() ?? []
                  ),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      //This switch block handles the various connection states of a StreamBuilder
                      // if data is loading
                      case ConnectionState
                          .waiting: //This means the Stream or Future has not received any data yet — it is still loading.
                      case ConnectionState
                          .done: // it means the Future has completed that may be data
                        //return Center(child: CircularProgressIndicator());

                      // if some or all data loaded then show it
                      case ConnectionState
                          .active: //This is used in StreamBuilder and means the stream is actively providing data
                      case ConnectionState
                          .none: //Means no connection was made to the Stream or Future.

                        final data = snapshot
                            .data
                            ?.docs; //This gets the list of documents from Firestore if snapshot.data is not null.
                        _list =
                            data
                                ?.map((e) => ChatUser.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            itemCount: _isSearching
                                ? _searchList.length
                                : _list.length,
                            padding: EdgeInsets.only(top: mq.height * .01),
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ChatUserCard(
                                user: _isSearching
                                    ? _searchList[index]
                                    : _list[index],
                              );
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
                );
              }
              
            },
          ),
        ),
      ),
    );
  }

  // ADD CHAT USER DIALOG
  void _addChatUserDialog() {
    String email = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: 10,
        ),

        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),

        //title
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Colors.blue, size: 28),
            Text('  Add User'),
          ],
        ),

        //content
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => email = value,
          decoration: const InputDecoration(
            hintText: 'Email Id',
            prefixIcon: Icon(Icons.email, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
          ),
        ),

        //actions
        actions: [
          //cancel button
          MaterialButton(
            onPressed: () {
              //hide alert dialog
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),

          //add button
          MaterialButton(
            onPressed: () async {
              //hide alert dialog
              Navigator.pop(context);
              if (email.trim().isNotEmpty) {
                await APIs.addChatUser(email).then((value) {
                  if (!value) {
                    Dialogs.showSnackBar(context, 'User does not Exists!');
                  }
                });
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
