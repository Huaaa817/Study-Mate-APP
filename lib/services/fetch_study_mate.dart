import 'package:cloud_functions/cloud_functions.dart';
// TODO: calling your Flow
Future<Map<String, dynamic>> fetchStudyMateImage(
  String hairLength,
  String hairColor,
  String hairStyled,
  String decoration,
  String skinTone,
  String smileFeelings,
  String eyeFeeling,
  String personality1,
  String personality2,
  String userSuggestion,
) async {
  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      // 'customRecipe',
      'studyMateImage',
    );

    final response = await callable.call({
      'imageSetting': {
        'hairLength': hairLength,
        'hairColor': hairColor,
        'hairStyled': hairStyled,
        'decoration': decoration,
        'skinTone': skinTone,
        'smileFeelings': smileFeelings,
        'eyeFeeling': eyeFeeling,
        'personality1': personality1,
        'personality2': personality2,
      },
      'otherDescription': userSuggestion,
    });

    final Map<String, dynamic> data = Map<String, dynamic>.from(
      response.data as Map,
    );
    //final customRecipe = Map<String, dynamic>.from(data["customRecipe"]);

    //return customRecipe;
    return data;
  } catch (e) {
    print("Error calling studymate image: $e");
    throw Exception("Failed to fetch studymate image");
  }
}
