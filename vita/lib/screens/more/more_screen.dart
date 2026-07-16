import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaColors.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: VitaColors.dark,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('More', style: VitaText.display(22, color: Colors.white, weight: FontWeight.w700)),
                    Text('Features & settings', style: VitaText.mono(12, color: Colors.white.withValues(alpha: 0.4))),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section('Pool Management'),
                    _MoreItem(icon: Icons.group_outlined, label: 'Pool Members', sub: '18 active', onTap: () => context.push('/group/members')),
                    _MoreItem(icon: Icons.add_circle_outline_rounded, label: 'Create New Pool', sub: '3-step setup', onTap: () => context.push('/group/create')),
                    _MoreItem(icon: Icons.settings_outlined, label: 'Admin Settings', sub: 'Mode, limits & danger zone', onTap: () => context.push('/group/admin')),
                    const SizedBox(height: 8),

                    _section('Emergency'),
                    _MoreItem(icon: Icons.emergency_rounded, label: 'Emergency Mode', sub: 'Activate VitaPool', onTap: () => context.push('/emergency'), color: VitaColors.red),
                    _MoreItem(icon: Icons.local_hospital_outlined, label: 'Hospital Finder', sub: 'Nearest hospitals', onTap: () => context.push('/emergency/hospitals')),
                    _MoreItem(icon: Icons.receipt_long_rounded, label: 'Emergency Receipt', sub: 'Last event summary', onTap: () => context.push('/emergency/receipt')),
                    const SizedBox(height: 8),

                    _section('Features'),
                    _MoreItem(icon: Icons.chat_bubble_outline_rounded, label: 'VitaVoice SMS', sub: 'AI SMS bot', onTap: () => context.push('/vitavoice')),
                    const SizedBox(height: 8),

                    _section('Account'),
                    _MoreItem(icon: Icons.settings_outlined, label: 'Settings', sub: 'Profile, notifications, privacy', onTap: () => context.push('/settings')),
                    const SizedBox(height: 8),

                    _section('Legal & Support'),
                    _MoreItem(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () => context.push('/privacy')),
                    _MoreItem(icon: Icons.gavel_outlined, label: 'Terms of Service', onTap: () => context.push('/terms')),
                    _MoreItem(icon: Icons.info_outline_rounded, label: 'About VITA', onTap: () => context.push('/about')),
                    const SizedBox(height: 8),

                    // User card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x0F000000)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: VitaColors.teal),
                            alignment: Alignment.center,
                            child: Text('WM', style: VitaText.display(16, color: Colors.white, weight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 12),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Wali Medugu', style: VitaText.display(14, color: VitaColors.dark, weight: FontWeight.w600)),
                            Text('Admin · Kano Pool', style: VitaText.body(12, color: VitaColors.gray)),
                          ]),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => context.go('/auth'),
                            child: Text('Sign Out', style: VitaText.body(13, color: VitaColors.red, weight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label.toUpperCase(), style: VitaText.mono(10, color: VitaColors.gray).copyWith(letterSpacing: 1.5)),
  );
}

class _MoreItem extends StatelessWidget {
  const _MoreItem({required this.icon, required this.label, this.sub, required this.onTap, this.color});
  final IconData icon;
  final String label;
  final String? sub;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x08000000)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (color ?? VitaColors.green).withValues(alpha: 0.1),
              ),
              child: Icon(icon, size: 18, color: color ?? VitaColors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: VitaText.body(14, color: color ?? VitaColors.dark, weight: FontWeight.w600)),
                  if (sub != null) Text(sub!, style: VitaText.body(11.5, color: VitaColors.gray)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: VitaColors.gray.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }
}
