import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/repositories/user_repo.dart';

class MeViewModel with ChangeNotifier {
  final UserRepository _userRepository;
  late StreamSubscription<User?> _meSubscription;

  final StreamController<User> _meStreamController = StreamController<User>();
  Stream<User> get meStream => _meStreamController.stream;

  late String _myId;
  String get myId => _myId;
  User? _me;
  User? get me => _me;

  bool _lastIsModerator = false;
  bool _isModeratorStatusChanged = false;
  bool get isModeratorStatusChanged => _isModeratorStatusChanged;

  String? userImageUrl;

  MeViewModel(String userId, {UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository() {
    _myId = userId;
    _meSubscription = _userRepository.streamUser(userId).listen((me) {
      if (me == null) {
        return;
      }

      _meStreamController.add(me);

      if (_me == null) {
        _lastIsModerator = me.isModerator;
      } else {
        _isModeratorStatusChanged = _lastIsModerator != me.isModerator;
        _lastIsModerator = me.isModerator;
      }
      _me = me;

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _meSubscription.cancel();
    _meStreamController.close();
    super.dispose();
  }

  Future<void> addMe(User me) async {
    await _userRepository.createOrUpdateUser(me);
  }

  /// 儲存 base64 圖片到 Storage，並更新 Firestore 的下載 URL
  Future<void> saveUserImage(String base64Image) async {
    if (_myId.isEmpty) return;
    await _userRepository.saveUserImage(_myId, base64Image);
    await loadUserImage(); // 儲存後重新取得 URL
  }

  /// 從 Firestore 載入圖片 URL
  Future<void> loadUserImage() async {
    if (_myId.isEmpty) return;
    userImageUrl = await _userRepository.getUserImage(_myId);
    notifyListeners();
  }
}
