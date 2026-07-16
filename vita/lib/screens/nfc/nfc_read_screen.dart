import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';
import 'package:vita/widgets/nfc_ring_animation.dart';

class NFCReadScreen extends StatelessWidget {
  const NFCReadScreen({super.key});

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
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.07)),
                          child: Icon(Icons.arrow_back, color: Colors.white.withValues(alpha: 0.6), size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Scan Patient Card', style: VitaText.display(17, color: Colors.white, weight: FontWeight.w700)),
                    ],
                  ),
                ),
                const Spacer(),
                NFCRingAnimation(icon: Icons.wifi_tethering_rounded, iconSize: 48),
                const SizedBox(height: 28),
                Text('Ready to Scan', style: VitaText.display(28, color: Colors.white, weight: FontWeight.w700).copyWith(letterSpacing: -0.8), textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Tap the patient\'s VitaCard sticker against your phone to instantly access their health data offline',
                    style: VitaText.body(13.5, color: Colors.white.withValues(alpha: 0.45)).copyWith(height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: VitaColors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: VitaColors.teal.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.credit_card_rounded, size: 24, color: Colors.white.withValues(alpha: 0.45)),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text('Works fully offline · No internet needed', style: VitaText.body(12, color: Colors.white.withValues(alpha: 0.45)), overflow: TextOverflow.visible),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Simulate tap for demo
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/nfc/read-result'),
                      style: ElevatedButton.styleFrom(backgroundColor: VitaColors.teal),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Simulate Tap (Demo)', style: VitaText.display(16, color: Colors.white, weight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
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
