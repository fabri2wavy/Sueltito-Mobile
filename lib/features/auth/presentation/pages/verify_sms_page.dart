import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifySmsPage extends StatefulWidget {
  const VerifySmsPage({super.key, this.phoneLabel});
  final String? phoneLabel;

  @override
  State<VerifySmsPage> createState() => _VerifySmsPageState();
}

class _VerifySmsPageState extends State<VerifySmsPage> {
  static const violetaRuso = Color(0xFF280033);
  static const verdeNeon = Color(0xFF33FF00);
  static const gris = Color(0xFFD9D9D9);

  final int _len = 6;
  late final List<TextEditingController> _ctrls;
  late final List<FocusNode> _nodes;

  bool _sending = false;
  int _resendSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(_len, (_) => TextEditingController());
    _nodes = List.generate(_len, (_) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _nodes.first.requestFocus(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final f in _nodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _ctrls.map((c) => c.text).join();
  bool get _complete => _code.length == _len && !_code.contains(RegExp(r'\D'));

  void _onChanged(String v, int i) {
    if (v.length == 1 && i < _len - 1) {
      _nodes[i + 1].requestFocus();
    } else if (v.isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _verify() async {
    if (!_complete || _sending) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _sending = false);
  }

  void _startResendCooldown([int seconds = 30]) {
    _timer?.cancel();
    setState(() => _resendSeconds = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds <= 1) {
        t.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds -= 1);
      }
    });
  }

  Future<void> _resend() async {
    if (_resendSeconds > 0) return;
    _startResendCooldown(30);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Código reenviado')));
  }

  InputDecoration _pinDecoration() {
    return InputDecoration(
      counterText: '',
      filled: true,
      fillColor: const Color(0xFFF3F5F6),
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: gris),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: verdeNeon, width: 2),
      ),
    );
  }

  Widget _pinBox(int i, double box, double font) {
    return SizedBox(
      width: box,
      child: TextField(
        controller: _ctrls[i],
        focusNode: _nodes[i],
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textInputAction:
            i == _len - 1 ? TextInputAction.done : TextInputAction.next,
        onChanged: (v) => _onChanged(v, i),
        decoration: _pinDecoration(),
        style: TextStyle(
          fontSize: font,
          fontWeight: FontWeight.w700,
          color: verdeNeon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                // Back
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
                  'Verificacion SMS',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: verdeNeon,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  widget.phoneLabel == null
                      ? 'Enviamos un código\ningresa el código de verificación'
                      : 'Enviamos un código a ${widget.phoneLabel}\nIngresa el código de verificación',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: Colors.black.withValues(alpha: 0.45),
                  ),
                ),
                const SizedBox(height: 24),

                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 12.0;
                    final available = constraints.maxWidth;
                    final box = ((available - spacing * (_len - 1)) / _len)
                        .clamp(42.0, 58.0);
                    final font = box >= 54 ? 22.0 : (box >= 48 ? 20.0 : 18.0);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        _len,
                        (i) => _pinBox(i, box, font),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Botón verificar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _complete && !_sending ? _verify : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verdeNeon,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: gris.withValues(alpha: 0.7),
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
                            : const Text('Verificar'),
                  ),
                ),

                const SizedBox(height: 28),

                // Reenviar
                Center(
                  child: Wrap(
                    children: [
                      const Text(
                        'No recibiste el codigo? ',
                        style: TextStyle(
                          color: verdeNeon,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: _resendSeconds == 0 ? _resend : null,
                        child: Text(
                          _resendSeconds == 0
                              ? 'Reenviar'
                              : 'Reenviar (${_resendSeconds}s)',
                          style: const TextStyle(
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
