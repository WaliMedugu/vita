import 'package:flutter/material.dart';
import 'package:vita/theme/app_theme.dart';

// ─── POOL CARD ────────────────────────────────────────────────────────────────
class PoolCardWidget extends StatelessWidget {
  const PoolCardWidget({
    super.key,
    required this.poolName,
    required this.amount,
    required this.mode,
    this.floorAmount = '₦3k floor',
    this.cardColor,
  });

  final String poolName;
  final String amount;
  final PoolMode mode;
  final String floorAmount;
  final Color? cardColor;

  @override
  Widget build(BuildContext context) {
    final bg = cardColor ?? VitaColors.green;
    final isPassive = mode == PoolMode.passive;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background circles
          Positioned(
            top: -80, right: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -30, left: 20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  poolName.toUpperCase(),
                  style: VitaText.mono(10,
                    color: Colors.white.withValues(alpha: 0.5),
                    weight: FontWeight.w500,
                  ).copyWith(letterSpacing: 1.5),
                ),
                const SizedBox(height: 6),
                Text(
                  amount,
                  style: VitaText.display(44,
                    color: Colors.white,
                  ).copyWith(letterSpacing: -2, height: 1),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ModePill(isPassive: isPassive),
                    const SizedBox(width: 8),
                    _FloorBadge(label: floorAmount),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum PoolMode { passive, scheduled }

class _ModePill extends StatelessWidget {
  const _ModePill({required this.isPassive});
  final bool isPassive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPassive
            ? Colors.white.withValues(alpha: 0.12)
            : const Color(0xFFD4A017).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPassive
                  ? const Color(0xFF6FFFC2)
                  : const Color(0xFFD4A017),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isPassive ? 'Passive' : 'Scheduled',
            style: VitaText.body(11.5,
              color: Colors.white,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloorBadge extends StatelessWidget {
  const _FloorBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, size: 10, color: Colors.white.withValues(alpha: 0.55)),
          const SizedBox(width: 4),
          Text(
            label,
            style: VitaText.mono(10.5,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
