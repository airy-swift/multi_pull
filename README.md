
![version:1.1.0](https://img.shields.io/badge/version-1.1.0-f53.svg)
![license:BSD3](https://img.shields.io/badge/license-BSD3-0d0.svg)

# multi_pull

"multi pull" is an extension of RefreshIndicator!

I'd love it if you gave me a star!🌟

## No words are needed at first. Just look at it.

<img width=250 src="https://user-images.githubusercontent.com/61507019/119260538-32a26680-bc0e-11eb-94ac-7c341a00aa79.gif">


### one of example customized multi_pull

<img width=250 src="https://user-images.githubusercontent.com/61507019/136678547-27f96ef3-c3b3-4872-90f9-a3a693b72701.png">


## What is MultiPull?

The RefreshIndicator is mainly used for scrolling and reloading, while MultiPull is an extension of the RefreshIndicator that allows users to select an action based on the widget that appears when they scroll. I have placed actions in the appBar, but I want users to be able to access them more easily. If you have an action in the appBar, but want to make it easier to access, you can place the same action in the MultiPull, and users will be able to reach it by just scrolling!

So long story short, let's see it in action!


## How to install

```pubspec.yml
dependencies:
  multi_pull: 1.1.0
```

## Getting Started

The usage of MultiPull is similar to RefreshIndicator. It works by having a Scrollable Widget like a ListView as a child. Then you place the widget in actionWidgets, wrapped in an ActionWidget that is displayed as a choice when pulled. Don't forget to set the action or onRefresh to what will happen when the choice is made.

```dart:main.dart
import 'package:multi_pull/multi_pull.dart';

~~~~
~~~~
    Scaffold(
      appBar: AppBar(
        title: Text("Second Page"),
      ),
      body: MultiPull(
        circleMoveDuration: Duration(milliseconds: 400),
        circleMoveCurve: Curves.easeInOut,
        circleIndicator: DefaultCircle(
          circleColor: Colors.grey,
          circleOpacity: 0.2,
        ),
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
```

The difference between action and onRefresh is simple: if you want to do asynchronous processing, just use onRefresh. The difference between action and onRefresh is simple: if you want to do asynchronous processing, just use onRefresh. no, technically, action can also do asynchronous processing, but onRefresh displays a RefreshIndicator to indicate that it is doing asynchronous processing.
