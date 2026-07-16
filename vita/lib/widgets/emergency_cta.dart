import 'package:flutter/material.dart';
import 'package:vita/theme/app_theme.dart';

// ─── EMERGENCY CTA BUTTON ─────────────────────────────────────────────────────
class EmergencyCTA extends StatefulWidget {
  const EmergencyCTA({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  State<EmergencyCTA> createState() => _EmergencyCTAState();
}

class _EmergencyCTAState extends State<EmergencyCTA>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _pulseAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: VitaColors.red,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: VitaColors.red.withValues(alpha: 0.35),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Pulse overlay
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, _) => Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.06 * _pulseAnim.value,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'EMERGENCY',
                            style: VitaText.display(20,
                              color: Colors.white,
                              weight: FontWeight.w700,
                            ).copyWith(letterSpacing: -0.5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Activate VitaPool now',
                          style: VitaText.body(11.5,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.2),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
