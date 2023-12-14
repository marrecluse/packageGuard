// profile_image_service.dart

class ProfileImageService {
  static String? _profileImageUrl;

  static void setProfileImageUrl(String? imageUrl) {
    _profileImageUrl = imageUrl;
  }

  static String? getProfileImageUrl() {
    return _profileImageUrl;
  }
}
