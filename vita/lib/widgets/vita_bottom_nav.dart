import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';

// ─── VITA BOTTOM NAV SHELL ────────────────────────────────────────────────────
class VitaShell extends StatelessWidget {
  const VitaShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const VitaBottomNav(),
    );
  }
}

// ─── VITA BOTTOM NAV BAR ──────────────────────────────────────────────────────
class VitaBottomNav extends StatelessWidget {
  const VitaBottomNav({super.key});

  static const _routes = ['/dashboard', '/health', '/nfc', '/more'];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _routes.length; i++) {
      if (loc.startsWith(_routes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0x12000000))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                active: idx == 0,
                onTap: () => context.go('/dashboard'),
              ),
              _NavItem(
                icon: Icons.medical_services_rounded,
                label: 'Profile',
                active: idx == 1,
                onTap: () => context.go('/health'),
              ),
              _NavItem(
                icon: Icons.nfc_rounded,
                label: 'NFC',
                active: idx == 2,
                onTap: () => context.go('/nfc'),
              ),
              _NavItem(
                icon: Icons.more_horiz_rounded,
                label: 'More',
                active: idx == 3,
                onTap: () => context.go('/more'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  size: 22,
                  color: active ? VitaColors.green : VitaColors.gray,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label.toUpperCase(),
                style: VitaText.mono(
                  9.5,
                  color: active ? VitaColors.green : VitaColors.gray,
                  weight: FontWeight.w600,
                ).copyWith(letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
