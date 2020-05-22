import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;
  final String username;

  User(
      {this.id,
      this.displayName,
      this.email,
      this.photoUrl,
      this.bio,
      this.username});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc['id'],
        email: doc['email'],
        photoUrl: doc['photoUrl'],
        username: doc['username'],
        displayName: doc['displayName'],
        bio: doc['bio']);
  }
}
