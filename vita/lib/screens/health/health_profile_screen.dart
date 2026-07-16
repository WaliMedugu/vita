import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';
import 'package:vita/widgets/vita_tag_chip.dart';

class HealthProfileScreen extends StatelessWidget {
  const HealthProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaColors.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 0),
                    _medicalCard(),
                    const SizedBox(height: 14),
                    _contactsCard(context),
                    const SizedBox(height: 14),
                    _poolCard(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/health/edit'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Edit Health Profile', style: VitaText.display(16, color: Colors.white, weight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18),
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

  Widget _buildHeader() {
    return Container(
      color: VitaColors.dark,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 56),
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Text(
                'VITA',
                style: VitaText.display(200,
                  color: Colors.white.withValues(alpha: 0.03),
                  weight: FontWeight.w700,
                ).copyWith(letterSpacing: -10),
              ),
            ),
          ),
          Column(
            children: [
              // Avatar
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VitaColors.green,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 3),
                ),
                alignment: Alignment.center,
                child: Text('WM', style: VitaText.display(26, color: Colors.white, weight: FontWeight.w700)),
              ),
              const SizedBox(height: 14),
              Text(
                'Wali Medugu',
                style: VitaText.display(22, color: Colors.white, weight: FontWeight.w700).copyWith(letterSpacing: -0.5),
              ),
              const SizedBox(height: 3),
              Text(
                'wali@example.com',
                style: VitaText.mono(12.5, color: Colors.white.withValues(alpha: 0.45)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _medicalCard() {
    return _HCard(
      title: 'Medical Details',
      icon: Icons.bloodtype_rounded,
      children: [
        _HRow(label: 'Blood Type', value: _BloodBadge(type: 'O+')),
        const SizedBox(height: 10),
        Text('CONDITIONS', style: VitaText.mono(11, color: VitaColors.gray).copyWith(letterSpacing: 1)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: const [
          VitaTagChip(label: 'Asthma'),
          VitaTagChip(label: 'Hypertension'),
        ]),
        const SizedBox(height: 10),
        Text('ALLERGIES', style: VitaText.mono(11, color: VitaColors.gray).copyWith(letterSpacing: 1)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: const [
          VitaTagChip(label: 'Penicillin', isDanger: true),
          VitaTagChip(label: 'Peanuts', isDanger: true),
          VitaTagChip(label: 'Latex', isDanger: true),
        ]),
      ],
    );
  }

  Widget _contactsCard(BuildContext context) {
    return _HCard(
      title: 'Emergency Contacts',
      icon: Icons.phone_in_talk_rounded,
      children: [
        _HRow(
          label: 'Primary',
          value: Row(children: [
            Expanded(
              child: Text('Fatima Medugu', style: VitaText.display(13.5, color: VitaColors.dark, weight: FontWeight.w700), overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            _CallBtn(
              label: 'Call',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Dialling Fatima Medugu (+234 809 123 4567)...', style: VitaText.body(13, color: Colors.white)),
                    backgroundColor: VitaColors.dark,
                  ),
                );
              },
            ),
          ]),
          valueExpanded: true,
        ),
        _HRow(
          label: 'Secondary',
          value: Row(children: [
            Expanded(
              child: Text('Dr. Nubwa Medugu', style: VitaText.display(13.5, color: VitaColors.dark, weight: FontWeight.w700), overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            _CallBtn(
              label: 'Call',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Dialling Dr. Nubwa Medugu (+234 803 987 6543)...', style: VitaText.body(13, color: Colors.white)),
                    backgroundColor: VitaColors.dark,
                  ),
                );
              },
            ),
          ]),
          valueExpanded: true,
        ),
      ],
    );
  }

  Widget _poolCard() {
    return _HCard(
      title: 'Linked VitaPool',
      icon: Icons.account_balance_rounded,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: VitaColors.lightGreen,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: VitaColors.green.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.account_balance_rounded, size: 28, color: VitaColors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('POOL-KAN-0041', style: VitaText.mono(13, color: VitaColors.green, weight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('Kano Solidarity Pool · 18 members', style: VitaText.body(12, color: VitaColors.gray)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── SHARED CARD ──────────────────────────────────────────────────────────────
class _HCard extends StatelessWidget {
  const _HCard({required this.title, required this.icon, required this.children});
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x0F000000)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: VitaColors.green),
              const SizedBox(width: 8),
              Text(title, style: VitaText.display(14, color: VitaColors.dark, weight: FontWeight.w700).copyWith(letterSpacing: -0.3)),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _HRow extends StatelessWidget {
  const _HRow({required this.label, required this.value, this.valueExpanded = false});
  final String label;
  final Widget value;
  final bool valueExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0D000000))),
      ),
      child: Row(
        children: [
          Text(label, style: VitaText.body(11.5, color: VitaColors.gray, weight: FontWeight.w500)),
          const SizedBox(width: 12),
          if (valueExpanded) Expanded(child: value) else value,
        ],
      ),
    );
  }
}

class _BloodBadge extends StatelessWidget {
  const _BloodBadge({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: VitaColors.lightRedBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(type, style: VitaText.display(16, color: VitaColors.red, weight: FontWeight.w700)),
    );
  }
}

class _CallBtn extends StatelessWidget {
  const _CallBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: VitaColors.lightGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone_outlined, size: 14, color: VitaColors.green),
            const SizedBox(width: 4),
            Text(label, style: VitaText.body(13, color: VitaColors.green, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
