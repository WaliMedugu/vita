import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';
import 'package:vita/widgets/pool_card_widget.dart';
import 'package:vita/widgets/transaction_item.dart';
import 'package:vita/widgets/emergency_cta.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isPassive = true;
  late AnimationController _liveDotCtrl;
  late Animation<double> _liveDotAnim;

  @override
  void initState() {
    super.initState();
    _liveDotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _liveDotAnim = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _liveDotCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _liveDotCtrl.dispose();
    super.dispose();
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active_outlined, color: VitaColors.teal),
                  const SizedBox(width: 10),
                  Text(
                    'Notifications',
                    style: VitaText.display(20, color: VitaColors.dark),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildNotificationItem(
                'Emergency resolved',
                'Kano Solidarity Pool released ₦14,500 for Funke Okafor.',
                '2 hrs ago',
                isAlert: true,
              ),
              const SizedBox(height: 12),
              _buildNotificationItem(
                'Weekly contribution successful',
                '₦500 swept successfully from your OPay wallet.',
                '1 day ago',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String body, String time, {bool isAlert = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6, right: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAlert ? VitaColors.red : VitaColors.green,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: VitaText.display(14, color: VitaColors.dark, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(body, style: VitaText.body(12, color: VitaColors.gray)),
              const SizedBox(height: 2),
              Text(time, style: VitaText.mono(10, color: VitaColors.gray)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTop(context),
              _buildBody(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTop(BuildContext context) {
    return Container(
      color: _isPassive ? VitaColors.dark : const Color(0xFF0D2A1E),
      child: Stack(
        children: [
          Positioned(
            bottom: -20,
            right: -10,
            child: Text(
              'VITA',
              style: VitaText.display(140,
                color: Colors.white.withValues(alpha: 0.04),
                weight: FontWeight.w700,
              ).copyWith(letterSpacing: -6),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              children: [
                // Greeting row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GOOD MORNING',
                            style: VitaText.mono(12.5,
                              color: Colors.white.withValues(alpha: 0.4),
                            ).copyWith(letterSpacing: 0),
                          ),
                          Text(
                            'Wali Medugu',
                            style: VitaText.display(19,
                              color: Colors.white,
                              weight: FontWeight.w700,
                            ).copyWith(letterSpacing: -0.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _IconBtn(icon: Icons.notifications_outlined, onTap: _showNotifications),
                    const SizedBox(width: 10),
                    _IconBtn(icon: Icons.settings_outlined, onTap: () => context.push('/settings')),
                  ],
                ),
                const SizedBox(height: 28),
                // Pool card
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _isPassive
                      ? PoolCardWidget(
                          key: const ValueKey('passive'),
                          poolName: 'Kano Solidarity Pool',
                          amount: '₦48,350',
                          mode: PoolMode.passive,
                        )
                      : PoolCardWidget(
                          key: const ValueKey('scheduled'),
                          poolName: "Abuja Women's Pool",
                          amount: '₦71,200',
                          mode: PoolMode.scheduled,
                          cardColor: const Color(0xFF2A6040),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode toggle
          Row(
            children: [
              _ModeChip(label: 'Passive', active: _isPassive, onTap: () => setState(() => _isPassive = true)),
              const SizedBox(width: 8),
              _ModeChip(label: 'Scheduled', active: !_isPassive, onTap: () => setState(() => _isPassive = false)),
            ],
          ),
          const SizedBox(height: 20),

          // Scheduled mode reminder
          if (!_isPassive) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: VitaColors.gold.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF8a6700), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'NEXT CONTRIBUTION',
                        style: VitaText.mono(11, color: const Color(0xFF8a6700)).copyWith(letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Friday, Jun 6 · ₦500',
                    style: VitaText.display(20, color: VitaColors.dark, weight: FontWeight.w700).copyWith(letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 3),
                  Text('Auto-debit from OPay wallet', style: VitaText.body(12, color: VitaColors.gray)),
                ],
              ),
            ),
          ],

          // ── EMERGENCY & IMMEDIATE ACCESS CONSOLE ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: VitaColors.red.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: VitaColors.red.withValues(alpha: 0.18), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: VitaColors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emergency_rounded, color: VitaColors.red, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'EMERGENCY CONSOLE',
                      style: VitaText.mono(11, color: VitaColors.red, weight: FontWeight.w700).copyWith(letterSpacing: 0.5),
                    ),
                    const Spacer(),
                    AnimatedBuilder(
                      animation: _liveDotAnim,
                      builder: (_, __) => Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: VitaColors.red.withValues(alpha: _liveDotAnim.value),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                EmergencyCTA(onTap: () => context.push('/emergency')),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ImmediateActionTile(
                        icon: Icons.wifi_tethering_rounded,
                        label: 'Scan Card',
                        onTap: () => context.push('/nfc/read'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ImmediateActionTile(
                        icon: Icons.local_hospital_rounded,
                        label: 'Hospitals',
                        onTap: () => context.push('/emergency/hospitals'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ImmediateActionTile(
                        icon: Icons.chat_bubble_rounded,
                        label: 'Voice Bot',
                        onTap: () => context.push('/vitavoice'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── RECENT ACTIVITY / LIVE FEED ──
          Row(
            children: [
              AnimatedBuilder(
                animation: _liveDotAnim,
                builder: (_, __) => Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: VitaColors.teal,
                    boxShadow: [
                      BoxShadow(
                        color: VitaColors.teal.withValues(alpha: _liveDotAnim.value * 0.5),
                        blurRadius: 6,
                        spreadRadius: _liveDotAnim.value * 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _isPassive ? 'LIVE FEED' : 'RECENT ACTIVITY',
                style: VitaText.mono(10, color: VitaColors.gray).copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 1, color: const Color(0x0F000000))),
            ],
          ),
          const SizedBox(height: 10),

          // Transactions - Clicking any transaction item takes to receipt for demonstration
          if (_isPassive) ...[
            TransactionList(
              children: [
                GestureDetector(
                  onTap: () => context.push('/emergency/receipt'),
                  child: const TransactionItem(initials: 'FO', name: 'Funke Ojo', ref: 'OPY-2024-884772', amount: '+₦100', time: '2 min ago'),
                ),
                GestureDetector(
                  onTap: () => context.push('/emergency/receipt'),
                  child: const TransactionItem(initials: 'KA', name: 'Kabiru Aliyu', ref: 'OPY-2024-884401', amount: '+₦100', time: '18 min ago'),
                ),
                GestureDetector(
                  onTap: () => context.push('/emergency/receipt'),
                  child: const TransactionItem(initials: 'NM', name: 'Ngozi Madu', ref: 'OPY-2024-883990', amount: '+₦100', time: '2 hrs ago'),
                ),
                GestureDetector(
                  onTap: () => context.push('/emergency/receipt'),
                  child: const TransactionItem(initials: 'BT', name: 'Bola Taiwo', ref: 'OPY-2024-882217', amount: '+₦100', time: '5 hrs ago'),
                ),
              ],
            ),
          ] else ...[
            TransactionList(
              children: [
                GestureDetector(
                  onTap: () => context.push('/emergency/receipt'),
                  child: const TransactionItem(initials: 'ZB', name: 'Zainab Bala', ref: 'OPY-2024-991100', amount: '+₦500', time: '1 day ago'),
                ),
                GestureDetector(
                  onTap: () => context.push('/emergency/receipt'),
                  child: const TransactionItem(initials: 'AB', name: 'Amina Bello', ref: 'OPY-2024-990877', amount: '+₦500', time: '1 day ago'),
                ),
                GestureDetector(
                  onTap: () => context.push('/emergency/receipt'),
                  child: const TransactionItem(
                    initials: 'RE',
                    name: 'Emergency Release',
                    ref: 'OPY-2024-EMG-0041',
                    amount: '−₦12,000',
                    time: '3 days ago',
                    amountColor: VitaColors.red,
                    avatarBg: VitaColors.lightRedBg,
                    avatarFg: VitaColors.red,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),

          // ── UTILITIES & SETTINGS ──
          Text(
            'UTILITIES & MANAGEMENT',
            style: VitaText.mono(10, color: VitaColors.gray).copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.1,
            children: [
              _UtilityAction(
                icon: Icons.nfc_rounded,
                title: 'Write Card',
                onTap: () => context.push('/nfc/write'),
              ),
              _UtilityAction(
                icon: Icons.group_outlined,
                title: 'Members',
                onTap: () => context.push('/group/members'),
              ),
              _UtilityAction(
                icon: Icons.medical_services_outlined,
                title: 'Health ID',
                onTap: () => context.go('/health'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? VitaColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? VitaColors.green : const Color(0x1A000000),
          ),
        ),
        child: Text(
          label,
          style: VitaText.body(12.5,
            color: active ? Colors.white : VitaColors.gray,
            weight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ImmediateActionTile extends StatelessWidget {
  const _ImmediateActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VitaColors.red.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: VitaColors.red),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: VitaText.display(12, color: VitaColors.dark, weight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UtilityAction extends StatelessWidget {
  const _UtilityAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x0F000000)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: VitaColors.green),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: VitaText.display(12, color: VitaColors.dark, weight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
