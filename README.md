# multi_pull

"multi pull" is an extension of RefreshIndicator!

I'd love it if you gave me a star!🌟

## No words are needed at first. Just look at it.

<img width=250 src="https://user-images.githubusercontent.com/61507019/119260538-32a26680-bc0e-11eb-94ac-7c341a00aa79.gif">


## What is MultiPull?

The RefreshIndicator is mainly used for scrolling and reloading, while MultiPull is an extension of the RefreshIndicator that allows users to select an action based on the widget that appears when they scroll. I have placed actions in the appBar, but I want users to be able to access them more easily. If you have an action in the appBar, but want to make it easier to access, you can place the same action in the MultiPull, and users will be able to reach it by just scrolling!

So long story short, let's see it in action!


## How to install

```pubspec.yml
dependencies:
  multi_pull: 0.1
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
        child: ListView(
          physics: BouncingScrollPhysics(),
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
            ...List.generate(100, (index) => Text(index.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
```

The difference between action and onRefresh is simple: if you want to do asynchronous processing, just use onRefresh. The difference between action and onRefresh is simple: if you want to do asynchronous processing, just use onRefresh. no, technically, action can also do asynchronous processing, but onRefresh displays a RefreshIndicator to indicate that it is doing asynchronous processing.
