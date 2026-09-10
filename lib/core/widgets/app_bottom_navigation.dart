import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0F),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Accueil',
              active: currentIndex == 0,
              onTap: () => onDestinationSelected(0),
            ),
            _BottomNavItem(
              icon: Icons.search_outlined,
              activeIcon: Icons.search,
              label: 'Recherche',
              active: currentIndex == 1,
              onTap: () => onDestinationSelected(1),
            ),
            _BottomNavItem(
              icon: Icons.add_circle_outline,
              activeIcon: Icons.add_circle,
              label: 'Publier',
              active: currentIndex == 2,
              onTap: () => onDestinationSelected(2),
            ),
            _BottomNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profil',
              active: currentIndex == 3,
              onTap: () => onDestinationSelected(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : Colors.white54;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(active ? activeIcon : icon, size: 20, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
