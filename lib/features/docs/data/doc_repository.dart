import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/document.dart';
import 'doc_api_service.dart';

final Provider<DocRepository> docRepositoryProvider =
    Provider<DocRepository>((ref) {
  return DocRepository(ref.watch(docApiServiceProvider));
});

class DocRepository {
  const DocRepository(this._apiService);

  final DocApiService _apiService;

  Future<List<Document>> getDocuments() {
    return _apiService.getDocuments();
  }

  Future<Document> uploadDocument({
    required String filePath,
    required String fileName,
  }) {
    return _apiService.uploadDocument(
      filePath: filePath,
      fileName: fileName,
    );
  }

  Future<void> deleteDocument(String id) {
    return _apiService.deleteDocument(id: id);
  }
}
