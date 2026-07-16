import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';

class EmergencyReceiptScreen extends StatelessWidget {
  const EmergencyReceiptScreen({super.key});

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
                color: VitaColors.green,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/dashboard'),
                      child: Icon(Icons.arrow_back, color: Colors.white.withValues(alpha: 0.7), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Text('Emergency Closed', style: VitaText.display(18, color: Colors.white, weight: FontWeight.w700).copyWith(letterSpacing: -0.4)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text('Resolved', style: VitaText.mono(11, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero amount
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0x0F000000))),
                      ),
                      child: Column(
                        children: [
                          Text('TOTAL SPENT', style: VitaText.mono(12, color: VitaColors.gray).copyWith(letterSpacing: 1)),
                          const SizedBox(height: 6),
                          Text('₦14,500', style: VitaText.display(52, color: VitaColors.red, weight: FontWeight.w700).copyWith(letterSpacing: -2, height: 1)),
                          const SizedBox(height: 6),
                          Text('REF-EMG-0041 · Jun 02, 2026', style: VitaText.mono(12, color: VitaColors.gray)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Summary card
                    _RcCard(children: [
                      _RcRow(label: 'Patient', value: 'Funke Okafor'),
                      _RcRow(label: 'Pool', value: 'Kano Solidarity Pool'),
                      _RcRow(label: 'Remaining Balance', value: '₦33,850', valueColor: VitaColors.teal),
                      _RcRow(
                        label: 'Protected Floor',
                        value: '',
                        valueWidget: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: VitaColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(children: [
                            const Icon(Icons.lock, size: 11, color: Color(0xFF8a6700)),
                            const SizedBox(width: 4),
                            Text('₦3,000', style: VitaText.mono(11.5, color: const Color(0xFF8a6700))),
                          ]),
                        ),
                        last: true,
                      ),
                    ]),
                    const SizedBox(height: 14),
                    Text('ITEMIZED PAYMENTS', style: VitaText.mono(10, color: VitaColors.gray).copyWith(letterSpacing: 1.5)),
                    const SizedBox(height: 12),
                    _RcCard(children: [
                      _PayItem(dest: 'Kabiru Aliyu · Bystander', ref: 'OPY-2026-EMG-904401', amount: '₦8,000'),
                      _PayItem(dest: 'National Hospital Abuja', ref: 'OPY-2026-EMG-904402', amount: '₦5,000'),
                      _PayItem(dest: 'Transport', ref: 'OPY-2026-EMG-904403', amount: '₦1,500', last: true),
                    ]),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: VitaColors.lightGreen, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 16, color: VitaColors.green),
                          const SizedBox(width: 8),
                          Text('Receipt broadcast to all 18 members · 14:32 WAT', style: VitaText.body(12.5, color: VitaColors.green, weight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Generating receipt PDF and opening share sheet...', style: VitaText.body(13, color: Colors.white)),
                              backgroundColor: VitaColors.dark,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: BorderSide(color: VitaColors.green.withValues(alpha: 0.3), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.share_outlined, size: 18, color: VitaColors.green),
                            const SizedBox(width: 8),
                            Text('Share Receipt PDF', style: VitaText.display(15, color: VitaColors.green, weight: FontWeight.w700)),
                          ],
                        ),
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
}

class _RcCard extends StatelessWidget {
  const _RcCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x0F000000)),
      ),
      child: Column(children: children),
    );
  }
}

class _RcRow extends StatelessWidget {
  const _RcRow({required this.label, required this.value, this.valueColor, this.valueWidget, this.last = false});
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? valueWidget;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: last ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0D000000)))),
      child: Row(
        children: [
          Text(label, style: VitaText.body(12.5, color: VitaColors.gray)),
          const Spacer(),
          valueWidget ?? Text(value, style: VitaText.display(13.5, color: valueColor ?? VitaColors.dark, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _PayItem extends StatelessWidget {
  const _PayItem({required this.dest, required this.ref, required this.amount, this.last = false});
  final String dest;
  final String ref;
  final String amount;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: last ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0D000000)))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dest, style: VitaText.display(13.5, color: VitaColors.dark, weight: FontWeight.w700)),
                Text(ref, style: VitaText.mono(10.5, color: VitaColors.gray)),
              ],
            ),
          ),
          Text(amount, style: VitaText.display(16, color: VitaColors.teal, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}
