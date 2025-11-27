
// lib/services/video_storage_service.dart
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class VideoStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Devuelve la URL del primer video encontrado en la carpeta:
  /// videos/{categoryId}/{topicId}/
  /// Si no hay archivos devuelve null.
  Future<String?> getFirstVideoDownloadUrl({
    required String categoryId,
    required String topicId,
  }) async {
    final path = 'videos/$categoryId/$topicId';
    final ref = _storage.ref().child(path);

    try {
      final ListResult listResult = await ref.listAll(); // lista objetos y subcarpetas
      if (listResult.items.isEmpty) {
        return null;
      }

      // Si quieres elegir el último subido por nombre/orden, ordénalos por name
      // final sorted = listResult.items..sort((a,b)=>a.name.compareTo(b.name));
      // final StorageReference chosen = sorted.last;

      final first = listResult.items.first;
      final url = await first.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      // Manejo básico de errores: carpeta inexistente o permisos
      if (kDebugMode) {
        print('FirebaseStorage error: ${e.code} ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unknown error listing storage: $e');
      }
      rethrow;
    }
  }

  /// Alternativa: listar todos y devolver lista de URLs
  Future<List<String>> listAllVideoUrls({required String categoryId, required String topicId}) async {
    final path = 'videos/$categoryId/$topicId';
    final ref = _storage.ref().child(path);
    final urls = <String>[];
    final result = await ref.listAll();
    for (final item in result.items) {
      final u = await item.getDownloadURL();
      urls.add(u);
    }
    return urls;
  }
}
