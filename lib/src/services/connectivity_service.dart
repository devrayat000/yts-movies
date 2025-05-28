import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for monitoring network connectivity status
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  static ConnectivityService get instance => _instance;

  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Initialize the connectivity service
  Future<void> initialize() async {
    try {
      // Check initial connectivity status
      final result = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(result);

      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectivityStatus,
        onError: (error, stackTrace) {
          log(
            'Connectivity monitoring error: $error',
            error: error,
            stackTrace: stackTrace,
          );
        },
      );
    } catch (e, stackTrace) {
      log(
        'Failed to initialize connectivity service: $e',
        error: e,
        stackTrace: stackTrace,
      );
      // Assume connected if we can't check
      _isConnected = true;
    }
  }

  /// Update connectivity status based on connectivity result
  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;

    // Check if any of the results indicate connectivity
    _isConnected = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn);

    if (wasConnected != _isConnected) {
      log('Connectivity status changed: ${_isConnected ? "Connected" : "Disconnected"}');
      _connectivityController.add(_isConnected);
    }
  }

  /// Get a user-friendly connectivity status message
  String get statusMessage {
    return _isConnected
        ? 'Connected to internet'
        : 'No internet connection. Please check your network settings.';
  }

  /// Check if the device has an active internet connection
  Future<bool> hasInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(result);
      return _isConnected;
    } catch (e) {
      log('Error checking internet connection: $e');
      return false;
    }
  }

  /// Dispose of the service and close streams
  void dispose() {
    _connectivitySubscription.cancel();
    _connectivityController.close();
  }
}
