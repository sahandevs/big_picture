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
  List<Item> parents = [];

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

class RelationPosition {
  final Offset fromPosition;
  final Size fromSize;
  final Offset toPosition;
  final Size toSize;

  RelationPosition({
    this.fromPosition,
    this.fromSize,
    this.toPosition,
    this.toSize,
  });

  @override
  String toString() {
    return 'RelationPosition{fromPosition: $fromPosition, fromSize: $fromSize, toPosition: $toPosition, toSize: $toSize}';
  }
}

class _MyHomePageState extends State<MyHomePage> {
  bool isHovering = false;
  bool isHoldingControl = false;
  Offset _translate = Offset.zero;

  List<Item> onBoardItems = [];
  List<Item> idleItems = Item.generate();

  ValueNotifier<Item> selectedItem = ValueNotifier(null);

  initState() {
    super.initState();
    addItemToBoard(idleItems.first);
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
          ..._relationPositions
              .map((relation) => buildPointer(relation))
              .toList(),
          ...onBoardItems
              .map((x) => BPItem(
                    child: buildItem(x),
                    item: x,
                    onPositionChanged: () => updatePaths(),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget buildPointer(RelationPosition relation) {
    StartingPoint startingPoint;
    final isAreaTop = relation.fromPosition.dy + relation.fromSize.height <
        relation.toPosition.dy;
    final isAreaRight = relation.fromPosition.dx + (relation.fromSize.width / 2) >
        relation.toPosition.dy;
    if (isAreaRight) {
      if (isAreaTop) {
        startingPoint = StartingPoint.TopRight;
      } else {
        startingPoint = StartingPoint.BottomRight;
      }
    } else {
      if (isAreaTop) {
        startingPoint = StartingPoint.TopLeft;
      } else {
        startingPoint = StartingPoint.BottomLeft;
      }
    }

    final _width = (relation.toPosition.dx - relation.fromPosition.dx).abs();
    final _height = (relation.toPosition.dy -
            relation.fromPosition.dy -
            relation.toSize.height)
        .abs();

    return Positioned(
      top: (relation.fromPosition.dy + relation.fromSize.height) -
          (isAreaTop ? 0 : _height),
      left: (relation.fromPosition.dx + relation.fromSize.width / 2) -
          (isAreaRight ? _width * 2 : _width),
      height: _height,
      width: _width,
      child: true ? Text(startingPoint.toString()) : Container(
        color: Colors.red,
        child: CustomPaint(
          painter: ArrowPainter(startingPoint),
        )
      ),
    );
  }

  List<RelationPosition> _relationPositions = [];

  updatePaths() {
    const Size _itemSize = Size(350, 130);
    _relationPositions = onBoardItems
        .map((item) {
          return item.parents
              .map((parent) => RelationPosition(
                  fromPosition: parent.position,
                  fromSize: _itemSize,
                  toSize: _itemSize,
                  toPosition: item.position))
              .toList();
        })
        .expand((i) => i)
        .toList();
    setState(() {});
  }

  Widget buildItem(Item item) {
    return GestureDetector(
      onTap: () {
        if (selectedItem.value == item) {
          selectedItem.value = null;
        } else if (selectedItem.value == null) {
          selectedItem.value = item;
        } else {
          if (!item.parents.contains(selectedItem.value)) {
            if (!selectedItem.value.parents.contains(item)) {
              item.parents.add(selectedItem.value);
              selectedItem.value = null;
              updatePaths();
            }
          } else {
            item.parents.remove(selectedItem.value);
            selectedItem.value = null;
            updatePaths();
          }
        }
      },
      child: SizedBox(
        width: 350,
        height: 130,
        child: ValueListenableBuilder(
          valueListenable: selectedItem,
          builder: (c, _selectedItem, _) => Card(
            color: _selectedItem == item ? Colors.grey[100] : Colors.white,
            child: Text(
                "${item.title}\nparent : ${item.parents.map((x) => x.title).join(", ")}"),
          ),
        ),
      ),
    );
  }
}

enum StartingPoint {
  TopRight,
  TopLeft,
  BottomRight,
  BottomLeft,
}

class ArrowPainter extends CustomPainter {
  final StartingPoint startingPoint;

  ArrowPainter(this.startingPoint);

  Offset calculateStart(Size size) {
    switch (startingPoint) {
      case StartingPoint.TopRight:
        return Offset(size.width, 0);
      case StartingPoint.TopLeft:
        return Offset(0, 0);
      case StartingPoint.BottomRight:
        return Offset(size.width, size.height);
      case StartingPoint.BottomLeft:
        return Offset(0, size.height);
    }
    return null;
  }

  Offset calculateEnd(Size size) {
    switch (startingPoint) {
      case StartingPoint.BottomLeft:
        return Offset(size.width, 0);
      case StartingPoint.BottomRight:
        return Offset(0, 0);
      case StartingPoint.TopLeft:
        return Offset(size.width, size.height);
      case StartingPoint.TopRight:
        return Offset(0, size.height);
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
//    final bg = Paint()
//      ..color = Colors.red
//      ..style = PaintingStyle.stroke
//      ..strokeWidth = 1;
//    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final _start = calculateStart(size);
    final _end = calculateEnd(size);
    final center = Offset(
        (_start.dx - _end.dx).abs() / 2, (_start.dy - _end.dy).abs() / 2);

    final _paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final _path = Path();
    _path.moveTo(_start.dx, _start.dy);
//    _path.quadraticBezierTo(
//        center.dx + 150, center.dy - 50, center.dx, center.dy);
//    _path.quadraticBezierTo(center.dx - 150, center.dy + 50, 0, size.height);
    _path.lineTo(_end.dx, _end.dy);
    canvas.drawPath(_path, _paint);

    final _arrowHeadPath = Path();
    _arrowHeadPath.moveTo(-5, _end.dy - 5);
    _arrowHeadPath.lineTo(0, _end.dy);
    _arrowHeadPath.lineTo(5, _end.dy - 5);
    canvas.drawPath(_arrowHeadPath, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class BPItem extends StatefulWidget {
  final Widget child;
  final Item item;
  final VoidCallback onPositionChanged;

  const BPItem({Key key, this.item, this.child, this.onPositionChanged})
      : super(key: key);

  @override
  _BPItemState createState() => _BPItemState();
}

class _BPItemState extends State<BPItem> {
  ValueNotifier<bool> isHovering = ValueNotifier(false);
  ValueNotifier<bool> isHoveringOverDragIcon = ValueNotifier(false);

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
                      widget.item.position += d.delta;
                    });
                    widget.onPositionChanged();
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
      left: widget.item.position.dx,
      top: widget.item.position.dy,
    );
  }
}
