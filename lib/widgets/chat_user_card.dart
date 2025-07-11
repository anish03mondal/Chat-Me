import 'package:chat_me/api/apis.dart';
import 'package:chat_me/helper/my_date_util.dart';
import 'package:chat_me/main.dart';
import 'package:chat_me/models/chat_user.dart';
import 'package:chat_me/models/message.dart';
import 'package:chat_me/screens/chat_screen.dart';
import 'package:chat_me/widgets/dialogs/profile_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message info (if null -> no messaage)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      elevation: 2,
      child: InkWell(
        onTap: () {
          //for navigatig to chat screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)),
          );
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) _message = list[0];
            return ListTile(
              //leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
              leading: InkWell(
                onTap: () {
                  showDialog(context: context, builder: (_) => ProfileDialog(user: widget.user,));
                },
                child: ClipRRect(
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
                          width: mq.height * .055,
                          height: mq.height * .055,
                          imageUrl: widget.user.image,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                ),
              ),

              title: Text(widget.user.name),
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                          ? 'image'
                          : _message!.msg
                    : widget.user.about,
                maxLines: 1,
              ),
              //trailing: Text('12:00 PM'),
              trailing: _message == null
                  ? null
                  : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                  ? Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    )
                  : Text(
                      MyDateUtil.getLastMessageTime(
                        context: context,
                        time: _message!.sent,
                      ),
                      style: TextStyle(color: Colors.black54),
                    ),
            );
          },
        ),
      ),
    );
  }
}
