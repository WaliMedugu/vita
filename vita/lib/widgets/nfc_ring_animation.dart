import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vita/theme/app_theme.dart';

// ─── NFC RING ANIMATION ───────────────────────────────────────────────────────
class NFCRingAnimation extends StatefulWidget {
  const NFCRingAnimation({
    super.key,
    required this.icon,
    this.iconSize = 48,
  });

  final IconData icon;
  final double iconSize;

  @override
  State<NFCRingAnimation> createState() => _NFCRingAnimationState();
}

class _NFCRingAnimationState extends State<NFCRingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late AnimationController _orbitCtrl;
  late Animation<double> _bounceAnim;
  late Animation<double> _orbitAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _orbitAnim = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      _orbitCtrl,
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _orbitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer dashed ring
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: VitaColors.teal.withValues(alpha: 0.08),
              border: Border.all(
                color: VitaColors.teal.withValues(alpha: 0.3),
                width: 1.5,
                // Note: actual dashes need CustomPainter; using solid for now
              ),
            ),
          ),
          // Orbiting ring
          AnimatedBuilder(
            animation: _orbitAnim,
            builder: (_, __) => Transform.rotate(
              angle: _orbitAnim.value,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: VitaColors.teal.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          // Inner circle + bouncing icon
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: VitaColors.teal.withValues(alpha: 0.12),
            ),
            child: ScaleTransition(
              scale: _bounceAnim,
              child: Icon(
                widget.icon,
                size: widget.iconSize,
                color: VitaColors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BACKGROUND RINGS ────────────────────────────────────────────────────────
class BackgroundRings extends StatelessWidget {
  const BackgroundRings({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _ring(320, 1.0),
            _ring(240, 0.5),
            _ring(160, 0.3),
          ],
        ),
      ),
    );
  }

  Widget _ring(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: VitaColors.teal.withValues(alpha: 0.12 * opacity),
          ),
        ),
      );
}
