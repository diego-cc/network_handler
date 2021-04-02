import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:network_handler/network_handler.dart';
import 'package:network_handler/network_status.dart';

class Example extends StatefulWidget {
  Example({Key key}) : super(key: key);

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  NetworkStatus _status = NetworkStatus.unknown;
  static final isIOS = Platform.isIOS;
  static final title = 'Network handler demo';

  Widget get child => NetworkHandler(
        child: ExampleChild(
          status: _status,
        ),
        onChanged: (NetworkStatus status) {
          setState(() {
            _status = status;
          });
        },
      );

  @override
  Widget build(BuildContext context) {
    if (isIOS) {
      return CupertinoApp(
        debugShowCheckedModeBanner: false,
        home: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(title),
          ),
          child: Center(
            child: child,
          ),
        ),
      );
    }

    /// Defaults to Material
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: Center(child: child)),
    );
  }
}

class ExampleChild extends StatelessWidget {
  final NetworkStatus status;

  const ExampleChild({Key key, @required this.status}) : super(key: key);

  TextSpan get _statusText {
    TextStyle textStyle = TextStyle(fontSize: 18, color: Colors.yellow[700]);

    String text = 'Unknown';

    switch (status) {
      case NetworkStatus.connected:
        text = 'Connected';
        textStyle = textStyle.copyWith(color: Colors.green);
        break;

      case NetworkStatus.disconnected:
        text = 'Disconnected';
        textStyle = textStyle.copyWith(color: Colors.red);
        break;

      default:
        break;
    }

    return TextSpan(
      text: text,
      style: textStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            text: 'Network connection status: ',
            children: [_statusText],
            style: TextStyle(fontSize: 18)));
  }
}
