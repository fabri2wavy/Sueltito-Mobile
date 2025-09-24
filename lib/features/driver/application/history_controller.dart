import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models.dart';

final historyProvider = NotifierProvider<HistoryController, List<Trip>>(HistoryController.new);

class HistoryController extends Notifier<List<Trip>> {
  @override
  List<Trip> build() => const [];
  void add(Trip t) => state = [t, ...state];
  void clear() => state = const [];
}
