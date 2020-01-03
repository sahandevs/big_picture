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
        primarySwatch: Colors.blue,
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
    return BPItem(
      child: child,
      position: Offset(x, y),
    );
  }
}

class BPItem extends StatefulWidget {
  final Widget child;
  final Offset position;

  const BPItem({Key key, this.position, this.child}) : super(key: key);

  @override
  _BPItemState createState() => _BPItemState();
}

class _BPItemState extends State<BPItem> {
  ValueNotifier<bool> isHovering = ValueNotifier(false);
  ValueNotifier<bool> isHoveringOverDragIcon = ValueNotifier(false);
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: MouseRegion(
        onEnter: (_) => isHovering.value = true,
        onExit: (_) => isHovering.value = false,
        child: Stack(
          fit: StackFit.loose,
          children: <Widget>[
            widget.child,
            Positioned(
              right: 10,
              top: 10,
              child: MouseRegion(
                onEnter: (_) => isHoveringOverDragIcon.value = true,
                onExit: (_) => isHoveringOverDragIcon.value = false,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (d) {
                    print("test");

                    setState(() {
                      _offset += d.delta;
                    });
                  },
                  child: ValueListenableBuilder(
                    valueListenable: isHovering,
                    builder: (c, isHovering, _) => AnimatedOpacity(
                      duration: Duration(milliseconds: 100),
                      opacity: isHovering ? 0.8 : 0.0,
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      left: widget.position.dx + _offset.dx,
      top: widget.position.dy + _offset.dy,
    );
  }
}
