import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_me/api/apis.dart';
import 'package:chat_me/helper/dialogs.dart';
import 'package:chat_me/main.dart';
import 'package:chat_me/models/chat_user.dart';
import 'package:chat_me/screens/auth/login_screen.dart';
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
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return GestureDetector(
      // for hidiing keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text('Profile Screen')),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await APIs.auth.signOut(); // Firebase sign-out

            final googleSignIn = GoogleSignIn();
            if (await googleSignIn.isSignedIn()) {
              await googleSignIn.disconnect(); // Important for web
              await googleSignIn.signOut();
            }

            // Optional: small delay to allow cleanup
            await Future.delayed(const Duration(milliseconds: 300));

            // Navigate only if still in widget tree
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
          icon: Icon(Icons.logout),
          label: Text('Logout'),
        ),

        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width, height: mq.height * .03),
                  Stack(
                    children: [
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
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          onPressed: () {},
                          shape: CircleBorder(),
                          color: Colors.white,
                          child: Icon(Icons.edit),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: mq.height * .03),

                  Text(widget.user.email, style: TextStyle(fontSize: 18)),

                  SizedBox(height: mq.height * .05),

                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me?.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
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
                    onSaved: (val) => APIs.me?.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackBar(
                            context,
                            'Profile Updated Successfully',
                          );
                        });
                        log('inside validator');
                      }
                    },
                    icon: Icon(Icons.edit),
                    label: Text('UPDATE'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
