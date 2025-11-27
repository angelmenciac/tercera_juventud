import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityVideo {
  final String id;
  final String categoryId;
  final String activityId;
  final String storagePath;
  final String downloadUrl;
  final String uploaderId;
  final String? title;
  final String? description;
  final Timestamp createdAt;

  ActivityVideo({
    required this.id,
    required this.categoryId,
    required this.activityId,
    required this.storagePath,
    required this.downloadUrl,
    required this.uploaderId,
    this.title,
    this.description,
    required this.createdAt,
  });

  factory ActivityVideo.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityVideo(
      id: doc.id,
      categoryId: data['categoryId'],
      activityId: data['activityId'],
      storagePath: data['storagePath'],
      downloadUrl: data['downloadUrl'],
      uploaderId: data['uploaderId'],
      title: data['title'],
      description: data['description'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'activityId': activityId,
      'storagePath': storagePath,
      'downloadUrl': downloadUrl,
      'uploaderId': uploaderId,
      'title': title,
      'description': description,
      'createdAt': createdAt,
    };
  }
}