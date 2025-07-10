import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_me/api/apis.dart';
import 'package:chat_me/main.dart';
import 'package:chat_me/models/chat_user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        flexibleSpace: SafeArea(child: _appBar()),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              //Used when you want to listen to real-time data (e.g., from Firebase, sockets, or any stream) and update the UI automatically when data changes.
              stream: APIs.getAllMessages(),
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
                    // _list =
                    //     data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                    //     [];
            
                    final _list = [];
            
                    if (_list.isNotEmpty) {
                      return ListView.builder(
                        itemCount: _list.length,
                        padding: EdgeInsets.only(top: mq.height * .01),
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Text('Message');
                          //return Text('Name: ${list[index]}');
                        },
                      );
                    } else {
                      return Center(
                        child: Text(
                          "Say Hiiii 👋",
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }
                }
              },
            ),
          ),
          _chatInput(),
        ],
      ),
    );
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () {},
        child: Row(
          children: [
            // Back Button
            IconButton(
              onPressed: () {
                Navigator.pop(context); // Go back to previous screen
              },
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),

            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .3),
              child: kIsWeb
                  ? Image.network(
                      widget.user.image,
                      width: mq.height * .055,
                      height: mq.height * .055,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.error),
                    )
                  : CachedNetworkImage(
                      width: mq.height * .05,
                      height: mq.height * .05,
                      imageUrl: widget.user.image,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
            ),

            // for adding some space
            SizedBox(width: 10),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 2),

                //last seen time of user
                Text(
                  "Last seen not available",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    //fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //bottom chat input field
  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          // Chat input box with buttons
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Emoji button
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.blueAccent,
                      size: 24,
                    ),
                  ),

                  // Text input
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "Type something...",
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none,
                      ),
                      //minLines: 1,
                      //maxLines: 4,
                    ),
                  ),

                  // Gallery image button
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.image,
                      color: Colors.blueAccent,
                      size: 24,
                    ),
                  ),

                  // Camera button
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.blueAccent,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          Material(
            color: Colors.green,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(100),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.send, color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
