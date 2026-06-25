import 'package:flutter/material.dart';

class PinoteBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PinoteBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Border / Divider color di bagian atas navbar
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD8CDBE).withOpacity(0.5),
            width: 1.0,
          ),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color(0xFFFFFDF8), // Surface color
        elevation: 0, // Dibuat 0 karena sudah ada border di Container
        selectedItemColor: const Color(0xFF8A5A44), // Primary Action
        unselectedItemColor: const Color(0xFF6F4E37).withOpacity(0.6), // Icon unselected
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        currentIndex: currentIndex,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}