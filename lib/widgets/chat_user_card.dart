import 'package:chat_me/main.dart';
import 'package:chat_me/models/chat_user.dart';
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
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      elevation: 2,
      child: InkWell(
        onTap: () {},
        child: ListTile(
          //leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
          leading: ClipRRect(
  borderRadius: BorderRadius.circular(mq.height * .3),
  child: kIsWeb
      ? Image.network(
          widget.user.image,
          width: mq.height * .055,
          height: mq.height * .055,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
        )
      : CachedNetworkImage(
          width: mq.height * .055,
          height: mq.height * .055,
          imageUrl: widget.user.image,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
),

          title: Text(widget.user.name),
          subtitle: Text(widget.user.about, maxLines: 1),
          //trailing: Text('12:00 PM'),
          trailing: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(color: Colors.green.shade400, borderRadius: BorderRadius.circular(50)),
          ),
        ),
      ),
    );
  }
}
