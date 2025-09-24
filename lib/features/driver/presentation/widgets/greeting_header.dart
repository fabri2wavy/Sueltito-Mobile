import 'package:flutter/material.dart';

class GreetingHeader extends StatelessWidget {
  final String name;
  const GreetingHeader({super.key, required this.name});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('¡Bienvenido Maestrito!', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text('Hola, $name', style: Theme.of(context).textTheme.headlineSmall),
    ]);
  }
}
