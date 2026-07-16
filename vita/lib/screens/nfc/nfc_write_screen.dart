import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';
import 'package:vita/widgets/nfc_ring_animation.dart';

class NFCWriteScreen extends StatefulWidget {
  const NFCWriteScreen({super.key});

  @override
  State<NFCWriteScreen> createState() => _NFCWriteScreenState();
}

class _NFCWriteScreenState extends State<NFCWriteScreen> {
  bool _written = false;
  bool _writing = false;
  double _progress = 0;

  void _simulateWrite() async {
    setState(() { _writing = true; _progress = 0; });
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() => _progress = i / 10);
    }
    setState(() { _writing = false; _written = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaColors.dark,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: BackgroundRings()),
            Column(
              children: [
                _buildHeader(context),
                if (_writing)
                  _buildWriting()
                else if (_written)
                  _buildSuccess(context)
                else
                  _buildReady(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.07)),
            child: Icon(Icons.arrow_back, color: Colors.white.withValues(alpha: 0.6), size: 18),
          ),
        ),
        const SizedBox(width: 12),
        Text('Write VitaCard', style: VitaText.display(17, color: Colors.white, weight: FontWeight.w700)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: VitaColors.teal.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
          child: Text('ANDROID · NFC', style: VitaText.mono(9, color: VitaColors.lightTeal).copyWith(letterSpacing: 1)),
        ),
      ],
    ),
  );

  Widget _buildReady(BuildContext context) => Expanded(
    child: Column(
      children: [
        const Spacer(),
        NFCRingAnimation(icon: Icons.nfc_rounded, iconSize: 48),
        const SizedBox(height: 28),
        Text('Tap your VitaCard', style: VitaText.display(28, color: Colors.white, weight: FontWeight.w700).copyWith(letterSpacing: -0.8), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(
          'Hold the NFC sticker to the top of your\nphone to encode your health profile',
          style: VitaText.body(13.5, color: Colors.white.withValues(alpha: 0.45)).copyWith(height: 1.6),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _dataPanel(),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _simulateWrite,
                  style: ElevatedButton.styleFrom(backgroundColor: VitaColors.teal),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Confirm & Write', style: VitaText.display(16, color: Colors.white, weight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Ensure NFC is enabled on your device', style: VitaText.mono(11, color: Colors.white.withValues(alpha: 0.25))),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildWriting() => Expanded(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 48, height: 48,
          child: CircularProgressIndicator(
            value: _progress,
            strokeWidth: 4,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation(VitaColors.teal),
          ),
        ),
        const SizedBox(height: 24),
        Text('Writing to Card…', style: VitaText.display(28, color: Colors.white, weight: FontWeight.w700).copyWith(letterSpacing: -0.8), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text('Keep your phone near the VitaCard sticker.\nDon\'t move it.', style: VitaText.body(13.5, color: Colors.white.withValues(alpha: 0.45)).copyWith(height: 1.6), textAlign: TextAlign.center),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(VitaColors.teal),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('${(_progress * 100).round()}% · ${(_progress * 248).round()} bytes written', style: VitaText.mono(11, color: Colors.white.withValues(alpha: 0.3))),
      ],
    ),
  );

  Widget _buildSuccess(BuildContext context) => Expanded(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      child: Column(
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: VitaColors.teal.withValues(alpha: 0.15),
              border: Border.all(color: VitaColors.teal, width: 2),
            ),
            child: const Icon(Icons.check_circle_outline_rounded, size: 52, color: VitaColors.teal),
          ),
          const SizedBox(height: 24),
          Text('Card Written!', style: VitaText.display(28, color: Colors.white, weight: FontWeight.w700).copyWith(letterSpacing: -0.8), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text('Your medical profile is now encoded. Anyone with VITA can tap to access it offline in an emergency.', style: VitaText.body(13.5, color: Colors.white.withValues(alpha: 0.45)).copyWith(height: 1.6), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                _ndRow('status', '● success', color: VitaColors.lightTeal),
                _ndRow('bytes', '248 / 144'),
                _ndRow('format', 'NTAG213 · NDEF', last: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(backgroundColor: VitaColors.teal),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Done', style: VitaText.display(16, color: Colors.white, weight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _dataPanel() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          _ndRow('name', 'Wali Medugu'),
          _ndRow('blood', 'O+', color: VitaColors.lightRed),
          _ndRow('allergies', 'Penicillin, Peanuts'),
          _ndRow('pool_id', 'POOL-KAN-0041', color: VitaColors.lightTeal),
          _ndRow('contact_1', '+234 800 123 4567', last: true),
        ],
      ),
    ),
  );

  Widget _ndRow(String key, String value, {Color? color, bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: last ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF)))),
      child: Row(
        children: [
          Text(key, style: VitaText.mono(10.5, color: Colors.white.withValues(alpha: 0.35)).copyWith(letterSpacing: 0.8)),
          const Spacer(),
          Text(value, style: VitaText.body(12.5, color: color ?? Colors.white, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}
