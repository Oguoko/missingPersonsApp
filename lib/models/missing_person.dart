import 'package:cloud_firestore/cloud_firestore.dart';

class MissingPerson {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String physicalDescription;
  final String lastSeenLocation;
  final List<String> photos;
  final String status;
  final String submittedBy;
  final DateTime createdAt;

  MissingPerson({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.physicalDescription,
    required this.lastSeenLocation,
    required this.photos,
    required this.status,
    required this.submittedBy,
    required this.createdAt,
  });

  factory MissingPerson.fromMap(String documentId, Map<String, dynamic> data) {
    return MissingPerson(
      id: documentId,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      physicalDescription: data['physical_description'] ?? '',
      lastSeenLocation: data['last_seen_location'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      status: data['status'] ?? 'missing',
      submittedBy: data['submitted_by'] ?? 'anonymous',
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'physical_description': physicalDescription,
      'last_seen_location': lastSeenLocation,
      'photos': photos,
      'status': status,
      'submitted_by': submittedBy,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
