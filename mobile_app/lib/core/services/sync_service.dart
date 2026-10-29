import 'package:flutter/foundation.dart';

class SyncService {
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  Future<bool> syncUserData() async {
    if (_isSyncing) return false;
    _isSyncing = true;
    try {
      if (kDebugMode) {
        debugPrint('[SyncService] Syncing transactions, budgets, and savings goals...');
      }
      await Future.delayed(const Duration(milliseconds: 1200));
      _lastSyncTime = DateTime.now();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SyncService] Sync failed: $e');
      }
      return false;
    } finally {
      _isSyncing = false;
    }
  }
}
