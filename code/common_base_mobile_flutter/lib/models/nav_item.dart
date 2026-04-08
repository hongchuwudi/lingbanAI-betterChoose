import 'package:flutter/material.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;
  final bool isSpecial;
  final Color? specialBackgroundColor;
  final double? specialIconSize;

  NavItem({
    required this.label,
    required this.icon,
    IconData? activeIcon,
    required this.screen,
    this.isSpecial = false,
    this.specialBackgroundColor,
    this.specialIconSize,
  }) : activeIcon = activeIcon ?? icon;

  IconData get activeIconData => activeIcon;
}
