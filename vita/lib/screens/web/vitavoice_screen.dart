import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';

class VitaVoiceScreen extends StatefulWidget {
  const VitaVoiceScreen({super.key});

  @override
  State<VitaVoiceScreen> createState() => _VitaVoiceScreenState();
}

class _VitaVoiceScreenState extends State<VitaVoiceScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0EF),
      body: SafeArea(
        child: Column(
          children: [
            // Tab bar
            Container(
              color: VitaColors.dark,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(Icons.arrow_back, color: Colors.white70, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text('VitaVoice', style: VitaText.display(18, color: Colors.white, weight: FontWeight.w700)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(color: VitaColors.teal.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text('AI BOT', style: VitaText.mono(9, color: VitaColors.lightTeal).copyWith(letterSpacing: 1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _SmsTab(label: 'Pidgin Bot', active: _tab == 0, onTap: () => setState(() => _tab = 0)),
                      const SizedBox(width: 8),
                      _SmsTab(label: 'Emergency Alert', active: _tab == 1, onTap: () => setState(() => _tab = 1)),
                    ],
                  ),
                  const SizedBox(height: 1),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _tab == 0
                    ? const _PidginConversationView(key: ValueKey('pidgin'))
                    : const _EmergencyConversationView(key: ValueKey('emg')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmsTab extends StatelessWidget {
  const _SmsTab({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: VitaText.body(13, color: active ? VitaColors.dark : Colors.white.withValues(alpha: 0.5), weight: active ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }
}

// Model message representation
class _ChatMessage {
  _ChatMessage({required this.text, required this.isOut, required this.time});
  final String text;
  final bool isOut;
  final String time;
}

// ─── PIDGIN BOT CONVERSATION ───
class _PidginConversationView extends StatefulWidget {
  const _PidginConversationView({super.key});

  @override
  State<_PidginConversationView> createState() => _PidginConversationViewState();
}

class _PidginConversationViewState extends State<_PidginConversationView> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "[VITA ASSIST] Welcome to VitaVoice\n\nHow can I help?\n\n1 - Register\n2 - Check pool balance\n3 - Report emergency\n4 - Change language",
      isOut: false,
      time: '10:02 AM',
    ),
  ];

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isOut: true, time: 'Now'));
    });
    _msgController.clear();
    _scrollToBottom();

    Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      String responseText = "";
      if (text == '1') {
        responseText = "[VITA ASSIST] To register new VitaCard, reply with your Full Name, Blood Type and Allergies (e.g. Wali Medugu, A+, None).";
      } else if (text == '2') {
        responseText = "[VITA ASSIST] Your VitaPool balance na ₦48,350 today. Reserved floor na ₦3,000 wey no fit release. Max releasable: ₦45,350.\n\nReply 3 to report emergency.";
      } else if (text == '3') {
        responseText = "[VITA ALERT] Emergency activated! Contacts don receive SMS with your GPS link. Nearest hospital: National Hospital Abuja (1.2km). Calling Fatima now...";
      } else if (text == '4') {
        responseText = "[VITA ASSIST] Reply with your preferred language:\n\nEN - English\nPD - Pidgin\nHA - Hausa\nYR - Yoruba\nIB - Igbo";
      } else {
        responseText = "[VITA ASSIST] Ah, I no understand that one o. Please reply with 1, 2, 3, or 4 make we start.";
      }

      setState(() {
        _messages.add(_ChatMessage(text: responseText, isOut: false, time: 'Now'));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: VitaColors.green),
                alignment: Alignment.center,
                child: Text('V', style: VitaText.display(16, color: Colors.white, weight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('VitaVoice', style: VitaText.body(14, color: VitaColors.dark, weight: FontWeight.w700)),
                  Text('+234 700 VITA 001', style: VitaText.mono(11.5, color: VitaColors.gray)),
                ]),
              ),
            ],
          ),
        ),
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            itemCount: _messages.length,
            itemBuilder: (context, i) {
              final msg = _messages[i];
              return _Bubble(
                text: msg.text,
                isOut: msg.isOut,
                time: msg.time,
              );
            },
          ),
        ),
        // Message input
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgController,
                  decoration: InputDecoration(
                    hintText: 'Type 1, 2, 3, or 4...',
                    hintStyle: VitaText.body(14, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: const Color(0xFFF2F2F0),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: VitaColors.green),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── EMERGENCY ALERT CONVERSATION ───
class _EmergencyConversationView extends StatelessWidget {
  const _EmergencyConversationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: VitaColors.red),
                alignment: Alignment.center,
                child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('VITA Emergency Alert', style: VitaText.body(14, color: VitaColors.dark, weight: FontWeight.w700)),
                  Text('+234 700 VITA 001', style: VitaText.mono(11.5, color: VitaColors.gray)),
                ]),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            children: [
              const _Bubble(
                text: '[VITA EMERGENCY]\n\nFunke Okafor has been found in an emergency near Wuse 2, Abuja by bystander Kabiru Aliyu.\n\nJun 02, 2026 · 14:18 WAT',
                isOut: false,
                time: '2:18 PM',
                bgColor: VitaColors.lightRedBg,
                textColor: VitaColors.red,
              ),
              // Link preview
              GestureDetector(
                onTap: () => context.push('/emergency/receipt'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: VitaColors.lightGreen,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: VitaColors.green.withValues(alpha: 0.25), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('vita.ng/emergency/LINK-K9X-0041-FUNKE', style: VitaText.mono(10.5, color: VitaColors.teal)),
                      const SizedBox(height: 5),
                      Row(children: [
                        const Icon(Icons.lock_outline, size: 14, color: VitaColors.dark),
                        const SizedBox(width: 4),
                        Text('VITA Emergency Portal', style: VitaText.display(13, color: VitaColors.dark, weight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 2),
                      Text('View health profile, GPS & release VitaPool funds', style: VitaText.body(11.5, color: VitaColors.gray)),
                    ],
                  ),
                ),
              ),
              const _Bubble(
                text: 'Tap the secure link to open VITA — no app or password needed. Release funds to the bystander\'s OPay wallet directly.',
                isOut: false,
                time: '2:18 PM',
              ),
              const _Bubble(text: 'Opened the link, releasing ₦8,000 now 🙏', isOut: true, time: '2:22 PM'),
              const _Bubble(
                text: '[SUCCESS] ₦8,000 released to Kabiru Aliyu (OPY-2026-EMG-904401). Pool updated. All 18 members notified.',
                isOut: false,
                time: '2:23 PM',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── BUBBLE ───
class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.isOut, required this.time, this.bgColor, this.textColor});
  final String text;
  final bool isOut;
  final String time;
  final Color? bgColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final bg = bgColor ?? (isOut ? VitaColors.green : Colors.white);
    final fg = textColor ?? (isOut ? Colors.white : VitaColors.dark);
    const radius = Radius.circular(18);
    const smallRadius = Radius.circular(4);

    return Align(
      alignment: isOut ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment: isOut ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.only(
                  topLeft: radius,
                  topRight: radius,
                  bottomLeft: isOut ? radius : smallRadius,
                  bottomRight: isOut ? smallRadius : radius,
                ),
              ),
              child: Text(text, style: VitaText.body(13.5, color: fg).copyWith(height: 1.55)),
            ),
            const SizedBox(height: 3),
            Text(time, style: VitaText.body(10, color: VitaColors.gray)),
          ],
        ),
      ),
    );
  }
}
