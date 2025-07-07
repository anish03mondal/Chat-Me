import 'package:chat_me/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key});

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
    onTap: () {
      
    },
    child: ListTile(
      leading: CircleAvatar(child: Icon(CupertinoIcons.person),),
      title: Text('Demo User'),
      subtitle: Text('Last User Message', maxLines: 1,),
      trailing: Text('12:00 PM'),
      
    ),
  ),
);

  }
}
