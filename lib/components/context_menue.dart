import 'dart:ui';
import 'package:flutter/material.dart';

import '../model/context_menu_item.dart';

class MacosContextMenu extends StatelessWidget {
  final List<ContextMenuItem> items;

  const MacosContextMenu({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 220,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.44),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: items.map(_buildItem).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(ContextMenuItem item) {
    if (item.divider) {
      return Divider(
        height: 1,
        thickness: 0.6,
        color: Colors.white.withOpacity(0.15),
      );
    }

    return HoverTile(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          children: [
            Icon(item.icon, size: 16, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            if (item.trailing != null)
              Icon(item.trailing, size: 16, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class HoverTile extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const HoverTile({required this.child, this.onTap});

  @override
  State<HoverTile> createState() => HoverTileState();
}

class HoverTileState extends State<HoverTile> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0,vertical: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: hover
                  ? const Color(0xFF0A84FF).withOpacity(0.65)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12)
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}