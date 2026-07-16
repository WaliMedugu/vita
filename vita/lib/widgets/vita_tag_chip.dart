import 'package:flutter/material.dart';
import 'package:vita/theme/app_theme.dart';

// ─── VITA TAG CHIP ────────────────────────────────────────────────────────────
class VitaTagChip extends StatelessWidget {
  const VitaTagChip({
    super.key,
    required this.label,
    this.isDanger = false,
    this.onRemove,
    this.icon,
  });

  final String label;
  final bool isDanger;
  final VoidCallback? onRemove;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bg = isDanger ? VitaColors.lightRedBg : VitaColors.lightGreen;
    final fg = isDanger ? VitaColors.red : VitaColors.green;
    final border = isDanger
        ? VitaColors.red.withValues(alpha: 0.2)
        : VitaColors.green.withValues(alpha: 0.2);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: onRemove != null ? 10 : 12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDanger && icon == null) ...[
            Icon(Icons.warning_amber_rounded, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: VitaText.body(12, color: fg, weight: FontWeight.w600),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, size: 14, color: fg),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── PILL (mono tag) ──────────────────────────────────────────────────────────
class VitaPill extends StatelessWidget {
  const VitaPill({
    super.key,
    required this.label,
    this.bg,
    this.fg,
  });

  final String label;
  final Color? bg;
  final Color? fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? VitaColors.lightGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: VitaText.mono(10,
          color: fg ?? VitaColors.green,
          weight: FontWeight.w500,
        ),
      ),
    );
  }
}
