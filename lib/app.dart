import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/welcome/presentation/pages/welcome_page.dart';
import 'features/auth/presentation/pages/login_page.dart';

class SueltitoApp extends StatelessWidget {
  const SueltitoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sueltito',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const _SignupPageTemp(),
        '/home': (context) => const _HomePageTemp(),
      },
    );
  }
}

class _SignupPageTemp extends StatelessWidget {
  const _SignupPageTemp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Volver'),
        ),
      ),
    );
  }
}

class _HomePageTemp extends StatelessWidget {
  const _HomePageTemp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: const Center(child: Text('Home temporal')),
    );
  }
}
