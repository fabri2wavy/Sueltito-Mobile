import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';

class VerifySmsPage extends StatefulWidget {
  const VerifySmsPage({
    super.key,
    this.phoneLabel,
    required this.verificationId,
    this.forceResendToken,
  });

  final String? phoneLabel;
  final String verificationId;
  final int? forceResendToken;

  @override
  State<VerifySmsPage> createState() => _VerifySmsPageState();
}

class _VerifySmsPageState extends State<VerifySmsPage> {
  static const violetaRuso = Color(0xFF280033);
  static const verdeNeon = Color(0xFF33FF00);
  static const gris = Color(0xFFD9D9D9);

  final _pinController = TextEditingController();
  bool _sending = false;

  Future<void> _verify() async {
    final code = _pinController.text.trim();
    if (code.length != 6) return;
    setState(() => _sending = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'invalid-verification-code' => 'Código incorrecto',
        'session-expired' => 'El código expiró, solicita uno nuevo',
        _ => 'Error: ${e.message}',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: verdeNeon,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: gris),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: violetaRuso),
              ),
              const SizedBox(height: 12),
              const Text(
                'Verificación SMS',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: verdeNeon,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.phoneLabel == null
                    ? 'Ingresa el código de 6 dígitos que enviamos'
                    : 'Enviamos un código a ${widget.phoneLabel}',
                style: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 24),

              Center(
                child: Pinput(
                  length: 6,
                  controller: _pinController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: verdeNeon, width: 2),
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme,
                  onCompleted: (_) => _verify(),
                ),
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _sending ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verdeNeon,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _sending
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Verificar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
