import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BackgroundViewModel extends ChangeNotifier {
  String? imageUrl;

  Future<void> fetchBackground(String userId, BuildContext context) async {
    final ref = FirebaseFirestore.instance
        .collection('apps/study_mate/users')
        .doc(userId)
        .collection('backgrounds')
        .orderBy('createdAt', descending: true)
        .limit(1);

    try {
      final snapshot = await ref.get();
      if (snapshot.docs.isNotEmpty && snapshot.docs.first['imageUrl'] != null) {
        imageUrl = snapshot.docs.first['imageUrl'];
        print('[LOG] 預取完成 ✅ imageUrl = $imageUrl');

        // ✅ 在取得 URL 後就立刻快取圖片（解碼並放入 flutter cache）
        await precacheImage(NetworkImage(imageUrl!), context);
        print('[LOG] 圖片快取完成 ✅');

        notifyListeners();
      }
    } catch (e) {
      print('預載背景失敗: $e');
    }
  }

  /// ✅ 提供背景 Widget（優先用 imageUrl，否則 fallback 回預設圖片）
  Widget get backgroundWidget {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      return Image.asset(
        'assets/img/default.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
  }
}
