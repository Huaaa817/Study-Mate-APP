import 'package:cloud_functions/cloud_functions.dart';

Future<String> fetchGreeting(String personality, String userId) async {
  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'generateGreeting',
    );

    final response = await callable.call({
      'personality': personality,
      'userId': userId,
    });

    final data = Map<String, dynamic>.from(response.data as Map);
    return data['greeting'] ?? 'Error generating greeting';
  } catch (e) {
    print("Error calling greeting generation function: $e");
    return 'Error generating greeting';
  }
}
