import 'package:flutter_app/repositories/user_id.dart';
import 'package:flutter/material.dart';

class UserIdInputViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  UserIdInputViewModel({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository();

  bool _loading = false;
  String? _error;
  String? _currentUserId;

  String? personality;
  String? hairLength;
  String? skinColor;
  bool hasCompletedProfile = false;

  String? userImageUrl; // ✅ 圖片下載連結 (替代 base64)

  bool get loading => _loading;
  String? get error => _error;
  String? get currentUserId => _currentUserId;

  void setCurrentUserId(String id) {
    _currentUserId = id;
    notifyListeners();
  }

  void setUserProfile({
    required String personality,
    required String hairLength,
    required String skinColor,
  }) {
    this.personality = personality;
    this.hairLength = hairLength;
    this.skinColor = skinColor;
    hasCompletedProfile = true;
    notifyListeners();
  }

  Future<bool?> submitUserId(String userId) async {
    if (userId.isEmpty) {
      _error = 'User ID cannot be empty';
      notifyListeners();
      return null;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      bool isNewUser = await _userRepository.checkAndCreateUserIfNotExists(
        userId,
      );
      _currentUserId = userId;
      return isNewUser;
    } catch (e) {
      _error = 'Error: $e';
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// ✅ 儲存 base64 圖片到 Storage，Firestore 存 downloadUrl
  Future<void> saveUserImage(String base64Image) async {
    if (_currentUserId == null) return;
    await _userRepository.saveUserImage(_currentUserId!, base64Image);
    await loadUserImage(); // 儲存後順便重新抓取 URL
  }

  /// ✅ 從 Firestore 載入圖片 URL
  Future<void> loadUserImage() async {
    if (_currentUserId == null) return;
    userImageUrl = await _userRepository.getUserImage(_currentUserId!);
    notifyListeners();
  }

  /// ✅ 更新使用者個人資料到 Firestore
  Future<void> updateUserProfile({
    required String personality,
    required String hairLength,
    required String skinColor,
  }) async {
    if (_currentUserId == null) return;
    await _userRepository.updateUserProfile(
      userId: _currentUserId!,
      personality: personality,
      hairLength: hairLength,
      skinColor: skinColor,
    );
  }
}
