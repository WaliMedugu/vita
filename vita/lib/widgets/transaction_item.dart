import 'package:flutter/material.dart';
import 'package:vita/theme/app_theme.dart';

// ─── TRANSACTION ITEM ─────────────────────────────────────────────────────────
class TransactionItem extends StatelessWidget {
  const TransactionItem({
    super.key,
    required this.initials,
    required this.name,
    required this.ref,
    required this.amount,
    required this.time,
    this.amountColor,
    this.avatarBg,
    this.avatarFg,
  });

  final String initials;
  final String name;
  final String ref;
  final String amount;
  final String time;
  final Color? amountColor;
  final Color? avatarBg;
  final Color? avatarFg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarBg ?? VitaColors.lightGreen,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: VitaText.body(13,
                color: avatarFg ?? VitaColors.green,
                weight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + ref
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: VitaText.body(13.5, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  ref,
                  style: VitaText.mono(10.5, color: VitaColors.gray),
                ),
              ],
            ),
          ),
          // Amount + time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: VitaText.display(15,
                  color: amountColor ?? VitaColors.teal,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: VitaText.mono(10.5, color: VitaColors.gray),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── DIVIDER VERSION ──────────────────────────────────────────────────────────
class TransactionList extends StatelessWidget {
  const TransactionList({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1)
            const Divider(height: 1, color: Color(0x0D000000)),
        ],
      ],
    );
  }
}
