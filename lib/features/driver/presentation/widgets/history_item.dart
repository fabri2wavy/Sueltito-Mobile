import 'package:flutter/material.dart';

class HistoryItem extends StatelessWidget {
  final String date, description, passengerId, amount;
  const HistoryItem({super.key, required this.date, required this.description, required this.passengerId, required this.amount});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(description),
      subtitle: Text('ID: $passengerId\n$date'),
      trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
