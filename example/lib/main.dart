import 'package:example/exitem.dart';
import 'package:flutter/material.dart';
import 'exbar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  String _text = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text(
          _text,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: ExBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          print(index.toString());
          setState(() {
            _currentIndex = index;
            _text = index.toString();
          });
        },
        items: [Icons.label, Icons.info, Icons.extension].map((x) {
          return ExBarItem(
            icon: Icon(x),
            label: x.fontFamily,
            extensionItems: [Icons.arrow_right, Icons.close].map((xx) => ExtensionItem(Icon(xx), () => setState(() => xx.toString()))).toList(),
            onSelectedTap: () => setState(() => _text = x.toString()),
          );
        }).toList(),
      ),
    );
  }
}
