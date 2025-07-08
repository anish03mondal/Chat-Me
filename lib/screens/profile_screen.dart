import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_me/api/apis.dart';
import 'package:chat_me/main.dart';
import 'package:chat_me/models/chat_user.dart';
import 'package:chat_me/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Profile Screen')),

      floatingActionButton: FloatingActionButton.extended(
        //backgroundColor: Colors.redAccent,
        onPressed: () async {
          await APIs.auth
              .signOut(); // FirebaseAuth.signOut(): Logs out the user from Firebase.
          await GoogleSignIn()
              .signOut(); //Logs out the user from their Google account (used in sign-in).
        },
        icon: Icon(Icons.logout),
        label: Text('Logout'),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
        child: Column(
          children: [
            SizedBox(width: mq.width, height: mq.height * .03),
            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .1),
              child: kIsWeb
                  ? Image.network(
                      widget.user.image,
                      width: mq.height * .2,
                      height: mq.height * .2,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.error),
                    )
                  : CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,
                      fit: BoxFit.fill,
                      imageUrl: widget.user.image,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
            ),

            SizedBox(height: mq.height * .03),

            Text(widget.user.email, style: TextStyle(fontSize: 18)),

            SizedBox(height: mq.height * .05),

            TextFormField(
              initialValue: widget.user.name,
              decoration: InputDecoration(
                prefix: Icon(Icons.person, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'eg yo yo Anish',
                label: Text('Name'),
              ),
            ),

            SizedBox(height: mq.height * .02),

            TextFormField(
              initialValue: widget.user.about,
              decoration: InputDecoration(
                prefix: Icon(Icons.info_outline, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Felling happy',
                label: Text('About'),
              ),
            ),

            SizedBox(height: mq.height * .05),

            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.edit),
              label: Text('UPDATE'),
            ),
          ],
        ),
      ),
    );
  }
}
