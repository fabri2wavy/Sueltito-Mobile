import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../application/history_controller.dart';
import '../widgets/history_item.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  static const _violetaRuso = Color(0xFF280033);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(historyProvider);
    final df = DateFormat('dd MMM yyyy HH:mm');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _violetaRuso),
          onPressed: () => context.pop(), // 🔙 vuelve al Home
        ),
        title: const Text(
          'Historial',
          style: TextStyle(
            color: _violetaRuso,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'Sin registros aún',
                style: TextStyle(color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final t = items[i];
                return HistoryItem(
                  date: df.format(t.timestamp),
                  description: t.description,
                  passengerId: t.passengerId,
                  amount: 'Bs. ${t.amount.toStringAsFixed(2)}',
                );
              },
            ),
    );
  }
}
