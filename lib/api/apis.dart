import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs {
  static FirebaseAuth auth =
      FirebaseAuth.instance; // crating instace of FirebaseAuth in auth variable
  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;  // creating instance of FirebaseFirestore in firestore variable
}
