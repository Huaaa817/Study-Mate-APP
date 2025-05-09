import 'package:cloud_functions/cloud_functions.dart';

// 調用 Firebase Function 來獲取動漫背景圖像
Future<String> fetchBackground({required String description}) async {
  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'generateBackground',
    );

    final response = await callable.call({'description': description});

    final data = Map<String, dynamic>.from(response.data as Map);
    return data['imageUrl'] ?? ''; // 返回生成的圖片 URL
  } catch (e) {
    print("Error calling generateBackground function: $e");
    return ''; // 返回空字符串，表示無背景圖片
  }
}
