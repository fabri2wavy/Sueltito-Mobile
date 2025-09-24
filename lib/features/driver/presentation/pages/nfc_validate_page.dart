import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../../application/balance_controller.dart';
import '../../application/history_controller.dart';
import '../../domain/models.dart';

class NfcValidatePage extends ConsumerStatefulWidget {
  const NfcValidatePage({super.key});
  @override
  ConsumerState<NfcValidatePage> createState() => _NfcValidatePageState();
}

class _NfcValidatePageState extends ConsumerState<NfcValidatePage> {
  bool _scanning = false;
  String? _status;

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  Future<void> _start() async {
    final ok = await NfcManager.instance.isAvailable();
    if (!ok) { setState(() => _status = 'NFC no disponible'); return; }

    setState(() { _scanning = true; _status = 'Acerque tarjeta del pasajero…'; });

    NfcManager.instance.startSession(onDiscovered: (tag) async {
      try {
        final passengerId = _extractId(tag) ?? 'PAS-${DateFormat('HHmmss').format(DateTime.now())}';

        // TODO: aquí conecta con tu backend para cobrar de verdad.
        // DEMO local:
        final result = PaymentResult.success(
          mode: ScanMode.nfc,
          passengerId: passengerId,
          amount: 3.00,
          timestamp: DateTime.now(),
          description: 'Pasaje',
        );

        ref.read(historyProvider.notifier).add(Trip(
          description: result.description,
          passengerId: result.passengerId,
          amount: result.amount,
          timestamp: result.timestamp,
        ));
        ref.read(balanceProvider.notifier).add(result.amount);

        await NfcManager.instance.stopSession();
        if (!mounted) return;
        context.go('/driver/success', extra: result);
      } catch (e) {
        await NfcManager.instance.stopSession(errorMessage: 'Error: $e');
        if (!mounted) return;
        context.go('/driver/fail', extra: PaymentResult.failure(
          mode: ScanMode.nfc,
          passengerId: '—',
          timestamp: DateTime.now(),
          failure: FailureCode.invalidCard,
        ));
      } finally {
        if (mounted) setState(() => _scanning = false);
      }
    });
  }

  String? _extractId(NfcTag tag) {
    Map<String, dynamic>? m; List<int>? bytes;
    m = tag.data['nfca'] as Map<String, dynamic>?; bytes = (m?['identifier'] as List?)?.cast<int>();
    m = tag.data['mifareclassic'] as Map<String, dynamic>?; bytes ??= (m?['identifier'] as List?)?.cast<int>();
    m = tag.data['ndef'] as Map<String, dynamic>?; bytes ??= (m?['identifier'] as List?)?.cast<int>();
    if (bytes != null) return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
    final iso = tag.data['iso7816'] as Map<String, dynamic>?;
    if (iso != null && iso['identifier'] is String) return iso['identifier'] as String;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validar viaje (NFC)')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (_scanning) const CircularProgressIndicator(),
          if (_status != null) Padding(padding: const EdgeInsets.all(12), child: Text(_status!)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _scanning ? null : _start,
            icon: const Icon(Icons.nfc),
            label: const Text('Escanear ahora'),
          ),
        ]),
      ),
    );
  }
}
