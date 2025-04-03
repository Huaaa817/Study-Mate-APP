import 'package:cloud_functions/cloud_functions.dart';

// TODO: calling your customRecipeFlow
/* Hints:
  You can check how food_page.dart calling customRecipesFlow.
  Note that the type of return value is crucial.
*/
Future<Map<String, dynamic>> fetchCustomRecipe(
  String title,
  String ingredients,
  String directions,
  String userIngredients, //check its name
) async {
  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'customRecipe',
    );

    final response = await callable.call({
      "suggestRecipe": {
        "title": title,
        "ingredients": ingredients,
        "directions": directions,
      },
      "ingredients":
          userIngredients, // check if this caller's argument is right
    });

    final data = Map<String, dynamic>.from(response.data as Map);
    //final customRecipe = Map<String, dynamic>.from(data["customRecipe"]);

    //return customRecipe;

    return {
      "recipe": Map<String, dynamic>.from(data["recipe"]), // 修正 key 名稱
      "customRecipeImage": data["customRecipeImage"], // 取得修改後食譜的圖片
      "originRecipeImage": data["originRecipeImage"], // 取得原始食譜的圖片
    };
  } catch (e) {
    print("Error calling custom recipe: $e");
    throw Exception("Failed to fetch custom recipe");
  }
}
