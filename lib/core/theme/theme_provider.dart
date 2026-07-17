import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

// Theme state provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});
