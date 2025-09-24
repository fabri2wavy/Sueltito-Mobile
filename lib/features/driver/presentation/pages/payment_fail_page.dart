import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/models.dart';

class PaymentFailPage extends StatelessWidget {
  final PaymentResult? result;
  const PaymentFailPage({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    final r = result; final df = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 80),
          const Center(child: Text('¡Cobro Fallido!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red))),
          const SizedBox(height: 24),
          Text('Intento: ${r != null ? df.format(r.timestamp) : "—"}'),
          const Spacer(),
          ElevatedButton(onPressed: () => context.go('/driver/validate/nfc'), child: const Text('Reintentar')),
        ]),
      ),
    );
  }
}
