import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Login method
  Future<Map<String, dynamic>?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      log("Attempting to log in with email: $email");

      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = cred.user;

      if (user != null) {
        log("User Logged In: ${user.uid}");
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          log("User Info: ${userDoc.data().toString()}");
          return userDoc.data();
        } else {
          log("User document does not exist in Firestore.");
          return null;
        }
      } else {
        log("User credential is null after login.");
      }
    } catch (e) {
      log("Login failed: ${e.toString()}");
      // Additional handling can be done here for specific FirebaseAuthExceptions if needed
    }
    return null;
  }

  // Sign out method
  Future<void> signout() async {
    try {
      await _auth.signOut();
      log("User signed out successfully.");
    } catch (e) {
      log("Something went wrong during sign out: $e");
    }
  }

  // Fetch user data method
  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        log("User data fetched: ${userDoc.data().toString()}");
        return userDoc.data();
      } else {
        log("User document does not exist in Firestore.");
        return null;
      }
    } catch (e) {
      log("Error fetching user data: $e");
      return null;
    }
  }
}
