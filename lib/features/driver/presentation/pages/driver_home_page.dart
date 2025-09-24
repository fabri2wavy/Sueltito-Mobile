import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../auth/application/driver_profile_controller.dart';
import '../../application/balance_controller.dart';
import '../widgets/greeting_header.dart';
import '../widgets/balance_card.dart';

class DriverHomePage extends ConsumerWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(driverProfileProvider);
    final balance = ref.watch(balanceProvider);
    final money = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs. ', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const GreetingHeader(name: 'Mauricio'),
          const SizedBox(height: 16),
          BalanceCard(label: 'Saldo disponible', amount: money.format(balance)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {}, // Retirar dinero (próximo paso)
            style: ElevatedButton.styleFrom(shape: const StadiumBorder(), minimumSize: const Size.fromHeight(48)),
            child: const Text('Retirar dinero'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.go('/driver/history'),
            style: ElevatedButton.styleFrom(shape: const StadiumBorder(), minimumSize: const Size.fromHeight(48)),
            child: const Text('Ver historial de cobros'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {}, // Config (próximo)
            style: ElevatedButton.styleFrom(shape: const StadiumBorder(), minimumSize: const Size.fromHeight(48)),
            child: const Text('Configuración'),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: () => context.go('/auth/login'),
            style: OutlinedButton.styleFrom(shape: const StadiumBorder(), minimumSize: const Size.fromHeight(48)),
            child: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          if (!profile.isRegistered) {
            context.go('/driver/register-nfc');
          } else {
            context.go('/driver/validate/nfc');
          }
        },
        child: const Icon(Icons.nfc),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
