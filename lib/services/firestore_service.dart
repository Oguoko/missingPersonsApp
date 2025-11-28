import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/missing_person.dart';
import '../models/comment.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add a new missing person entry
  Future<void> addMissingPerson(MissingPerson person) async {
    await _db.collection('missing_persons').doc(person.id).set(person.toMap());
  }

  /// Stream list of all missing persons
  Stream<List<MissingPerson>> getMissingPersons() {
    return _db.collection('missing_persons').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MissingPerson.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Unified image uploader for both Web and Mobile
  Future<String> uploadImageUnified({
    required String personId,
    File? file,
    Uint8List? bytes,
  }) async {
    final fileName =
        '${personId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final ref = _storage.ref().child("missing_photos/$fileName");

    // Web upload
    if (kIsWeb) {
      final uploadTask = await ref
          .putData(bytes!, SettableMetadata(contentType: 'image/jpeg'));
      return await uploadTask.ref.getDownloadURL();
    }

    // Mobile upload (Android / iOS)
    final uploadTask = await ref.putFile(file!);
    return await uploadTask.ref.getDownloadURL();
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

  /// Stream comments for a specific person
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

  /// Update the verification/status of a missing person
  Future<void> updatePersonStatus(String personId, String newStatus) async {
    await _db.collection('missing_persons').doc(personId).update({
      'status': newStatus,
    });
  }

  /// Get current authenticated Firebase user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Fetch one missing person by document ID
  Future<MissingPerson?> getMissingPerson(String id) async {
    final doc = await _db.collection('missing_persons').doc(id).get();

    if (!doc.exists) return null;

    return MissingPerson.fromMap(doc.id, doc.data()!);
  }
}
