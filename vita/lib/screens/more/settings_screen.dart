import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emergencyAlerts = true;
  bool _contributionAlerts = true;
  bool _receiptAlerts = true;
  bool _biometrics = false;
  String _language = 'English';

  String _fullName = 'Wali Medugu';
  String _email = 'wali@example.com';
  String _phone = '+234 800 000 0001';

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: VitaText.body(13, color: Colors.white)),
        backgroundColor: VitaColors.dark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _editStringSetting(String title, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Edit $title', style: VitaText.display(16, color: VitaColors.dark)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: VitaText.body(13, color: VitaColors.gray)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.trim().isNotEmpty) {
                setState(() => onSave(controller.text.trim()));
                _showSnackBar('$title updated successfully.');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Change Password', style: VitaText.display(16, color: VitaColors.dark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
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
              _showSnackBar('Password changed successfully.');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: VitaColors.dark,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back, color: Colors.white70, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text('Settings', style: VitaText.display(18, color: Colors.white, weight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  children: [
                    // Profile section
                    _SettingsCard(title: 'Profile', children: [
                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Full Name',
                        value: _fullName,
                        onTap: () => _editStringSetting('Full Name', _fullName, (v) => _fullName = v),
                      ),
                      _SettingsTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: _email,
                        onTap: () => _editStringSetting('Email', _email, (v) => _email = v),
                      ),
                      _SettingsTile(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: _phone,
                        onTap: () => _editStringSetting('Phone', _phone, (v) => _phone = v),
                        last: true,
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Notifications
                    _SettingsCard(title: 'Notifications', children: [
                      _SettingsToggle(
                        icon: Icons.emergency_rounded,
                        label: 'Emergency Alerts',
                        sub: 'Critical — cannot be disabled',
                        value: _emergencyAlerts,
                        onChanged: (v) {},
                        disabled: true,
                      ),
                      _SettingsToggle(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Contribution Updates',
                        value: _contributionAlerts,
                        onChanged: (v) => setState(() => _contributionAlerts = v),
                      ),
                      _SettingsToggle(
                        icon: Icons.receipt_long_rounded,
                        label: 'Receipt Notifications',
                        value: _receiptAlerts,
                        onChanged: (v) => setState(() => _receiptAlerts = v),
                        last: true,
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Security
                    _SettingsCard(title: 'Security', children: [
                      _SettingsToggle(
                        icon: Icons.fingerprint_rounded,
                        label: 'Biometric Login',
                        sub: 'Use fingerprint or Face ID',
                        value: _biometrics,
                        onChanged: (v) => setState(() => _biometrics = v),
                      ),
                      _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        label: 'Change Password',
                        onTap: _changePassword,
                        last: true,
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Language & Region
                    _SettingsCard(title: 'Language & Region', children: [
                      _SettingsDropdown(
                        icon: Icons.language_rounded,
                        label: 'Language',
                        value: _language,
                        options: ['English', 'Hausa', 'Yoruba', 'Igbo', 'Pidgin'],
                        onChanged: (v) => setState(() => _language = v!),
                        last: true,
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Legal
                    _SettingsCard(title: 'Legal', children: [
                      _SettingsTile(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () => context.push('/privacy')),
                      _SettingsTile(icon: Icons.gavel_outlined, label: 'Terms of Service', onTap: () => context.push('/terms')),
                      _SettingsTile(icon: Icons.info_outline_rounded, label: 'About VITA', onTap: () => context.push('/about'), last: true),
                    ]),
                    const SizedBox(height: 16),

                    // Danger
                    _SettingsCard(title: 'Account', children: [
                      _SettingsTile(
                        icon: Icons.logout_rounded,
                        label: 'Sign Out',
                        valueColor: VitaColors.red,
                        onTap: () => context.go('/auth'),
                        last: true,
                      ),
                    ]),
                    const SizedBox(height: 32),
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

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(title.toUpperCase(), style: VitaText.mono(10, color: VitaColors.gray).copyWith(letterSpacing: 1.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x0F000000)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.label, this.value, this.valueColor, required this.onTap, this.last = false});
  final IconData icon;
  final String label;
  final String? value;
  final Color? valueColor;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: last ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0D000000)))),
        child: Row(
          children: [
            Icon(icon, size: 18, color: valueColor ?? VitaColors.gray),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: VitaText.body(14, color: valueColor ?? VitaColors.dark, weight: FontWeight.w500))),
            if (value != null) ...[
              Text(value!, style: VitaText.body(13, color: VitaColors.gray)),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right_rounded, size: 18, color: VitaColors.gray.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  const _SettingsToggle({required this.icon, required this.label, this.sub, required this.value, required this.onChanged, this.disabled = false, this.last = false});
  final IconData icon;
  final String label;
  final String? sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool disabled;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: last ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0D000000)))),
      child: Row(
        children: [
          Icon(icon, size: 18, color: VitaColors.gray),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: VitaText.body(14, color: VitaColors.dark, weight: FontWeight.w500)),
                if (sub != null) Text(sub!, style: VitaText.body(11.5, color: VitaColors.gray)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: disabled ? null : onChanged,
            activeColor: VitaColors.teal,
          ),
        ],
      ),
    );
  }
}

class _SettingsDropdown extends StatelessWidget {
  const _SettingsDropdown({required this.icon, required this.label, required this.value, required this.options, required this.onChanged, this.last = false});
  final IconData icon;
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: last ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0D000000)))),
      child: Row(
        children: [
          Icon(icon, size: 18, color: VitaColors.gray),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: VitaText.body(14, color: VitaColors.dark, weight: FontWeight.w500))),
          DropdownButton<String>(
            value: value,
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: VitaText.body(13)))).toList(),
            onChanged: onChanged,
            underline: const SizedBox(),
            style: VitaText.body(13, color: VitaColors.gray),
          ),
        ],
      ),
    );
  }
}
