import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
          ),
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  const Dock({super.key, required this.items});

  final List<IconData> items;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> with SingleTickerProviderStateMixin {
  late List<IconData> _items;
  IconData? _draggingItem;
  int? _draggingIndex;
  late final AnimationController _controller;
  late final Animation<double> _hoverScale;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _hoverScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black12,
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_items.length, (index) {
            final icon = _items[index];

            return DragTarget<IconData>(
              onWillAccept: (data) => true,
              onAccept: (data) {
                setState(() {
                  _items.removeAt(_draggingIndex!);
                  _items.insert(index, data);
                  _draggingItem = null;
                  _draggingIndex = null;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(
                      horizontal: _draggingItem == null
                          ? 8
                          : (_draggingIndex == index ? 32 : 8)),
                  child: Draggable<IconData>(
                    data: icon,
                    feedback: DockButton(icon: icon, isDragging: true),
                    onDragStarted: () {
                      setState(() {
                        _draggingItem = icon;
                        _draggingIndex = index;
                      });
                    },
                    onDragEnd: (_) {
                      setState(() {
                        _draggingItem = null;
                        _draggingIndex = null;
                      });
                    },
                    childWhenDragging: const SizedBox.shrink(),
                    child: ScaleTransition(
                      scale: _draggingItem == null
                          ? _hoverScale
                          : AlwaysStoppedAnimation(1.0),
                      child: DockButton(icon: icon),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class DockButton extends StatelessWidget {
  const DockButton({required this.icon, this.isDragging = false, super.key});

  final IconData icon;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 50),
      height: 48,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
        boxShadow: isDragging
            ? [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Center(
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
