import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';
import 'package:vita/widgets/vita_tag_chip.dart';

class NFCReadResultScreen extends StatelessWidget {
  const NFCReadResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaColors.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Allergies
                    Text('ALLERGIES', style: VitaText.mono(11.5, color: VitaColors.gray, weight: FontWeight.w600).copyWith(letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 6, children: const [
                      VitaTagChip(label: 'Aspirin', isDanger: true),
                      VitaTagChip(label: 'Sulfa drugs', isDanger: true),
                    ]),
                    const SizedBox(height: 14),
                    // Conditions
                    Text('CONDITIONS', style: VitaText.mono(11.5, color: VitaColors.gray, weight: FontWeight.w600).copyWith(letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 6, children: const [
                      VitaTagChip(label: 'Type 2 Diabetes'),
                      VitaTagChip(label: 'Hypertension'),
                    ]),
                    const SizedBox(height: 16),
                    // Gemini First Aid
                    _FirstAidCard(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () => context.push('/emergency'),
                        style: ElevatedButton.styleFrom(backgroundColor: VitaColors.red),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.emergency_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text('EMERGENCY', style: VitaText.display(15, color: Colors.white, weight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Color(0x1F000000), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone_outlined, size: 16, color: VitaColors.dark),
                            const SizedBox(width: 6),
                            Text('Call', style: VitaText.display(14, color: VitaColors.dark, weight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: VitaColors.dark,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
                  child: Icon(Icons.arrow_back, color: Colors.white.withValues(alpha: 0.6), size: 18),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PATIENT IDENTIFIED', style: VitaText.mono(11, color: Colors.white.withValues(alpha: 0.4)).copyWith(letterSpacing: 1)),
                    Text('● Offline · VITA-NG-002841', style: VitaText.mono(12, color: VitaColors.teal.withValues(alpha: 0.8)), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: VitaColors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('A−', style: VitaText.display(20, color: VitaColors.lightRed, weight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Funke Okafor', style: VitaText.display(28, color: Colors.white, weight: FontWeight.w700).copyWith(letterSpacing: -1)),
          const SizedBox(height: 3),
          Text('NFC read · Jun 02, 2026 · 14:17 WAT', style: VitaText.mono(11, color: Colors.white.withValues(alpha: 0.35))),
        ],
      ),
    );
  }
}

class _FirstAidCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: VitaColors.lightGreen,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: VitaColors.teal, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy_outlined, size: 16, color: VitaColors.green),
              const SizedBox(width: 8),
              Text('Gemini · WHO First Aid', style: VitaText.display(13.5, color: VitaColors.green, weight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          _Step(num: '1', text: 'Check consciousness — call out, tap shoulder firmly'),
          _Step(num: '2', text: 'If conscious & diabetic: give sugary drink or glucose gel immediately'),
          _Step(num: '3', text: 'If unconscious: recovery position, monitor breathing, do NOT give food'),
          _Step(num: '4', text: 'Do NOT give Aspirin or Sulfa drugs — patient is allergic', last: true, bold: true),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: VitaColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: VitaColors.gold.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFF8a6700)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI-generated guidance only. Seek professional medical help immediately and always.',
                    style: VitaText.body(11.5, color: const Color(0xFF8a6700)).copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.num, required this.text, this.last = false, this.bold = false});
  final String num;
  final String text;
  final bool last;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: last ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x1E18A574)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: VitaColors.green),
            alignment: Alignment.center,
            child: Text(num, style: VitaText.mono(11, color: Colors.white, weight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: VitaText.body(13, color: VitaColors.dark, weight: bold ? FontWeight.w700 : FontWeight.w400).copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
