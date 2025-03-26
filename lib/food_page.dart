import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'widgets/styled_text.dart';
import 'widgets/styled_frame.dart';
import 'services/fetch_custom_recipe.dart';

class FoodPage extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  final Function(Map<String, dynamic>) onUpdate;

  FoodPage({required this.recipeData, required this.onUpdate});

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final TextEditingController _controller = TextEditingController();
  late Map<String, dynamic> updatedRecipe;
  String? originImageUrl;
  String? generatedImageUrl;
  bool isLoading = false;
  bool hasGenerated = false;

  @override
  void initState() {
    super.initState();
    updatedRecipe = Map<String, dynamic>.from(widget.recipeData);
  }

  void generateUpdatedRecipe() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });
    // check this format
    try {
      final newRecipe = await fetchCustomRecipe(
        updatedRecipe["title"],
        updatedRecipe["ingredients"],
        updatedRecipe["directions"],
        _controller.text,
      );
      setState(() {
        updatedRecipe = newRecipe["recipe"];
        originImageUrl = newRecipe["originRecipeImage"]["url"];
        generatedImageUrl = newRecipe["customRecipeImage"]["url"];
        hasGenerated = true;
      });
    } catch (e) {
      print("Error generating updated recipe: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  void confirmUpdate() {
    widget.onUpdate(updatedRecipe);
    Navigator.pop(context);
  }

  Widget buildRecipeFieldSection({
    required String label,
    required String oldValue,
    required String updatedValue,
  }) {
    if (!hasGenerated) {
      return StyledFrame(
        label: label,
        content: oldValue,
        backgroundColor: Colors.blue.shade100,
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StyledFrame(
            label: "$label (Old)",
            content: oldValue,
            backgroundColor: Colors.red.shade100,
          ),
          SizedBox(height: 5),
          StyledFrame(
            label: "$label (Updated)",
            content: updatedValue,
            backgroundColor: Colors.green.shade100,
          ),
        ],
      );
    }
  }

  Widget buildImageSection(String label, String? imageUrl) {
    if (imageUrl == null) return SizedBox.shrink();

    Widget imageWidget;

    if (imageUrl.startsWith('data:image')) {
      final base64Data = imageUrl.split(',').last;
      final Uint8List bytes = base64Decode(base64Data);
      imageWidget = Image.memory(bytes, fit: BoxFit.contain);
    } else {
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(Icons.broken_image, size: 50, color: Colors.red),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StyledText(label, color: Colors.black87, fontSize: 22),
        SizedBox(height: 10),
        SizedBox(width: double.infinity, child: imageWidget),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StyledText('Recipe Details', color: Colors.brown, fontSize: 26),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildRecipeFieldSection(
                label: "Title",
                oldValue: widget.recipeData["title"],
                updatedValue: updatedRecipe["title"],
              ),
              SizedBox(height: 10),
              buildRecipeFieldSection(
                label: "Ingredients",
                oldValue: widget.recipeData["ingredients"],
                updatedValue: updatedRecipe["ingredients"],
              ),
              SizedBox(height: 10),
              buildRecipeFieldSection(
                label: "Directions",
                oldValue: widget.recipeData["directions"],
                updatedValue: updatedRecipe["directions"],
              ),
              SizedBox(height: 20),

              if (originImageUrl != null)
                buildImageSection("Origin Image:", originImageUrl),
              if (generatedImageUrl != null)
                buildImageSection("Generated Image:", generatedImageUrl),

              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Enter improvement suggestion',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon:
                        isLoading
                            ? CircularProgressIndicator()
                            : Icon(Icons.send, color: Colors.deepPurpleAccent),
                    onPressed: generateUpdatedRecipe,
                  ),
                ),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: isLoading ? null : confirmUpdate,
                child: StyledText(
                  'Confirm Update',
                  color: Colors.deepPurpleAccent,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
