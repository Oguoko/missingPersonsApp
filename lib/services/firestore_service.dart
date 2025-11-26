import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/missing_person.dart';
import '../models/comment.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add a new missing person report
  Future<void> addMissingPerson(MissingPerson person) async {
    await _db.collection('missing_persons').doc(person.id).set(person.toMap());
  }

  /// Fetch all missing persons
  Stream<List<MissingPerson>> getMissingPersons() {
    return _db.collection('missing_persons').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MissingPerson.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Upload image and return its URL
  Future<String> uploadImage(File file, String personId) async {
    final ref = _storage.ref().child(
      'missing_photos/$personId/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  /// Add a comment to a missing person
  Future<void> addComment(String personId, Comment comment) async {
    await _db
        .collection('missing_persons')
        .doc(personId)
        .collection('comments')
        .doc(comment.id)
        .set(comment.toMap());
  }

  /// Fetch comments as a stream
  Stream<List<Comment>> getComments(String personId) {
    return _db
        .collection('missing_persons')
        .doc(personId)
        .collection('comments')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Comment.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  /// Update status field (useful when verified/unverified)
  Future<void> updatePersonStatus(String personId, String newStatus) async {
    await _db.collection('missing_persons').doc(personId).update({
      'status': newStatus,
    });
  }

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get a single missing person by ID
  Future<MissingPerson?> getMissingPerson(String id) async {
    final doc = await _db.collection('missing_persons').doc(id).get();

    if (!doc.exists) return null;

    return MissingPerson.fromMap(doc.id, doc.data()!);
  }
}
