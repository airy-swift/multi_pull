import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_pull/multi_pull.dart';

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
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('simple pull page'),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SimplePage(),
                  )),
            ),
            ElevatedButton(
              child: Text('label pull page'),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LabelPage(),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class SimplePage extends StatefulWidget {
  SimplePage({Key? key}) : super(key: key);

  @override
  SimplePageState createState() => SimplePageState();
}

class SimplePageState extends State<SimplePage> {
  SimplePageState();

  final _firstTextController = TextEditingController();
  final _secondTextController = TextEditingController();
  final _thirdTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstTextController.text = "Hello";
    _secondTextController.text = "multi pull actions";
    _thirdTextController.text = "airy-swift";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Page"),
      ),
      body: MultiPull(
        circleMoveDuration: Duration(milliseconds: 400),
        circleMoveCurve: Curves.easeInOut,
        pullIndicators: [
          DefaultPullIndicator(
            icon: Icon(Icons.arrow_back_ios_outlined),
            label: Text("back"),
            onPull: () => Navigator.pop(context),
          ),
          DefaultPullIndicator(
            icon: Icon(Icons.refresh_rounded),
            onPull: () async => await Future.delayed(Duration(seconds: 2)),
          ),
          DefaultPullIndicator(
            icon: Icon(Icons.backspace_outlined),
            label: Text("clear", style: TextStyle(color: Colors.redAccent)),
            onPull: () {
              _firstTextController.clear();
              _secondTextController.clear();
              _thirdTextController.clear();
            },
          ),
        ],
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            TextField(
              controller: _firstTextController,
            ),
            TextField(
              controller: _secondTextController,
            ),
            TextField(
              controller: _thirdTextController,
            ),
          ],
        ),
      ),
    );
  }
}

class LabelPage extends StatelessWidget {
  const LabelPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: MultiPull(
        circleMoveDuration: Duration(milliseconds: 400),
        circleMoveCurve: Curves.easeInOut,
        circleIndicator: ArrowIndicator(),
        pullIndicators: [
          LabelPullIndicator(
            label: "Back",
            onPull: () => Navigator.pop(context),
          ),
          LabelPullIndicator(
            label: "Refresh",
            onPull: () async => await Future.delayed(Duration(seconds: 2)),
          ),

        ],
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            Center(child: Text("label")),
          ],
        ),
      ),
    );
  }
}