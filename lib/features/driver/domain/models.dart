enum ScanMode { nfc }
enum FailureCode { insufficientBalance, invalidCard, duplicateTap, offline, expiredCard }

class PaymentResult {
  final bool success;
  final ScanMode mode;
  final String passengerId;
  final double amount;
  final DateTime timestamp;
  final String description;
  final FailureCode? failure;

  const PaymentResult({
    required this.success,
    required this.mode,
    required this.passengerId,
    required this.amount,
    required this.timestamp,
    required this.description,
    this.failure,
  });

  factory PaymentResult.success({
    required ScanMode mode,
    required String passengerId,
    required double amount,
    required DateTime timestamp,
    required String description,
  }) => PaymentResult(
        success: true, mode: mode, passengerId: passengerId,
        amount: amount, timestamp: timestamp, description: description,
      );

  factory PaymentResult.failure({
    required ScanMode mode,
    required String passengerId,
    required DateTime timestamp,
    required FailureCode failure,
  }) => PaymentResult(
        success: false, mode: mode, passengerId: passengerId,
        amount: 0.0, timestamp: timestamp, description: '—', failure: failure,
      );
}

class Trip {
  final String description;
  final String passengerId;
  final double amount;
  final DateTime timestamp;
  const Trip({required this.description, required this.passengerId, required this.amount, required this.timestamp});
}
