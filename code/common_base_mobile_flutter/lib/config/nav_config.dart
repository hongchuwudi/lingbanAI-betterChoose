import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/nav_item.dart';
import '../models/user.dart';
import '../screens/elder/elder_home_screen.dart';
import '../screens/elder/elder_care_screen.dart';
import '../screens/elder/elder_health_screen.dart';
import '../screens/child/child_home_screen.dart';
import '../screens/child/child_care_screen.dart';
import '../screens/child/child_health_screen.dart';
import '../screens/lingban_screen.dart';
import '../screens/profile_screen.dart';

class NavConfig {
  static List<NavItem> getNavItems(User? user) {
    if (user == null) {
      return [];
    }

    final roleCode = user.roleCode;
    final roleCategory = user.roleCategory;

    if (roleCategory == 'BUSINESS') {
      if (roleCode == 'oldMan') {
        return _getElderNavItems();
      } else if (roleCode == 'young') {
        return _getChildNavItems();
      }
    }

    return [];
  }

  static List<NavItem> _getElderNavItems() {
    return [
      NavItem(
        label: '首页',
        icon: LucideIcons.home,
        activeIcon: LucideIcons.home,
        screen: const ElderHomeScreen(),
      ),
      NavItem(
        label: '关怀',
        icon: LucideIcons.heartHandshake,
        activeIcon: LucideIcons.heartHandshake,
        screen: const ElderCareScreen(),
      ),
      NavItem(
        label: '灵伴',
        icon: LucideIcons.messageCircle,
        activeIcon: LucideIcons.messageCircle,
        screen: const LingbanScreen(),
        isSpecial: true,
        specialBackgroundColor: const Color(0xFF42A5F5),
        specialIconSize: 32,
      ),
      NavItem(
        label: '健康',
        icon: LucideIcons.heartPulse,
        activeIcon: LucideIcons.heartPulse,
        screen: const ElderHealthScreen(),
      ),
      NavItem(
        label: '我的',
        icon: LucideIcons.user,
        activeIcon: LucideIcons.user,
        screen: const ProfileScreen(),
      ),
    ];
  }

  static List<NavItem> _getChildNavItems() {
    return [
      NavItem(
        label: '首页',
        icon: LucideIcons.home,
        activeIcon: LucideIcons.home,
        screen: const ChildHomeScreen(),
      ),
      NavItem(
        label: '关怀',
        icon: LucideIcons.heartHandshake,
        activeIcon: LucideIcons.heartHandshake,
        screen: const ChildCareScreen(),
      ),
      NavItem(
        label: '灵伴',
        icon: LucideIcons.messageCircle,
        activeIcon: LucideIcons.messageCircle,
        screen: const LingbanScreen(),
        isSpecial: true,
        specialBackgroundColor: const Color(0xFF42A5F5),
        specialIconSize: 32,
      ),
      NavItem(
        label: '健康',
        icon: LucideIcons.heartPulse,
        activeIcon: LucideIcons.heartPulse,
        screen: const ChildHealthScreen(),
      ),
      NavItem(
        label: '我的',
        icon: LucideIcons.user,
        activeIcon: LucideIcons.user,
        screen: const ProfileScreen(),
      ),
    ];
  }
}
