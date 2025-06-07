import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: ColorPickerPage());
}

class ColorPickerPage extends StatefulWidget {
  @override
  _ColorPickerPageState createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  Color currentColor = Colors.blue;

  void changeColor(Color color) {
    setState(() => currentColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('色彩選擇器')),
      body: Center(
        child: ElevatedButton(
          onPressed:
              () => showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: Text('選擇顏色'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: currentColor,
                          onColorChanged: changeColor,
                          enableAlpha: false,
                          showLabel: true,
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text('確認'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
              ),
          child: Text('目前顏色'),
          style: ElevatedButton.styleFrom(
            backgroundColor: currentColor,
            foregroundColor:
                useWhiteForeground(currentColor) ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
