import 'package:flutter_riverpod/flutter_riverpod.dart';

final StateProvider<int> selectedTabIndexProvider = StateProvider<int>((ref) {
  return 0;
});
