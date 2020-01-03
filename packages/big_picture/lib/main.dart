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
      debugShowCheckedModeBanner: false,
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

class Item {
  Item(this.title);

  Offset position = Offset.zero;
  String title;

  static List<Item> generate() {
    return [
      Item("Item #1"),
      Item("Item #2"),
      Item("Item #3"),
      Item("Item #4"),
      Item("Item #5"),
      Item("Item #6"),
      Item("Item #7"),
      Item("Item #8"),
      Item("Item #9"),
      Item("Item #10"),
    ];
  }
}

class _MyHomePageState extends State<MyHomePage> {
  bool isHovering = false;
  bool isHoldingControl = false;
  Offset _translate = Offset.zero;

  List<Item> onBoardItems = [];
  List<Item> idleItems = Item.generate();

  initState() {
    super.initState();
    addItemToBoard(idleItems.first);
  }

  addItemToBoard(Item target) {
    idleItems.remove(target);
    onBoardItems.add(target);
  }

  Widget buildDrawerItem(Item item) {
    return GestureDetector(
      onTap: () => setState(() => addItemToBoard(item)),
      child: Container(
        padding: EdgeInsets.all(5),
        width: double.infinity,
        height: 100,
        child: Card(
          child: Text(item.title),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        endDrawer: Drawer(
          child: ListView.builder(
            itemBuilder: (context, index) => buildDrawerItem(idleItems[index]),
            itemCount: idleItems.length,
          ),
        ),
        appBar: AppBar(
          actions: <Widget>[
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            )
          ],
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
          buildPointer(
            fromPosition: Offset(10, 50),
            fromSize: Size(350, 130),
            toPosition: Offset(300, 300),
            toSize: Size(350, 130),
          ),
          ...onBoardItems
              .map((x) => BPItem(child: buildItem(x), position: x.position))
              .toList(),
        ],
      ),
    );
  }

  Widget buildPointer(
      {Offset fromPosition, Size fromSize, Offset toPosition, Size toSize}) {
    return Positioned(
      top: fromPosition.dy + fromSize.height,
      left: fromPosition.dx + fromSize.width / 2,
      height: toPosition.dy - fromPosition.dy,
      width: toPosition.dx - fromPosition.dx,
      child: Container(
        child: CustomPaint(
          painter: ArrowPainter(),
        ),
      ),
    );
  }

  Widget buildItem(Item item) {
    return SizedBox(
      width: 350,
      height: 130,
      child: Card(
        child: Text(item.title),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final _paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);

    final _path = Path();
    _path.moveTo(size.width, 0);
    _path.quadraticBezierTo(
        center.dx + 150, center.dy - 50, center.dx, center.dy);
    _path.quadraticBezierTo(center.dx - 150, center.dy + 50, 0, size.height);
    canvas.drawPath(_path, _paint);

    final _arrowHeadPath = Path();
    _arrowHeadPath.moveTo(-5, size.height - 5);
    _arrowHeadPath.lineTo(0, size.height);
    _arrowHeadPath.lineTo(5, size.height - 5);
    canvas.drawPath(_arrowHeadPath, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
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
