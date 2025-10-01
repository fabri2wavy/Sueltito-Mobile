import 'package:flutter/material.dart';
import 'router.dart';           // 👈 usa tu GoRouter
import 'core/theme.dart';      // tu tema (AppTheme.theme o buildTheme)

class SueltitoApp extends StatelessWidget {
  const SueltitoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sueltito',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,    // si tu tema es buildTheme(), cámbialo aquí
      routerConfig: router,     // 👈 ¡clave! activa GoRouter
    );
  }
}
