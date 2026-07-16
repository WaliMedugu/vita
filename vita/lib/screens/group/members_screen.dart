import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';


class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      style: VitaText.body(14),
                      decoration: InputDecoration(
                        hintText: 'Search members...',
                        prefixIcon: const Icon(Icons.search, color: VitaColors.gray, size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF2F2F0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        hintStyle: VitaText.body(14, color: const Color(0xFFB0B0AE)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('ADMIN', style: VitaText.mono(10, color: VitaColors.gray).copyWith(letterSpacing: 1.5)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x0F000000))),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: VitaColors.green),
                            alignment: Alignment.center,
                            child: Text('WM', style: VitaText.display(14, color: Colors.white, weight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Wali Medugu', style: VitaText.display(14, color: VitaColors.dark, weight: FontWeight.w700)),
                              Text('Joined Nov 2025', style: VitaText.body(11.5, color: VitaColors.gray)),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(color: VitaColors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text('Admin', style: VitaText.mono(10.5, color: VitaColors.green)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('MEMBERS (17)', style: VitaText.mono(10, color: VitaColors.gray).copyWith(letterSpacing: 1.5)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x0F000000))),
                      child: Column(
                        children: [
                          _MemberRow(initials: 'FO', name: 'Funke Okafor', sub: 'Joined Jan 2026', status: 'Member', statusColor: VitaColors.gray),
                          _MemberRow(initials: 'KA', name: 'Kabiru Aliyu', sub: 'Joined Jan 2026', status: 'Member', statusColor: VitaColors.gray),
                          _MemberRow(initials: 'ZB', name: 'Zainab Bala', sub: 'Invited 2 days ago', status: 'Pending', statusColor: const Color(0xFF8a6700), statusBg: Color(0x1FD4A017), last: true),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Displaying all 17 members of Kano Solidarity Pool...', style: VitaText.body(13, color: Colors.white)),
                                  backgroundColor: VitaColors.dark,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text('View all 17 →', style: VitaText.body(12.5, color: VitaColors.teal, weight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ],
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pool Members', style: VitaText.display(18, color: Colors.white, weight: FontWeight.w700).copyWith(letterSpacing: -0.4)),
                const SizedBox(height: 2),
                Text('Kano Pool · 18 active', style: VitaText.mono(12, color: Colors.white.withValues(alpha: 0.4))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.push('/group/create'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(children: [
                const Icon(Icons.add, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text('Invite', style: VitaText.body(13, color: Colors.white, weight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.initials, required this.name, required this.sub,
    required this.status, required this.statusColor, this.statusBg, this.last = false,
  });
  final String initials, name, sub, status;
  final Color statusColor;
  final Color? statusBg;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: last ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0D000000)))),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: VitaColors.lightGreen),
            alignment: Alignment.center,
            child: Text(initials, style: VitaText.body(13, color: VitaColors.green, weight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: VitaText.body(13.5, color: VitaColors.dark, weight: FontWeight.w600)),
              Text(sub, style: VitaText.mono(10.5, color: VitaColors.gray)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: statusBg ?? Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status, style: VitaText.mono(10.5, color: statusColor)),
          ),
        ],
      ),
    );
  }
}
