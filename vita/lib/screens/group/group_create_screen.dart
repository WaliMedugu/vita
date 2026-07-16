import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';

class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  State<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  int _step = 0;
  int _mode = 0; // 0 = passive, 1 = scheduled

  final PageController _pageCtrl = PageController();

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      context.pop();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1(onNext: _next),
                  _Step2(selectedMode: _mode, onModeChange: (v) => setState(() => _mode = v), onNext: _next, onBack: _back),
                  _Step3(onNext: _next, onBack: _back),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final stepNums = ['01', '02', '03'];
    final stepTitles = ['Pool\nDetails', 'Contribution\nMode', 'Invite\nMembers'];
    final stepLabels = ['Step 1 of 3', 'Step 2 of 3', 'Step 3 of 3'];

    return Container(
      color: VitaColors.dark,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Stack(
        children: [
          Positioned(
            bottom: -40, right: -20,
            child: Text(stepNums[_step], style: VitaText.display(180, color: Colors.white.withValues(alpha: 0.04), weight: FontWeight.w700).copyWith(letterSpacing: -8)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stepLabels[_step], style: VitaText.mono(10, color: Colors.white.withValues(alpha: 0.35)).copyWith(letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text(stepTitles[_step], style: VitaText.display(26, color: Colors.white, weight: FontWeight.w700).copyWith(letterSpacing: -0.8, height: 1.15)),
              const SizedBox(height: 16),
              Row(
                children: List.generate(3, (i) {
                  final done = i < _step;
                  final active = i == _step;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 3,
                      margin: i < 2 ? const EdgeInsets.only(right: 5) : null,
                      decoration: BoxDecoration(
                        color: done ? VitaColors.teal : active ? Colors.white : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── STEP 1 ───────────────────────────────────────────────────────────────────
class _Step1 extends StatelessWidget {
  const _Step1({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GcField(label: 'Pool Name', hint: 'e.g. Kano Solidarity Pool'),
          const SizedBox(height: 14),
          _GcField(label: 'Spending Limit per Emergency', value: '₦15,000', sub: 'Default cap per event — editable anytime'),
          const SizedBox(height: 14),
          _GcField(label: 'Reserve Floor', value: '₦3,000', sub: 'Always protected · cannot be released'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Next', style: VitaText.display(16, color: Colors.white, weight: FontWeight.w700)), const SizedBox(width: 8), const Icon(Icons.arrow_forward, size: 18)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── STEP 2 ───────────────────────────────────────────────────────────────────
class _Step2 extends StatelessWidget {
  const _Step2({required this.selectedMode, required this.onModeChange, required this.onNext, required this.onBack});
  final int selectedMode;
  final ValueChanged<int> onModeChange;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose how members fund the pool. This can be changed later by admins (with a 30-min objection window).', style: VitaText.body(13, color: VitaColors.gray).copyWith(height: 1.6)),
          const SizedBox(height: 16),
          _ModeOption(
            title: 'Passive Sweep',
            description: 'A small ₦100 amount is automatically swept from each OPay transaction. Zero manual effort for members.',
            selected: selectedMode == 0,
            recommended: true,
            onTap: () => onModeChange(0),
            extra: selectedMode == 0 ? _GcField(label: 'Sweep Amount', value: '₦100') : null,
          ),
          const SizedBox(height: 10),
          _ModeOption(
            title: 'Scheduled Deposit',
            description: 'Fixed weekly or monthly deposit. Best for groups with predictable income cycles.',
            selected: selectedMode == 1,
            onTap: () => onModeChange(1),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Next', style: VitaText.display(16, color: Colors.white, weight: FontWeight.w700)), const SizedBox(width: 8), const Icon(Icons.arrow_forward, size: 18)]),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(onPressed: onBack, child: Text('← Back', style: VitaText.body(14, color: VitaColors.gray))),
          ),
        ],
      ),
    );
  }
}

// ─── STEP 3 ───────────────────────────────────────────────────────────────────
class _Step3 extends StatefulWidget {
  const _Step3({required this.onNext, required this.onBack});
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<_Step3> createState() => _Step3State();
}

class _Step3State extends State<_Step3> {
  final TextEditingController _inviteController = TextEditingController();
  final List<Map<String, String>> _invites = [
    {'initials': 'FK', 'email': 'funke@email.com', 'time': 'Invited just now'},
    {'initials': 'KB', 'email': 'kabiru@email.com', 'time': 'Invited 5 min ago'},
  ];

  void _addInvite() {
    final text = _inviteController.text.trim();
    if (text.isEmpty) return;

    String initials = "??";
    if (text.length >= 2) {
      initials = text.substring(0, 2).toUpperCase();
    } else if (text.isNotEmpty) {
      initials = text.substring(0, 1).toUpperCase();
    }

    setState(() {
      _invites.insert(0, {
        'initials': initials,
        'email': text,
        'time': 'Invited just now',
      });
    });
    _inviteController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitation sent to $text', style: VitaText.body(13, color: Colors.white)),
        backgroundColor: VitaColors.dark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _inviteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inviteController,
                  style: VitaText.body(14, weight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'email or phone number',
                    filled: true,
                    fillColor: const Color(0xFFF2F2F0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    hintStyle: VitaText.body(14, color: const Color(0xFFB0B0AE)),
                  ),
                  onSubmitted: (_) => _addInvite(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addInvite,
                style: ElevatedButton.styleFrom(
                  backgroundColor: VitaColors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Invite', style: VitaText.display(14, color: Colors.white, weight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('PENDING (${_invites.length})', style: VitaText.mono(11, color: VitaColors.gray).copyWith(letterSpacing: 1)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x0F000000))),
            child: Column(
              children: List.generate(_invites.length, (index) {
                final item = _invites[index];
                return _InviteItem(
                  initials: item['initials']!,
                  email: item['email']!,
                  time: item['time']!,
                  last: index == _invites.length - 1,
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onNext,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Create Pool', style: VitaText.display(16, color: Colors.white, weight: FontWeight.w700)),
                const SizedBox(width: 8),
                const Icon(Icons.celebration_rounded, size: 18),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(onPressed: widget.onBack, child: Text('Skip for now', style: VitaText.body(14, color: VitaColors.gray))),
          ),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({required this.title, required this.description, required this.selected, required this.onTap, this.recommended = false, this.extra});
  final String title;
  final String description;
  final bool selected;
  final bool recommended;
  final VoidCallback onTap;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? VitaColors.teal.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? VitaColors.teal : const Color(0x14000000), width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(title, style: VitaText.display(14, color: VitaColors.dark, weight: FontWeight.w700).copyWith(letterSpacing: -0.2)),
                      if (recommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: VitaColors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text('Recommended', style: VitaText.mono(10.5, color: VitaColors.green, weight: FontWeight.w600)),
                        ),
                      ],
                    ]),
                  ],
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? VitaColors.teal : const Color(0x26000000), width: 2),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: VitaColors.teal),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: VitaText.body(12.5, color: VitaColors.gray).copyWith(height: 1.5)),
            if (extra != null) ...[const SizedBox(height: 12), extra!],
          ],
        ),
      ),
    );
  }
}

class _InviteItem extends StatelessWidget {
  const _InviteItem({required this.initials, required this.email, required this.time, this.last = false});
  final String initials;
  final String email;
  final String time;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: last ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0D000000)))),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: VitaColors.lightGreen),
            alignment: Alignment.center,
            child: Text(initials, style: VitaText.body(13, color: VitaColors.green, weight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(email, style: VitaText.body(13.5, color: VitaColors.dark, weight: FontWeight.w600)),
              ),
              Text(time, style: VitaText.body(11, color: VitaColors.gray)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(color: VitaColors.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
            child: Text('Pending', style: VitaText.mono(10.5, color: const Color(0xFF8a6700))),
          ),
        ],
      ),
    );
  }
}

class _GcField extends StatelessWidget {
  const _GcField({required this.label, this.hint, this.value, this.sub});
  final String label;
  final String? hint;
  final String? value;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: VitaText.mono(11.5, color: VitaColors.dark, weight: FontWeight.w600).copyWith(letterSpacing: 0.8)),
        const SizedBox(height: 5),
        TextFormField(
          initialValue: value,
          style: VitaText.body(14, weight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF2F2F0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VitaColors.teal, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            hintStyle: VitaText.body(14, color: const Color(0xFFB0B0AE)),
          ),
        ),
        if (sub != null) ...[
          const SizedBox(height: 5),
          Text(sub!, style: VitaText.body(11.5, color: VitaColors.gray)),
        ],
      ],
    );
  }
}
