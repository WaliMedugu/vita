import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';

class EmergencyConfirmScreen extends StatelessWidget {
  const EmergencyConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaColors.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildTop()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  children: [
                    // Details card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 48, offset: const Offset(0, 12))],
                        border: Border.all(color: const Color(0x0F000000)),
                      ),
                      child: Column(
                        children: [
                          _EcRow(icon: Icons.person_outline, label: 'Patient', value: 'Funke Okafor'),
                          _EcRow(icon: Icons.bloodtype_rounded, label: 'Blood Type', value: 'A− Negative'),
                          _EcRow(icon: Icons.location_on_outlined, label: 'Your GPS Location',
                            value: '9.0579° N, 7.4951° E',
                            sub: 'Near Wuse 2, Abuja',
                          ),
                          _EcRow(icon: Icons.account_balance_outlined, label: 'Pool Available',
                            value: '₦48,350', valueColor: VitaColors.green,
                          ),
                          _EcRow(icon: Icons.warning_amber_rounded, label: 'Allergies — Do NOT give',
                            value: 'Aspirin · Sulfa drugs', valueColor: VitaColors.red, last: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.pushReplacement('/emergency/hospitals'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VitaColors.red,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          shadowColor: VitaColors.red.withValues(alpha: 0.4),
                          elevation: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.sos_rounded, size: 26),
                            const SizedBox(width: 10),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('CONFIRM EMERGENCY', style: VitaText.display(22, color: Colors.white, weight: FontWeight.w700).copyWith(letterSpacing: -0.5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: VitaColors.gray),
                        const SizedBox(width: 5),
                        Text('GPS shared with all emergency contacts', style: VitaText.body(11.5, color: VitaColors.gray)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0x1A000000)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Cancel — False Alarm', style: VitaText.display(14, color: VitaColors.gray, weight: FontWeight.w700)),
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

  Widget _buildTop() {
    return Container(
      color: VitaColors.red,
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 68),
      child: Stack(
        children: [
          Center(
            child: Text('!', style: TextStyle(fontFamily: 'sans-serif', fontSize: 300, fontWeight: FontWeight.w900, color: Colors.black.withValues(alpha: 0.1), height: 0.9)),
          ),
          Column(
            children: [
              const Icon(Icons.emergency_rounded, size: 52, color: Colors.white),
              const SizedBox(height: 12),
              Text('Emergency\nActivation', style: VitaText.display(28, color: Colors.white, weight: FontWeight.w700).copyWith(letterSpacing: -0.8, height: 1.15), textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text('Confirm to alert contacts & release VitaPool', style: VitaText.body(13, color: Colors.white.withValues(alpha: 0.65)), textAlign: TextAlign.center),
            ],
          ),
        ],
      ),
    );
  }
}

class _EcRow extends StatelessWidget {
  const _EcRow({
    required this.icon,
    required this.label,
    required this.value,
    this.sub,
    this.valueColor,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? sub;
  final Color? valueColor;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: last ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0D000000)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: VitaColors.gray),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: VitaText.mono(11, color: VitaColors.gray).copyWith(letterSpacing: 0.8)),
                const SizedBox(height: 2),
                Text(value, style: VitaText.display(14, color: valueColor ?? VitaColors.dark, weight: FontWeight.w700)),
                if (sub != null) Text(sub!, style: VitaText.body(11.5, color: VitaColors.gray).copyWith(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
