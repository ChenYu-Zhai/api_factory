import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2C2C2C);
  
  // Primary
  static const Color primary = Colors.blue;
  static const Color primaryContainer = Color(0xFF1976D2); // Darker blue
  
  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;
  
  // Status
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color pending = Colors.grey;

  // Overlays
  static final Color overlay = Colors.black.withValues(alpha: 0.7);
  static final Color selectionOverlay = Colors.blue.withValues(alpha: 0.2);
  static final Color hoverOverlay = Colors.white.withValues(alpha: 0.1);
}
