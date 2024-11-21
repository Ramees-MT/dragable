import 'package:flutter/material.dart';

/// Entrypoint of the application.


/// [Widget] building the [MaterialApp].
class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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

/// Dock with draggable and reorderable items.
class Dock extends StatefulWidget {
  const Dock({super.key, required this.items});

  /// Initial items to put in this [Dock].
  final List<IconData> items;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<IconData> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                final oldIndex = _items.indexOf(data);
                _items.removeAt(oldIndex);
                _items.insert(index, data);
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Draggable<IconData>(
                data: icon,
                feedback: DockButton(icon: icon, isDragging: true),
                childWhenDragging: Opacity(
                  opacity: 0.5,
                  child: DockButton(icon: icon),
                ),
                child: DockButton(icon: icon),
              );
            },
          );
        }),
      ),
    );
  }
}

/// A single dock button with draggable and animated scaling.
class DockButton extends StatefulWidget {
  const DockButton({required this.icon, this.isDragging = false, super.key});

  /// The icon to display in the button.
  final IconData icon;

  /// Whether this button is being dragged.
  final bool isDragging;

  @override
  State<DockButton> createState() => _DockButtonState();
}

class _DockButtonState extends State<DockButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
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
      child: ScaleTransition(
        scale: widget.isDragging ? const AlwaysStoppedAnimation(1.5) : _scaleAnimation,
        child: Container(
          constraints: const BoxConstraints(minWidth: 48),
          height: 48,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.primaries[widget.icon.hashCode %
                Colors.primaries.length], // Cycle through colors
            boxShadow: widget.isDragging
                ? [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Icon(widget.icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
