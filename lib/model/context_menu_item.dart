import 'package:flutter/cupertino.dart';

class ContextMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool divider;
  final IconData? trailing;

  ContextMenuItem({
    required this.label,
    required this.icon,
    this.onTap,
    this.trailing,
    this.divider = false,
  });
}