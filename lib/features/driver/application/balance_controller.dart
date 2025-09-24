import 'package:flutter_riverpod/flutter_riverpod.dart';

final balanceProvider = NotifierProvider<BalanceController, double>(BalanceController.new);

class BalanceController extends Notifier<double> {
  @override
  double build() => 200.0; // saldo demo
  void add(double amount) => state += amount;
  void reset([double v = 200.0]) => state = v;
}
