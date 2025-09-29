import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'verify_sms_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get _valid => _formKey.currentState?.validate() ?? false;

  // Normaliza a E.164 para Bolivia por defecto
  String _formatBoliviaE164(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('591')) return '+$digits'; // 591XXXXXXXX
    if (digits.length == 8) return '+591$digits'; // 8 dígitos
    if (digits.startsWith('0') && digits.length == 9) {
      // 0XXXXXXXX
      return '+591${digits.substring(1)}';
    }
    return '+$digits'; // fallback si ya viene con prefijo
  }

  Future<void> _startPhoneVerification() async {
    if (!_valid || _sending) return;
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);

    final phoneE164 = _formatBoliviaE164(_phoneCtrl.text.trim());
    final auth = FirebaseAuth.instance;

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneE164,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          // Opcional: login automático cuando Play Services autovalida
          // await auth.signInWithCredential(credential);
          // if (mounted) Navigator.pushReplacementNamed(context, '/home');
        },
        verificationFailed: (e) {
          final msg = switch (e.code) {
            'invalid-phone-number' => 'Número inválido',
            'too-many-requests' => 'Demasiados intentos. Intenta más tarde.',
            'quota-exceeded' => 'Cuota de SMS agotada temporalmente.',
            _ => 'Error: ${e.message}',
          };
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        },
        codeSent: (verificationId, resendToken) {
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => VerifySmsPage(
                    phoneLabel: phoneE164,
                    verificationId:
                        verificationId, // necesario para validar el PIN
                    forceResendToken: resendToken, // opcional (para reenviar)
                  ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo iniciar la verificación')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // Mantiene tu firma original, ahora invoca la verificación
  void _goToVerify(String role) {
    if (!_valid) return;
    _startPhoneVerification();
  }

  @override
  Widget build(BuildContext context) {
    const violetaRuso = Color(0xFF280033);
    const Color verdeAzulado = Color(0xFF199D89);
    const gris = Color(0xFFD9D9D9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton.filledTonal(
                    onPressed: () => Navigator.pop(context),
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(
                        gris.withValues(alpha: 0.25),
                      ),
                      foregroundColor: const WidgetStatePropertyAll<Color>(
                        violetaRuso,
                      ),
                      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Hola! Registrate para\npoder comenzar',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: verdeAzulado,
                  ),
                ),
                const SizedBox(height: 28),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _userCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Usuario',
                          hintStyle: const TextStyle(color: Colors.black26),
                          filled: true,
                          fillColor: const Color(0xFFF3F5F6),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: verdeAzulado,
                              width: 2,
                            ),
                          ),
                        ),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Ingresa tu usuario'
                                    : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Numero de celular (+591)',
                          hintStyle: const TextStyle(color: Colors.black26),
                          filled: true,
                          fillColor: const Color(0xFFF3F5F6),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: verdeAzulado,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty) return 'Ingresa tu celular';
                          final digits = t.replaceAll(RegExp(r'\D'), '');
                          if (digits.length < 8) return 'Celular inválido';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _sending ? null : () => _goToVerify('usuario'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verdeAzulado,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    child:
                        _sending
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Registrate como usuario'),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _sending ? null : () => _goToVerify('conductor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verdeAzulado,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    child:
                        _sending
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Registrate como conductor'),
                  ),
                ),

                const SizedBox(height: 28),

                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      const Text(
                        'Ya formas parte de Sueltito? ',
                        style: TextStyle(
                          color: Color(0xFF199D89),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Inicia sesion',
                          style: TextStyle(
                            color: violetaRuso,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
