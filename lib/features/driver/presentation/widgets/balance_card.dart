import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final String label;
  final String amount;
  const BalanceCard({super.key, required this.label, required this.amount});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFFECE0FF),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(amount, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0F766E))),
        ]),
      ),
    );
  }
}
