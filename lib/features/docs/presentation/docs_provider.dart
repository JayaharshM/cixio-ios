import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/document.dart';
import '../data/doc_repository.dart';

final AsyncNotifierProvider<DocsNotifier, List<Document>>
    docsProvider =
    AsyncNotifierProvider<DocsNotifier, List<Document>>(
        DocsNotifier.new);

class DocsNotifier extends AsyncNotifier<List<Document>> {
  @override
  Future<List<Document>> build() async {
    return ref.watch(docRepositoryProvider).getDocuments();
  }

  Future<void> uploadDocument(String filePath, String fileName) async {
    final List<Document> currentDocs = state.value ?? <Document>[];
    try {
      final Document newDoc = await ref
          .read(docRepositoryProvider)
          .uploadDocument(filePath: filePath, fileName: fileName);
      state = AsyncData(<Document>[...currentDocs, newDoc]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteDocument(String id) async {
    final List<Document> currentDocs = state.value ?? <Document>[];
    try {
      await ref.read(docRepositoryProvider).deleteDocument(id);
      state = AsyncData(<Document>[
        for (final doc in currentDocs)
          if (doc.id != id) doc
      ]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
