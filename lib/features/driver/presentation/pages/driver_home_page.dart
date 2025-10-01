import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../auth/application/driver_profile_controller.dart';
import '../../application/balance_controller.dart';
import '../widgets/greeting_header.dart';
import '../widgets/balance_card.dart';

//nombre del conductor desde FirebaseAuth
final driverNameProvider = Provider<String>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  final name = user?.displayName?.trim();
  return (name != null && name.isNotEmpty) ? name : 'Conductor';
});

class DriverHomePage extends ConsumerWidget {
  const DriverHomePage({super.key});

  static const _violetaRuso = Color(0xFF280033);
  static const _verdeBlack = Color(0xFF199d89);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(driverProfileProvider);
    final balance = ref.watch(balanceProvider);
    final name = ref.watch(driverNameProvider); // 👈 aquí
    final money = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs. ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Inicio',
          style: TextStyle(color: _violetaRuso, fontWeight: FontWeight.w800),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GreetingHeader(name: name), // 👈 ya no hardcodeado
              const SizedBox(height: 16),
              BalanceCard(label: 'Saldo disponible', amount: money.format(balance)),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  // TODO: flujo de retiro
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _verdeBlack,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retirar dinero'),
              ),
              const SizedBox(height: 12),

              // Usa push para que el back vuelva a Home
              ElevatedButton(
                onPressed: () => context.push('/driver/history'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _violetaRuso,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: _violetaRuso),
                ),
                child: const Text('Ver historial de cobros'),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () {
                  // TODO: configuración
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _violetaRuso,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: _violetaRuso),
                ),
                child: const Text('Configuración'),
              ),

              const Spacer(),

              OutlinedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) context.go('/auth/login');
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.large(
        backgroundColor: _violetaRuso,
        foregroundColor: Colors.white,
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
