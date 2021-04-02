import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:network_handler/network_status.dart';

/// Default host to ping
const String defaultHost = 'example.com';

/// Default port to use for the host above
const int defaultPort = 80;

/// Default timeout to cancel status checks
const int defaultTimeoutSeconds = 5;

/// Detects changes in network connection status
/// (regardless of whether the user is connected to Wi-Fi or mobile data).
///
/// Pass an [onChanged] event handler to execute actions upon those changes.
///
/// The [child] parameter is mandatory.
///
/// Ideally, you would only use NetworkHandler to wrap the
/// [child] widget that needs to know the device's connection status at all times.
///
/// NetworkHandler will continuously check the device's connection status in
/// the background every [refreshTimer] milliseconds (2000 by default)
class NetworkHandler extends StatefulWidget {
  final Widget child;
  final ValueChanged<NetworkStatus> onChanged;

  /// The value of [refreshTimer] is currently being ignored.
  final int refreshTimer;

  NetworkHandler(
      {Key key, @required this.child, this.refreshTimer = 2000, this.onChanged})
      : super(key: key);

  @override
  _NetworkHandlerState createState() => _NetworkHandlerState();
}

class _NetworkHandlerState extends State<NetworkHandler> {
  Isolate _isolate;
  ReceivePort _receivePort;

  NetworkStatus _status = NetworkStatus.unknown;

  static int _refreshTimer;
  static Timer _networkTimer;

  /// Pings [defaultHost] once.
  ///
  /// It is assumed that [defaultHost] has zero downtime
  /// (an unrealistic expectation),
  /// so choose it wisely.
  static FutureOr<NetworkStatus> _checkStatus({SendPort sendPort}) {
    return Socket.connect(defaultHost, defaultPort,
            timeout: const Duration(seconds: defaultTimeoutSeconds))
        .then((socket) {
      final status = NetworkStatus.connected;

      sendPort?.send(status);

      socket.destroy();
      return status;
    }).catchError((err) {
      if (stdout.supportsAnsiEscapes) {
        print(
            '\x1B[31mFailed to check connection status. You are most likely disconnected\x1B[0m 😕');
      } else {
        print(
            'Failed to check connection status. You are most likely disconnected 😕');
      }

      print('\n$err');

      final status = NetworkStatus.disconnected;

      sendPort?.send(status);
      return status;
    });
  }

  static void _checkStatusPeriodic(SendPort sendPort) {
    _networkTimer = Timer.periodic(
        Duration(milliseconds: _refreshTimer ?? 2000),
        (timer) => _checkStatus(sendPort: sendPort));
  }

  /// Initialises [_isolate] in a separate event loop and
  /// listens for changes in network connection status.
  FutureOr<void> _startNetworkChecks() async {
    _receivePort = ReceivePort();

    try {
      _isolate =
          await Isolate.spawn(_checkStatusPeriodic, _receivePort.sendPort);

      _receivePort.listen((message) {
        if (message != _status) {
          if (message == NetworkStatus.connected &&
              _status == NetworkStatus.disconnected) {
            print('Back online! 😎');
          }
          widget.onChanged(message);

          setState(() {
            _status = message;
          });
        }
      });
    } catch (err) {
      print('Could not initialise network isolate:');
      print(err);
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshTimer = widget.refreshTimer;
    _startNetworkChecks();
  }

  @override
  void dispose() {
    super.dispose();
    _networkTimer?.cancel();
    _isolate?.kill(priority: Isolate.immediate);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
