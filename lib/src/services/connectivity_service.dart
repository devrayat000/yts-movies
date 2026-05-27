import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum ConnectivityState {
  initial("initial"),
  connected("connected"),
  disconnected("disconnected"),
  ;

  final String value;
  const ConnectivityState(this.value);
}

/// Service for monitoring network connectivity status
@lazySingleton
class ConnectivityService extends Cubit<ConnectivityState> {
  late final StreamSubscription<List<ConnectivityResult>> _sub;
  late final Connectivity _conn;

  ConnectivityService() : super(ConnectivityState.initial) {
    _conn = Connectivity();
    _sub = _conn.onConnectivityChanged.listen(
      (results) {
        if (_checkConnected(results)) {
          _updateState(ConnectivityState.connected);
        } else {
          _updateState(ConnectivityState.disconnected);
        }
      },
      onError: (error) => addError(error),
    );
  }

  void _updateState(ConnectivityState newState) {
    if (state != newState) {
      log('Connectivity status changed: $newState}');
      emit(newState);
    }
  }

  bool get isConnected => state == ConnectivityState.connected;
  bool get isDisconnected => state == ConnectivityState.disconnected;

  /// Initialize the connectivity service
  @postConstruct
  Future<void> initialize() async {
    try {
      // Check initial connectivity status
      final results = await _conn.checkConnectivity();
      if (_checkConnected(results)) {
        _updateState(ConnectivityState.connected);
      } else {
        _updateState(ConnectivityState.disconnected);
      }
    } catch (e, stackTrace) {
      log(
        'Failed to initialize connectivity service: $e',
        error: e,
        stackTrace: stackTrace,
      );
      addError(e, stackTrace);
    }
  }

  /// Get a user-friendly connectivity status message
  String get statusMessage {
    return state == ConnectivityState.connected
        ? 'Connected to internet'
        : 'No internet connection. Please check your network settings.';
  }

  bool _checkConnected(List<ConnectivityResult> results) => results.any(
      (element) =>
          element == ConnectivityResult.ethernet ||
          element == ConnectivityResult.mobile ||
          element == ConnectivityResult.wifi);

  /// Dispose of the service and close streams
  @override
  @disposeMethod
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
