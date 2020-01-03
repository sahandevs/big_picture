import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isHovering = false;
  bool isHoldingControl = false;
  Offset _translate = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned(
              left: _translate.dx,
              top: _translate.dy,
              child: Focus(
                onKey: (_, k) {
                  final RawKeyEventDataAndroid _data = k.data;
                  if (_data.keyCode == 17) {
                    setState(() {
                      if (k is RawKeyUpEvent) {
                        isHoldingControl = false;
                      } else {
                        isHoldingControl = true;
                      }
                    });
                  }
                  return false;
                },
                autofocus: true,
                canRequestFocus: true,
                onFocusChange: (isFocused) => print("is focused $isFocused"),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (d) {
                    if (isHoldingControl) {
                      setState(() {
                        _translate += d.delta;
                      });
                    }
                  },
                  child: buildContent(),
                ),
              ),
            )
          ],
        ));
  }

  Widget buildContent() {
    return SizedBox(
      width: 3000,
      height: 3000,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Placeholder(),
          builtBPItem(buildItem(), x: 100, y: 100)
        ],
      ),
    );
  }

  Widget buildItem() {
    return SizedBox(
      width: 350,
      height: 130,
      child: Card(),
    );
  }

  Widget builtBPItem(Widget child, {double x, double y}) {
    return Positioned(
      child: child,
      left: x,
      top: y,
    );
  }
}
