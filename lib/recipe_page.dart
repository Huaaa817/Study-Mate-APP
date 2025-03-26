import 'package:flutter/material.dart';
import 'food_page.dart';
import 'widgets/styled_text.dart';
import 'services/fetch_recipes.dart';

class RecipeRecommendationPage extends StatefulWidget {
  @override
  _RecipeRecommendationPageState createState() =>
      _RecipeRecommendationPageState();
}

class _RecipeRecommendationPageState extends State<RecipeRecommendationPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _recipes = [];
  bool isLoading = false;

  void fetchRecipes(String prompt) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await retrieveRecipes(prompt);
      setState(() {
        _recipes = response;
      });
    } catch (e) {
      print("Error fetching recipes: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  void navigateToDetail(int index) {
    final recipe = _recipes[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FoodPage(
              recipeData: recipe,
              onUpdate: (updatedRecipe) {
                setState(() {
                  _recipes[index] = updatedRecipe;
                });
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StyledText(
          'Recipe Recommender',
          color: Colors.brown,
          fontSize: 26,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Input your ingredients',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon:
                      isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Icon(Icons.send, color: Colors.deepPurpleAccent),
                  onPressed: () => fetchRecipes(_controller.text),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child:
                  _recipes.isEmpty
                      ? Center(
                        child: StyledText(
                          'No recipes yet. Try typing something!',
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                      : ListView.builder(
                        itemCount: _recipes.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: StyledText(
                                _recipes[index]['title'] ?? 'Untitled',
                                color: Colors.black87,
                                fontSize: 22,
                              ),
                              subtitle: StyledText(
                                "Ingredients: ${_recipes[index]['ingredients']}",
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                              onTap: () => navigateToDetail(index),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
