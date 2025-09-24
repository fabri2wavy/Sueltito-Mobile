import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final driverProfileProvider =
    NotifierProvider<DriverProfileController, DriverProfile>(
        DriverProfileController.new);

class DriverProfile {
  final String? nfcId;
  const DriverProfile({this.nfcId});
  bool get isRegistered => nfcId != null && nfcId!.isNotEmpty;
}

class DriverProfileController extends Notifier<DriverProfile> {
  static const _kNfcIdKey = 'driver_nfc_id';
  final _store = const FlutterSecureStorage();

  @override
  DriverProfile build() {
    _load();
    return const DriverProfile(nfcId: null);
  }

  Future<void> _load() async {
    final saved = await _store.read(key: _kNfcIdKey);
    if (saved != state.nfcId) state = DriverProfile(nfcId: saved);
  }

  Future<void> registerNfc(String id) async {
    await _store.write(key: _kNfcIdKey, value: id);
    state = DriverProfile(nfcId: id);
  }

  Future<void> clearNfc() async {
    await _store.delete(key: _kNfcIdKey);
    state = const DriverProfile(nfcId: null);
  }
}
