import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/history_controller.dart';
import '../widgets/history_item.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(historyProvider);
    final df = DateFormat('dd MMM yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: Column(
        children: [
      Expanded(
        child: items.isEmpty
            ? const Center(child: Text('Sin registros aún'))
            : ListView.builder(
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
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Volver al inicio'),
        ),
      ),
    ],
      ),
    );
  }
}
