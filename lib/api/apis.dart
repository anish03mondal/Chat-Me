import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:chat_me/models/chat_user.dart';
import 'package:chat_me/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:math' as math;
import 'dart:developer' as dev;

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

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me?.pushToken = t;
        dev.log('Push Token: $t');
      }
    });
  }

  // 🔍 Check if user exists
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for adding a chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      // user exists
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({}); // Added set() to actually create the document

      return true;
    } else {
      // user doesn't exist
      return false;
    }
  }

  // 📥 Get self info
  static Future<void> getSelfInfo() async {
    final userSnapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .get();
    if (userSnapshot.exists) {
      me = ChatUser.fromJson(userSnapshot.data()!);
      await getFirebaseMessagingToken();
      // for setting user status to active
      APIs.updateActiveStatus(true);
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

  //for getting ids of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // 📡 Stream of all users except self
   static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    //log('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for adding a user to my users when first message is sent
static Future<void> sendFirstMessage(
    ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}) // Create an empty document or add fields as needed
        .then((value) => sendMessage(chatUser, msg, type));
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

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
    ChatUser chatUser,
  ) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots(); // Fixed case: snapShots → snapshots
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    await firestore.collection('users').doc(user.uid).update({
      // Fixed square brackets to curly braces
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_toke': me?.pushToken,
    }); // Fixed extra parenthesis
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
  static Future<void> sendMessage(
    ChatUser chatUser,
    String msg,
    Type type,
  ) async {
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
    dynamic fileOrBytes, { // File (mobile) or Uint8List (web)
    String? fileName, // required for web
  }) async {
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
