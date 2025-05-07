import 'package:cloud_functions/cloud_functions.dart';

// 用來發送請求並獲取聊天回應
Future<String> fetchChattingResponse(String userPersonality, String userMessage, List<String> conversationHistory) async {
  try {
    // 呼叫 Firebase Functions
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('generateChatting');
    
    // 傳送使用者的個性、訊息和對話歷史給 Firebase Functions
    final response = await callable.call({
      'personality': userPersonality,  // 使用者個性
      'message': userMessage,          // 使用者輸入的訊息
      'conversationHistory': conversationHistory,  // 傳遞對話歷史
    });

    // 確保回應有資料並返回 AI 回應
    final data = Map<String, dynamic>.from(response.data);
    return data['response'] ?? 'Error: No response from AI';
  } catch (e) {
    print('Error calling chat function: $e');
    return 'Error: Something went wrong with the chat.';
  }
}
