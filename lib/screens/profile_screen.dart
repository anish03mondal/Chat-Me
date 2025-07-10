import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_me/api/apis.dart';
import 'package:chat_me/helper/dialogs.dart';
import 'package:chat_me/models/chat_user.dart';
import 'package:chat_me/screens/auth/login_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  late Size mq;

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile Screen')),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await APIs.auth.signOut();

            final googleSignIn = GoogleSignIn();
            if (await googleSignIn.isSignedIn()) {
              await googleSignIn.disconnect();
              await googleSignIn.signOut();
            }

            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),

        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: mq.height * .03),

                  // Profile Picture
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .1),
                        child: _image != null
                            ? Image.network(
                                _image!,
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: widget.user.image,
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error, size: 50),
                              ),
                      ),

                      // Edit Button
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          onPressed: _showBottomSheet,
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: const Icon(Icons.edit),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: mq.height * .03),
                  Text(widget.user.email, style: const TextStyle(fontSize: 18)),

                  SizedBox(height: mq.height * .05),

                  // Name Field
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me?.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'eg: Yo Yo Anish',
                      labelText: 'Name',
                    ),
                  ),

                  SizedBox(height: mq.height * .02),

                  // About Field
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me?.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Feeling happy',
                      labelText: 'About',
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
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('UPDATE'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Bottom Sheet for Image Picker
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
            top: mq.height * .03,
            bottom: mq.height * .05,
          ),
          children: [
            const Text(
              'Pick Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: mq.height * .02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery Picker
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.width * .3, mq.height * .15),
                  ),
                  onPressed: () async {
                    if (kIsWeb) {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                      );
                      if (result != null && result.files.single.bytes != null) {
                        final bytes = result.files.single.bytes!;
                        final fileName = result.files.single.name;
                        final imageUrl = await APIs.uploadWebImageToCloudinary(bytes, fileName);
                        if (imageUrl != null) {
                          await APIs.updateProfileImage(imageUrl);
                          setState(() => _image = imageUrl);
                        }
                      }
                    } else {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        final file = File(image.path);
                        final imageUrl = await APIs.uploadImageToCloudinary(file);
                        if (imageUrl != null) {
                          await APIs.updateProfileImage(imageUrl);
                          setState(() => _image = imageUrl);
                        }
                      }
                    }
                    if (mounted) Navigator.pop(context);
                  },
                  child: Image.asset('images/add.png'),
                ),

                // Camera Picker
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.width * .3, mq.height * .15),
                  ),
                  onPressed: () async {
                    if (kIsWeb) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Camera not supported on web.'),
                          ),
                        );
                      }
                    } else {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (image != null) {
                        final file = File(image.path);
                        final imageUrl = await APIs.uploadImageToCloudinary(file);
                        if (imageUrl != null) {
                          await APIs.updateProfileImage(imageUrl);
                          setState(() => _image = imageUrl);
                        }
                      }
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: Image.asset('images/camera1.png'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
