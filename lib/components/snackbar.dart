import 'dart:ui';
import 'package:flutter/material.dart';

class BubbleSnackBar extends StatelessWidget {
  final String message;

  const BubbleSnackBar({super.key, required this.message});


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.44),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.dividerColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            message,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}