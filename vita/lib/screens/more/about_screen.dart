import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaColors.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                color: VitaColors.green,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Icon(Icons.arrow_back, color: Colors.white.withValues(alpha: 0.7), size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Text('V', style: VitaText.display(38, color: Colors.white, weight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 16),
                    Text('VITA', style: VitaText.display(32, color: Colors.white, weight: FontWeight.w700).copyWith(letterSpacing: -1)),
                    const SizedBox(height: 4),
                    Text('Community Health & Emergency Pool', style: VitaText.body(14, color: Colors.white.withValues(alpha: 0.65))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                      child: Text('Version 1.0.0 (Build 1)', style: VitaText.mono(11, color: Colors.white.withValues(alpha: 0.8))),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x0F000000))),
                      child: Text(
                        'VITA is a community-powered health emergency platform built for Nigeria. A ₦300 NFC sticker stores your health data offline — readable in any crisis. Community micro-contributions of ₦100 per OPay transaction build a shared safety fund that releases instantly when emergencies strike.',
                        style: VitaText.body(14, color: VitaColors.gray).copyWith(height: 1.7),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _AboutStat(icon: Icons.group_rounded, value: '133M', label: 'Uninsured Nigerians we\'re solving for'),
                    const SizedBox(height: 10),
                    _AboutStat(icon: Icons.timer_rounded, value: '90s', label: 'Target response time: tap card to funds'),
                    const SizedBox(height: 10),
                    _AboutStat(icon: Icons.credit_card_rounded, value: '₦300', label: 'Cost of a NFC VitaCard sticker'),
                    const SizedBox(height: 24),
                    Text('BUILT WITH', style: VitaText.mono(10, color: VitaColors.gray).copyWith(letterSpacing: 1.5)),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      _TechChip('Flutter'),
                      _TechChip('OPay API'),
                      _TechChip('Gemini AI'),
                      _TechChip('NTAG213 NFC'),
                      _TechChip('Google Maps'),
                      _TechChip('Firebase'),
                    ]),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening email client to support@vita.ng...', style: VitaText.body(13, color: Colors.white)),
                            backgroundColor: VitaColors.dark,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: VitaColors.lightGreen, borderRadius: BorderRadius.circular(16), border: Border.all(color: VitaColors.green.withValues(alpha: 0.2))),
                        child: Row(
                          children: [
                            const Icon(Icons.email_outlined, color: VitaColors.green, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Contact Support', style: VitaText.display(14, color: VitaColors.dark, weight: FontWeight.w700)),
                                Text('support@vita.ng', style: VitaText.mono(12, color: VitaColors.green)),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(child: Text('© 2026 VITA Health Technologies Ltd · Kano, Nigeria', style: VitaText.body(12, color: VitaColors.gray))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutStat extends StatelessWidget {
  const _AboutStat({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x0F000000))),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: const BoxDecoration(shape: BoxShape.circle, color: VitaColors.lightGreen), child: Icon(icon, color: VitaColors.green, size: 20)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value, style: VitaText.display(22, color: VitaColors.dark, weight: FontWeight.w700).copyWith(letterSpacing: -0.5)),
              Text(label, style: VitaText.body(12, color: VitaColors.gray)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  const _TechChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: VitaColors.lightGreen, borderRadius: BorderRadius.circular(20), border: Border.all(color: VitaColors.green.withValues(alpha: 0.2))),
      child: Text(label, style: VitaText.body(12, color: VitaColors.green, weight: FontWeight.w600)),
    );
  }
}
