import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterNfcPage extends StatefulWidget {
  const RegisterNfcPage({super.key});

  @override
  State<RegisterNfcPage> createState() => _RegisterNfcPageState();
}

class _RegisterNfcPageState extends State<RegisterNfcPage> {
  static const _violetaRuso = Color(0xFF280033);
  static const _verdeBlack  = Color(0xFF199d89);

  bool _scanning = false;
  bool _completed = false;
  String _status = 'Toca “Escanear NFC” y acerca TU tarjeta/sticker';
  String? _nfcId;
  String? _lastTagDump;
  Timer? _timeout;

  @override
  void dispose() {
    _timeout?.cancel();
    NfcManager.instance.stopSession();
    super.dispose();
  }

  Future<void> _startScan() async {
    final available = await NfcManager.instance.isAvailable();
    if (!available) {
      setState(() => _status = 'NFC no disponible en este dispositivo');
      return;
    }

    setState(() {
      _scanning = true;
      _completed = false;
      _status = 'Acerca TU tarjeta/sticker para registrar…';
      _nfcId = null;
      _lastTagDump = null;
    });

    // Timeout de seguridad (10s). Lo cancelamos cuando ya tengamos UID.
    _timeout?.cancel();
    _timeout = Timer(const Duration(seconds: 10), () {
      if (!mounted || _completed) return;
      NfcManager.instance.stopSession();
      setState(() {
        _scanning = false;
        _status = 'Tiempo agotado. Intenta nuevamente.';
      });
    });

    NfcManager.instance.startSession(onDiscovered: (tag) async {
      try {
        debugPrint('🔎 REGISTER TAG DATA: ${tag.data}');
        _lastTagDump = tag.data.toString();

        final id = _extractId(tag);
        if (id == null || id.isEmpty) {
          throw 'No se pudo leer un identificador del tag (NDEF vacío)';
        }

        // ✅ Cancelamos el timeout en cuanto tenemos el UID
        _completed = true;
        _timeout?.cancel();

        setState(() {
          _nfcId = id;
          _status = 'Leído: $id\nGuardando…';
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw 'Sesión inválida (no hay usuario)';

        // Guardado con timeout corto: si tarda/falla, seguimos igual (no bloqueamos la UI)
        try {
          await FirebaseFirestore.instance
              .collection('drivers')
              .doc(user.uid)
              .set({
                'nfcId': id,
                'displayName': user.displayName ?? 'Conductor',
                'phone': user.phoneNumber,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true))
              .timeout(const Duration(seconds: 3));
        } on TimeoutException {
          debugPrint('⏳ Firestore set >3s. Continuamos y dejamos que sincronice luego.');
        } on FirebaseException catch (e, st) {
          debugPrint('❌ FirebaseException al guardar: ${e.code} ${e.message}\n$st');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No se pudo guardar ahora (${e.code}). Se intentará luego.')),
            );
          }
        } catch (e, st) {
          debugPrint('❌ Error inesperado al guardar: $e\n$st');
        }

        await NfcManager.instance.stopSession();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('NFC registrado: $id')),
        );
        context.go('/driver');
      } catch (e, st) {
        debugPrint('❌ Error en onDiscovered: $e\n$st');
        _timeout?.cancel();
        await NfcManager.instance.stopSession(errorMessage: 'Error: $e');
        if (!mounted) return;
        setState(() {
          _scanning = false;
          _status = 'Error: $e';
        });
      } finally {
        if (mounted) setState(() => _scanning = false);
      }
    });
  }

  /// Extrae un UID en HEX (soporta nfca/mifareclassic/ndef/iso7816).
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

    return null; // no pudimos extraer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Registrar mi NFC'),
        backgroundColor: Colors.white,
        foregroundColor: _violetaRuso,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (_scanning) const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (_nfcId != null) ...[
              const SizedBox(height: 12),
              Text('ID: $_nfcId', style: const TextStyle(color: Colors.black54)),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _scanning ? null : _startScan,
              icon: const Icon(Icons.nfc),
              label: const Text('Escanear NFC'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _verdeBlack,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_lastTagDump != null) ...[
              const SizedBox(height: 16),
              Text(
                'Debug tag:\n$_lastTagDump',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ]
          ]),
        ),
      ),
    );
  }
}
