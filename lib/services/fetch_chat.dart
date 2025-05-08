import 'package:cloud_functions/cloud_functions.dart';

// 這是用來調用Firebase Function並獲取生成的打招呼語
Future<String> fetchGreeting(String personality) async {
  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'generateGreeting',
    );

    final response = await callable.call({'personality': personality});

    final data = Map<String, dynamic>.from(response.data as Map);
    return data['greeting'] ?? 'Error generating greeting';
  } catch (e) {
    print("Error calling greeting generation function: $e");
    return 'Error generating greeting';
  }
}
