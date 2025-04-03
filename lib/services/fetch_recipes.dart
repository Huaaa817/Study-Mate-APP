import 'package:cloud_functions/cloud_functions.dart';

// TODO: calling your retrieveRecipeFlow
/* Hints:
  You can check how recipe_page.dart calling retrieveRecipeFlow.
  Note that the type of return value is crucial.
*/
Future<List<Map<String, dynamic>>> retrieveRecipes(String ingredients) async {
  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'retrieveRecipe',
    );
    print("Hihi");
    final response = await callable.call(ingredients); //check this argument
    print("Hihi2");
    //final data = Map<String, dynamic>.from(response.data as Map);

    //final originRecipe = Map<String, dynamic>.from(data["originRecipe"]);
    //return [originRecipe];
    final List<dynamic> data = response.data as List<dynamic>;

    return data.map((recipe) => Map<String, dynamic>.from(recipe)).toList();
  } catch (e) {
    print("Error fetching retrieved recipes: $e");
    throw Exception("Failed to fetch recipes");
  }
}
