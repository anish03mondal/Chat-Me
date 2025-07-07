import 'package:chat_me/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs {
  static FirebaseAuth auth =
      FirebaseAuth.instance; // crating instace of FirebaseAuth in auth variable
  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore
      .instance; // creating instance of FirebaseFirestore in firestore variable

  static User get user => auth.currentUser!;  //Gets the currently logged-in Firebase user.

  //for checking if user exists or not
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get())
        .exists; //will return true of false
  }

  //for crating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      about: "Hey I am using We Chat!",
      createdAt: time,
      email: user.email.toString(),
      id: user.uid,
      image: user.photoURL.toString(),
      isOnline: false,
      lastActive: time,
      name: user.displayName.toString(),
      pushToken: '',
    );

    return await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
  }
}
