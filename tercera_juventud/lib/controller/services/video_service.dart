import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tercera_juventud/models/video_model.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VideoService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Subir archivo y crear documento en 'videos'
  Future<void> uploadVideoForActivity({
    required File file,
    required String categoryId,
    required String activityId,
    required String uploaderId,
    String? title,
    String? description,
    void Function(double progress)? onProgress,
  }) async {
    final uid = Uuid().v4();
    final ext = file.path.split('.').last;
    final storagePath = 'videos/$categoryId/$activityId/$uid.$ext';

    final ref = _storage.ref().child(storagePath);
    final uploadTask = ref.putFile(file);

    uploadTask.snapshotEvents.listen((event) {
      final p = event.bytesTransferred / (event.totalBytes ?? 1);
      if (onProgress != null) onProgress(p);
    });

    final snapshot = await uploadTask.whenComplete(() => null);

    final downloadUrl = await snapshot.ref.getDownloadURL();

    final doc = {
      'categoryId': categoryId,
      'activityId': activityId,
      'storagePath': storagePath,
      'downloadUrl': downloadUrl,
      'uploaderId': uploaderId,
      'title': title ?? '',
      'description': description ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'visibility': 'public',
    };

    await _firestore.collection('videos').add(doc);
  }

  // Obtener último video (más reciente) para una actividad
  Future<ActivityVideo?> getLatestVideo(String categoryId, String activityId) async {
    final qs = await _firestore
        .collection('videos')
        .where('categoryId', isEqualTo: categoryId)
        .where('activityId', isEqualTo: activityId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (qs.docs.isEmpty) return null;
    return ActivityVideo.fromDoc(qs.docs.first);
  }

  // Stream si quieres que la UI reaccione en tiempo real
  Stream<ActivityVideo?> streamLatestVideo(String categoryId, String activityId) {
    return _firestore
        .collection('videos')
        .where('categoryId', isEqualTo: categoryId)
        .where('activityId', isEqualTo: activityId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : ActivityVideo.fromDoc(snap.docs.first));
  }
}