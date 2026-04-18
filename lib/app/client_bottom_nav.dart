import 'package:flutter/material.dart';

import 'router.dart';

class ClientBottomNav extends StatelessWidget {
  const ClientBottomNav({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  static const List<String> _routes = [
    AppRouter.clientHome,
    AppRouter.clientOrders,
    AppRouter.clientCreateOrder,
    AppRouter.clientCreateSparePartRequest,
    AppRouter.clientAccount,
  ];

  void _open(BuildContext context, int index) {
    if (index == currentIndex) return;
    final target = _routes[index];
    Navigator.pushNamedAndRemoveUntil(
      context,
      target,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: scheme.primary,
      unselectedItemColor: scheme.onSurfaceVariant,
      backgroundColor: Colors.white,
      elevation: 8,
      onTap: (index) => _open(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long_rounded),
          label: 'طلباتي',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.handyman_outlined),
          activeIcon: Icon(Icons.handyman_rounded),
          label: 'صيانة',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.extension_outlined),
          activeIcon: Icon(Icons.extension_rounded),
          label: 'طلبات أخرى',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'حسابي',
        ),
      ],
    );
  }
}
