import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectionStatus { connected, disconnected, unknown }

class ConnectivityNotifier extends Notifier<ConnectionStatus> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  ConnectionStatus build() {
    // Setup listener
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      _updateStatus(result);
    });

    // Initial cleanup
    ref.onDispose(() {
      _subscription.cancel();
    });

    // We can try to get the initial status immediately if possible,
    // but build must be synchronous. Use a microtask/future to update state shortly.
    _init();

    return ConnectionStatus.unknown;
  }

  Future<void> _init() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateStatus(result);
    } catch (_) {
      state = ConnectionStatus.disconnected;
    }
  }

  void _updateStatus(List<ConnectivityResult> result) {
    // If list contains any 'valid' connection type, we consider it connected.
    if (result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet) ||
        result.contains(ConnectivityResult.vpn)) {
      state = ConnectionStatus.connected;
    } else {
      state = ConnectionStatus.disconnected;
    }
  }
}

final connectivityProvider =
    NotifierProvider<ConnectivityNotifier, ConnectionStatus>(
      ConnectivityNotifier.new,
    );
