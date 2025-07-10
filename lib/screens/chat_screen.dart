import 'package:cached_network_image/cached_network_image.dart';
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
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
            ),
        
            // for adding some space
            SizedBox(width: 10,),
        
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.user.name,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                ),
        
                SizedBox(height: 2,),
        
                //last seen time of user
                Text("Last seen not available",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  //fontWeight: FontWeight.w500,
                ),
                ),
        
              ],
            )
          ],
        ),
      ),
    );
  }
}
