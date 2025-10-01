import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../application/history_controller.dart';
import '../../application/balance_controller.dart';
import '../../domain/models.dart';

class NfcValidatePage extends ConsumerStatefulWidget {
  const NfcValidatePage({super.key});

  @override
  ConsumerState<NfcValidatePage> createState() => _NfcValidatePageState();
}

class _NfcValidatePageState extends ConsumerState<NfcValidatePage> {
  static const _violetaRuso = Color(0xFF280033);
  static const _verdeBlack  = Color(0xFF199d89);

  bool _scanning = false;
  String _status = 'Acerque la tarjeta NFC del pasajero…';

  @override
  void initState() {
    super.initState();
    _startValidation();
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  Future<void> _startValidation() async {
    final available = await NfcManager.instance.isAvailable();
    if (!available) {
      setState(() => _status = 'NFC no disponible en este dispositivo');
      return;
    }

    setState(() {
      _scanning = true;
      _status = 'Acerque la tarjeta NFC del pasajero…';
    });

    NfcManager.instance.startSession(onDiscovered: (tag) async {
      try {
        debugPrint('🔎 VALIDATE TAG DATA: ${tag.data}');
        final readId = _extractId(tag);
        if (readId == null || readId.isEmpty) {
          throw 'Tag sin ID legible (NDEF vacío sin UID expuesto)';
        }

        // Chequear que el conductor tenga NFC registrado (opcional aquí)
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) throw 'Sesión no válida (uid nulo)';
        final snap = await FirebaseFirestore.instance
            .collection('drivers')
            .doc(uid)
            .get();
        final registeredId = snap.data()?['nfcId'] as String?;
        if (registeredId == null || registeredId.isEmpty) {
          throw 'El conductor no tiene NFC registrado';
        }

        // DEMO: consideramos cobro exitoso siempre (monto fijo).
        final now = DateTime.now();
        final result = PaymentResult.success(
          mode: ScanMode.nfc,
          passengerId: readId,
          amount: 3.50,
          timestamp: now,
          description: 'Pasaje',
        );

        // Actualiza estado local (historial + saldo)
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

        final result = PaymentResult.failure(
          mode: ScanMode.nfc,
          passengerId: '—',
          timestamp: DateTime.now(),
          failure: FailureCode.invalidCard,
        );

        if (!mounted) return;
        context.go('/driver/fail', extra: result);
      } finally {
        if (mounted) setState(() => _scanning = false);
      }
    });
  }

  String? _extractId(NfcTag tag) {
    final root = tag.data as Map; // Map<dynamic, dynamic>
    List<int>? bytes;

    final nfca = root['nfca'] as Map?;
    final nfcaId = nfca?['identifier'];
    if (nfcaId is List) bytes = nfcaId.cast<int>();

    final mfc = root['mifareclassic'] as Map?;
    final mfcId = mfc?['identifier'];
    if (bytes == null && mfcId is List) bytes = mfcId.cast<int>();

    final ndef = root['ndef'] as Map?;
    final ndefId = ndef?['identifier'];
    if (bytes == null && ndefId is List) bytes = ndefId.cast<int>();

    if (bytes != null) {
      return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
    }

    final iso = root['iso7816'] as Map?;
    final isoId = iso?['identifier'];
    if (isoId is String && isoId.isNotEmpty) return isoId;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Validar NFC'),
        backgroundColor: Colors.white,
        foregroundColor: _violetaRuso,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_scanning) const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _scanning ? null : _startValidation,
                icon: const Icon(Icons.nfc),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _verdeBlack,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
