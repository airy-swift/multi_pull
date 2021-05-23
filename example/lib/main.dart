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
  MyHomePage({Key key, this.title}) : super(key: key);
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
        child: RaisedButton(
          child: Text('次へ'),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NextPage(),
                ));
          },
        ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  NextPage();

  final _firstTextController = TextEditingController();
  final _secondTextController = TextEditingController();
  final _thirdTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Page"),
      ),
      body: MultiPull(
        actionWidgets: [
          ActionWidget(
            icon: Icon(Icons.arrow_back_ios_outlined),
            label: "back",
            action: () => Navigator.pop(context),
          ),
          ActionWidget(
            icon: Icon(Icons.refresh_rounded),
            label: "reload",
            onRefresh: () async => await Future.delayed(Duration(seconds: 2)),
          ),
          ActionWidget(
            icon: Icon(Icons.backspace_outlined),
            label: "clear",
            action: () {
              _firstTextController.clear();
              _secondTextController.clear();
              _thirdTextController.clear();
            },
          ),
        ],
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: ListView(
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
        ),
      ),
    );
  }
}
