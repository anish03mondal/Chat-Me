import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_me/main.dart';
import 'package:chat_me/models/chat_user.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: mq.width < 600 ? mq.width * .9 : mq.width * .5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Picture
            Material(
              elevation: 6,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: user.image,
                width: mq.height * .16,
                height: mq.height * .16,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, size: 60),
              ),
            ),
            const SizedBox(height: 20),

            // Name
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Email
            Text(
              user.email,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // About (optional)
            if (user.about.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.about,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
