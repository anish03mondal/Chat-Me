import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_me/api/apis.dart';
import 'package:chat_me/main.dart';
import 'package:chat_me/models/chat_user.dart';
import 'package:chat_me/models/message.dart';
import 'package:chat_me/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all meesages
  List<Message> _list = [];

  //for handling message text changes
  final _textController = TextEditingController();

  //for storing value of emoji or hiding emoji
  bool _showEmoji = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 1,
            flexibleSpace: SafeArea(child: _appBar()),
          ),

          backgroundColor: Color.fromARGB(255, 234, 248, 255),

          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  //Used when you want to listen to real-time data (e.g., from Firebase, sockets, or any stream) and update the UI automatically when data changes.
                  stream: APIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      //This switch block handles the various connection states of a StreamBuilder
                      // if data is loading
                      case ConnectionState
                          .waiting: //This means the Stream or Future has not received any data yet — it is still loading.
                      case ConnectionState
                          .done: // it means the Future has completed that may be data
                        return SizedBox();

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
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            itemCount: _list.length,
                            padding: EdgeInsets.only(top: mq.height * .01),
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return MessageCard(message: _list[index]);
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

              // show emojis on keyboard emoji button click & vice versa
              if (_showEmoji)
                SizedBox(
                  height: mq.height * .35,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      emojiViewConfig: EmojiViewConfig(
                        emojiSizeMax: 32 * (kIsWeb ? 1.0 : 1.3),
                        columns: 8,
                        backgroundColor: const Color.fromARGB(
                          255,
                          234,
                          248,
                          255,
                        ),
                      ),
                    ),
                  ),
                ),
              // SizedBox
            ],
          ),
        ),
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
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    },

                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.blueAccent,
                      size: 24,
                    ),
                  ),

                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji)
                          setState(() {
                            _showEmoji = !_showEmoji;
                          });
                      },
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

          // Send message button
          Material(
            color: Colors.green,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () {
                if (_textController.text.isNotEmpty) {
                  APIs.sendMessage(widget.user, _textController.text);
                  _textController.text = '';
                }
              },
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
