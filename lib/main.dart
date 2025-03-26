import 'package:flutter/material.dart';
import 'recipe_page.dart';
import 'widgets/styled_text.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<String> _imageUrls = [
    'assets/img/food1.jpg',
    'assets/img/food2.jpg',
    'assets/img/food3.jpg',
    'assets/img/food4.jpg',
  ];
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    Future.delayed(Duration(seconds: 8), () {
      if (mounted) {
        int nextIndex = (_currentIndex + 1) % _imageUrls.length;
        _pageController.animateToPage(
          nextIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentIndex = nextIndex;
        });
        _startAutoSlide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                /// **🔹 左側橘色區域**
                Expanded(
                  flex: 1,
                  child: Container(
                    width: constraints.maxWidth * 0.4, // **確保適應不同螢幕**
                    color: Colors.orange.shade300,
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.05,
                      vertical: constraints.maxHeight * 0.1,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StyledText(
                          "Welcome to Recipe Finder",
                          color: Colors.white,
                          fontSize: 32,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.02),
                        StyledText(
                          "Discover new recipes based on your preferences!",
                          color: Colors.white70,
                          fontSize: 20,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.05),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => RecipeRecommendationPage(),
                              ),
                            );
                          },
                          child: StyledText(
                            "Let's Start",
                            color: Colors.deepPurpleAccent,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// **🔹 右側可滑動圖片**
                Expanded(
                  flex: 1,
                  child: Container(
                    width: constraints.maxWidth * 0.6,
                    child: PageView.builder(
                      controller: _pageController,
                      physics: BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemCount: _imageUrls.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            _imageUrls[index],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
