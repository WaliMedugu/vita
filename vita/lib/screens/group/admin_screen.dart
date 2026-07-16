import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vita/theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _secondsLeft = 24 * 60 + 38; // 24m 38s
  late Timer _timer;
  bool _showPendingBanner = true;
  String _currentMode = 'Passive · ₦100/txn';
  String _spendingLimit = '₦15,000 / emergency';
  String _reserveFloor = '₦3,000';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _timerLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s remaining';
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: VitaText.body(13, color: Colors.white)),
        backgroundColor: VitaColors.dark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onRequestModeChange() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Request Mode Change', style: VitaText.display(16, color: VitaColors.dark)),
        content: Text(
          'This will initiate a 30-minute window for all pool members to approve or object to switching the contribution mode.',
          style: VitaText.body(13, color: VitaColors.gray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: VitaText.body(13, color: VitaColors.gray)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _showPendingBanner = true;
                _secondsLeft = 30 * 60; // reset to 30 mins
              });
              _showSnackBar('Mode change request submitted to members.');
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _onEditLimits() {
    final limitController = TextEditingController(text: _spendingLimit.replaceAll(RegExp(r'[^\d,]+'), ''));
    final reserveController = TextEditingController(text: _reserveFloor.replaceAll(RegExp(r'[^\d,]+'), ''));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Edit Pool Limits', style: VitaText.display(16, color: VitaColors.dark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: limitController,
              decoration: const InputDecoration(
                labelText: 'Spending Limit (₦)',
                prefixText: '₦ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reserveController,
              decoration: const InputDecoration(
                labelText: 'Reserve Floor (₦)',
                prefixText: '₦ ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: VitaText.body(13, color: VitaColors.gray)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _spendingLimit = '₦${limitController.text} / emergency';
                _reserveFloor = '₦${reserveController.text}';
              });
              _showSnackBar('Pool limits updated successfully.');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _onDissolvePool() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Dissolve Pool?', style: VitaText.display(16, color: VitaColors.red)),
        content: Text(
          'WARNING: Dissolving the pool is permanent. All accumulated funds will be refunded back to the members wallets proportionately.',
          style: VitaText.body(13, color: VitaColors.gray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: VitaText.body(13, color: VitaColors.gray)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Pool dissolution initiated.');
            },
            style: ElevatedButton.styleFrom(backgroundColor: VitaColors.red),
            child: const Text('Dissolve'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaColors.white,
      appBar: AppBar(
        backgroundColor: VitaColors.dark,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Settings', style: VitaText.display(16, color: Colors.white)),
            Text('Kano Solidarity Pool', style: VitaText.mono(10, color: Colors.white.withOpacity(0.5))),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              children: [
                // Pending banner
                if (_showPendingBanner) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: VitaColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: VitaColors.gold.withValues(alpha: 0.35), width: 1.5),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.timer_outlined, size: 22, color: Color(0xFF8a6700)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mode Change Pending', style: VitaText.display(13.5, color: const Color(0xFF8a6700), weight: FontWeight.w700)),
                              const SizedBox(height: 3),
                              Text('Switching Passive → Scheduled. Members may object within the window.', style: VitaText.body(13, color: const Color(0xFF8a6700)).copyWith(height: 1.5)),
                              const SizedBox(height: 6),
                              Row(children: [
                                const Icon(Icons.timer, size: 14, color: Color(0xFFD4A017)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(_timerLabel, style: VitaText.mono(13.5, color: const Color(0xFFD4A017), weight: FontWeight.w700)),
                                ),
                              ]),
                              const SizedBox(height: 10),
                              Row(children: [
                                _SmallBtn(
                                  label: 'Proceed',
                                  color: VitaColors.teal,
                                  onTap: () {
                                    setState(() {
                                      _showPendingBanner = false;
                                      _currentMode = 'Scheduled · ₦500/week';
                                    });
                                    _showSnackBar('Mode change proceeded and is now active.');
                                  },
                                ),
                                const SizedBox(width: 8),
                                _SmallBtn(
                                  label: 'Cancel',
                                  color: VitaColors.red,
                                  onTap: () {
                                    setState(() {
                                      _showPendingBanner = false;
                                    });
                                    _showSnackBar('Pending mode change request cancelled.');
                                  },
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Contribution Mode
                _AdminCard(
                  title: 'Contribution Mode',
                  children: [
                    _ARow(
                      label: 'Current Mode',
                      value: _currentMode,
                      badge: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(color: VitaColors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text('Active', style: VitaText.mono(10.5, color: VitaColors.green)),
                      ),
                    ),
                  ],
                  extra: Column(
                    children: [
                      const SizedBox(height: 14),
                      _OutlineBtn(
                        label: 'Request Mode Change',
                        onTap: _onRequestModeChange,
                      ),
                      const SizedBox(height: 8),
                      Text('Opens 30-min objection window', style: VitaText.body(11, color: VitaColors.gray), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Pool Limits
                _AdminCard(
                  title: 'Pool Limits',
                  children: [
                    _ARow(label: 'Spending Limit', value: _spendingLimit),
                    _ARow(
                      label: 'Reserve Floor',
                      value: _reserveFloor,
                      badge: const Icon(Icons.lock_outline, size: 14, color: VitaColors.gold),
                    ),
                    _ARow(label: 'Active Members', value: '18', last: true),
                  ],
                  extra: Column(children: [
                    const SizedBox(height: 14),
                    _OutlineBtn(
                      label: 'Edit Limits',
                      onTap: _onEditLimits,
                    ),
                  ]),
                ),
                const SizedBox(height: 12),

                // Danger Zone
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: VitaColors.red.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Danger Zone', style: VitaText.display(14, color: VitaColors.red, weight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Text('These actions cannot be undone.', style: VitaText.body(13, color: VitaColors.gray)),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _onDissolvePool,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            side: BorderSide(color: VitaColors.red.withValues(alpha: 0.25), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: VitaColors.red, size: 18),
                              const SizedBox(width: 8),
                              Text('Dissolve Pool', style: VitaText.display(14, color: VitaColors.red, weight: FontWeight.w700)),
                            ],
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
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.title, required this.children, this.extra});
  final String title;
  final List<Widget> children;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x0F000000))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: VitaText.display(14, color: VitaColors.dark, weight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...children,
          if (extra != null) extra!,
        ],
      ),
    );
  }
}

class _ARow extends StatelessWidget {
  const _ARow({required this.label, required this.value, this.badge, this.last = false});
  final String label;
  final String value;
  final Widget? badge;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: last ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0D000000)))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: VitaText.body(11.5, color: VitaColors.gray, weight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: VitaText.display(13.5, color: VitaColors.dark, weight: FontWeight.w700)),
        ])),
        if (badge != null) badge!,
      ]),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  const _SmallBtn({required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: VitaText.body(12, color: Colors.white, weight: FontWeight.w600)),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  const _OutlineBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 13),
          side: BorderSide(color: VitaColors.green.withValues(alpha: 0.3), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: VitaText.display(14, color: VitaColors.green, weight: FontWeight.w700)),
      ),
    );
  }
}
