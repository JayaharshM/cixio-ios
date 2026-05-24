import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/document.dart';
import '../../../core/network/api_client.dart';

final Provider<DocApiService> docApiServiceProvider =
    Provider<DocApiService>((ref) {
  return DocApiService(ref.watch(apiClientProvider));
});

class DocApiService {
  const DocApiService(this._dio);

  final Dio _dio;

  Future<List<Document>> getDocuments() async {
    final Response<Object?> response = await _dio.get<Object?>('/documents');

    final Object? data = response.data;
    final List<dynamic> documents = data is List<dynamic>
        ? data
        : _asMap(data)['documents'] as List<dynamic>? ?? <dynamic>[];

    return documents.map((doc) => Document.fromJson(_asMap(doc))).toList();
  }

  Future<Document> uploadDocument({
    required String filePath,
    required String fileName,
  }) async {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final Response<Object?> response = await _dio.post<Object?>(
      '/documents/upload',
      data: formData,
    );

    return Document.fromJson(_asMap(response.data));
  }

  Future<void> deleteDocument({
    required String id,
  }) async {
    await _dio.delete<void>('/documents/$id');
  }

  Map<String, dynamic> _asMap(Object? data) {
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }
}
