import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

const String _profileImageKey = 'app_profile_image_path';

class ProfileImageNotifier extends StateNotifier<String?> {
  ProfileImageNotifier() : super(null) {
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? imagePath = prefs.getString(_profileImageKey);
    if (imagePath != null && imagePath.isNotEmpty) {
      state = imagePath;
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      state = image.path;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileImageKey, image.path);
    }
  }

  Future<void> deleteImage() async {
    state = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileImageKey);
  }
}

final StateNotifierProvider<ProfileImageNotifier, String?> profileImageProvider =
    StateNotifierProvider<ProfileImageNotifier, String?>((ref) {
  return ProfileImageNotifier();
});
