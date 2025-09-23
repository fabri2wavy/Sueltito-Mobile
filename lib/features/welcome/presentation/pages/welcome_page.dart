import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/pages/signup.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            Image.asset(
              'assets/images/brand_logo.png',
              height: 180,
              errorBuilder: (_, __, ___) => const SizedBox(height: 180),
            ),

            const SizedBox(height: 20),
            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  //Botón Inicia Sesión
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text("Inicia Sesión"),
                    ),
                  ),
                  const SizedBox(height: 15),

                  //Botón Regístrate
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignupPage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.violetaRuso),
                        foregroundColor: AppTheme.violetaRuso,
                      ),
                      child: const Text("Regístrate"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
