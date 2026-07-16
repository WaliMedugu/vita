import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';
import 'package:vita/widgets/nfc_ring_animation.dart';

class NFCHomeScreen extends StatelessWidget {
  const NFCHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaColors.dark,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: BackgroundRings()),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    children: [
                      Text('NFC', style: VitaText.display(22, color: Colors.white, weight: FontWeight.w700)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: VitaColors.teal.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('ACTIVE', style: VitaText.mono(9, color: VitaColors.lightTeal).copyWith(letterSpacing: 1)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                NFCRingAnimation(icon: Icons.nfc_rounded, iconSize: 52),
                const SizedBox(height: 32),
                Text(
                  'What would you like to do?',
                  style: VitaText.display(24, color: Colors.white, weight: FontWeight.w700).copyWith(letterSpacing: -0.8),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Write your health card or scan\na patient\'s VitaCard sticker',
                  style: VitaText.body(14, color: Colors.white.withValues(alpha: 0.45)).copyWith(height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    children: [
                      _NFCBtn(
                        icon: Icons.nfc_rounded,
                        label: 'Write My VitaCard',
                        sub: 'Encode your health profile to NFC',
                        onTap: () => context.push('/nfc/write'),
                      ),
                      const SizedBox(height: 12),
                      _NFCBtn(
                        icon: Icons.wifi_tethering_rounded,
                        label: 'Scan Patient Card',
                        sub: 'Read health data offline',
                        onTap: () => context.push('/nfc/read'),
                        outlined: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NFCBtn extends StatelessWidget {
  const _NFCBtn({required this.icon, required this.label, required this.sub, required this.onTap, this.outlined = false});
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : VitaColors.teal,
          borderRadius: BorderRadius.circular(14),
          border: outlined ? Border.all(color: Colors.white.withValues(alpha: 0.15)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: outlined ? Colors.white : Colors.white, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: VitaText.display(15, color: Colors.white, weight: FontWeight.w700).copyWith(letterSpacing: -0.3)),
                  Text(sub, style: VitaText.body(11.5, color: Colors.white.withValues(alpha: 0.6))),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Icon(Icons.arrow_forward, color: Colors.white.withValues(alpha: 0.6), size: 18),
          ],
        ),
      ),
    );
  }
}
