import 'dart:convert';
import 'dart:io';
import 'package:chat_me/models/chat_user.dart';
import 'package:chat_me/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class APIs {
  // Firebase auth & firestore
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Current user instance
  static User get user => auth.currentUser!;
  static ChatUser? me;
  static String? profilePhotoUrl;

  // Cloudinary config
  static const String cloudName = 'dlqncdnx9';
  static const String uploadPreset = 'flutter_unsigned';

  // 🔍 Check if user exists
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // 📥 Get self info
  static Future<void> getSelfInfo() async {
    final userSnapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .get();
    if (userSnapshot.exists) {
      me = ChatUser.fromJson(userSnapshot.data()!);
    } else {
      await createUser();
      await getSelfInfo();
    }
  }

  // 🧾 Create a new user in Firestore
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      about: "Hey I am using We Chat!",
      createdAt: time,
      email: user.email.toString(),
      id: user.uid,
      image: profilePhotoUrl ?? user.photoURL.toString(),
      isOnline: false,
      lastActive: time,
      name: user.displayName.toString(),
      pushToken: '',
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // 📡 Stream of all users except self
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // ✏️ Update basic user info (name, about)
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me?.name ?? '',
      'about': me?.about ?? '',
    });
  }

  // 🖼️ Upload image (Mobile) to Cloudinary
  static Future<String?> uploadImageToCloudinary(File file) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonResponse['secure_url'];
      } else {
        print('Cloudinary upload failed: $jsonResponse');
        return null;
      }
    } catch (e) {
      print('Error uploading (Mobile): $e');
      return null;
    }
  }

  // 🌐 Upload image (Web) to Cloudinary
  static Future<String?> uploadWebImageToCloudinary(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: fileName),
        );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonResponse['secure_url'];
      } else {
        print('Cloudinary upload failed (Web): $jsonResponse');
        return null;
      }
    } catch (e) {
      print('Error uploading (Web): $e');
      return null;
    }
  }

  // ✅ Update profile image in Firestore
  static Future<void> updateProfileImage(String imageUrl) async {
    await firestore.collection('users').doc(user.uid).update({
      'image': imageUrl,
    });

    // Also update local cache
    if (me != null) me!.image = imageUrl;
  }

  // Chat screen Relaed API **********************

  //useful for getting conversation id
  static String getConversationID(String id) {
    final ids = [user.uid, id];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  //for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
    ChatUser user,
  ) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
      toId: chatUser.id,
      msg: msg,
      read: '',
      type: type,
      fromId: user.uid,
      sent: time,
    );

    final ref = firestore.collection(
      'chats/${getConversationID(chatUser.id)}/messages/',
    );
    await ref.doc(time).set(message.toJson());
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent) // Assuming 'sent' contains the message ID
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
    ChatUser user,
  ) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // send chat image
  static Future<void> sendChatImage(
  ChatUser chatUser,
  dynamic fileOrBytes, // File (mobile) or Uint8List (web)
  {String? fileName}    // required for web
) async {
  try {
    String? imageUrl;

    if (kIsWeb) {
      // Web: fileOrBytes is Uint8List, fileName is required
      if (fileOrBytes is Uint8List && fileName != null) {
        imageUrl = await uploadWebImageToCloudinary(fileOrBytes, fileName);
      } else {
        print('❌ Invalid data for web image upload');
        return;
      }
    } else {
      // Mobile: fileOrBytes is File
      if (fileOrBytes is File) {
        imageUrl = await uploadImageToCloudinary(fileOrBytes);
      } else {
        print('❌ Invalid file for mobile image upload');
        return;
      }
    }

    if (imageUrl != null) {
      await sendMessage(chatUser, imageUrl, Type.image);
    } else {
      print('❌ Image upload failed');
    }
  } catch (e) {
    print('❌ Error sending chat image: $e');
  }
}
}
