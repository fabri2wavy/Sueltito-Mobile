import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/application/driver_profile_controller.dart';

class RegisterNfcPage extends ConsumerStatefulWidget {
  const RegisterNfcPage({super.key});
  @override
  ConsumerState<RegisterNfcPage> createState() => _RegisterNfcPageState();
}

class _RegisterNfcPageState extends ConsumerState<RegisterNfcPage> {
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

    setState(() { _scanning = true; _status = 'Acerque SU tarjeta para registrar…'; });

    NfcManager.instance.startSession(onDiscovered: (tag) async {
      try {
        final id = _extractId(tag);
        if (id == null) throw 'No se pudo leer un identificador';
        await ref.read(driverProfileProvider.notifier).registerNfc(id);
        await NfcManager.instance.stopSession();
        if (!mounted) return;
        context.go('/driver');
      } catch (e) {
        await NfcManager.instance.stopSession(errorMessage: 'Error: $e');
        if (mounted) setState(() { _scanning = false; _status = 'Error: $e'; });
      }
    });
  }

  String? _extractId(NfcTag tag) {
    Map<String, dynamic>? m;
    List<int>? bytes;
    m = tag.data['nfca'] as Map<String, dynamic>?; bytes = (m?['identifier'] as List?)?.cast<int>();
    m = tag.data['mifareclassic'] as Map<String, dynamic>?; bytes ??= (m?['identifier'] as List?)?.cast<int>();
    m = tag.data['ndef'] as Map<String, dynamic>?; bytes ??= (m?['identifier'] as List?)?.cast<int>();
    if (bytes != null) {
      return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
    }
    final iso = tag.data['iso7816'] as Map<String, dynamic>?;
    if (iso != null && iso['identifier'] is String) return iso['identifier'] as String;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar mi NFC')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (_scanning) const CircularProgressIndicator(),
          if (_status != null) Padding(padding: const EdgeInsets.all(12), child: Text(_status!)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _scanning ? null : _start,
            icon: const Icon(Icons.nfc),
            label: const Text('Registrar ahora'),
          ),
        ]),
      ),
    );
  }
}
