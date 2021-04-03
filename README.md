[![pub points](https://badges.bar/network_handler/pub%20points)](https://pub.dev/packages/network_handler/score)

# network_handler
Notifies your app whenever your device's network connection status changes. It exposes a callback for you to handle those changes.

![Example](https://user-images.githubusercontent.com/50987412/113435156-d47ab380-9414-11eb-8a18-493630a5f349.gif)

## Usage
```
// ...
import 'package:network_handler/network_handler.dart';
import 'package:network_handler/network_status.dart';

class SomeWidget extends StatefulWidget {
    @override
    _SomeWidgetState createState() => _SomeWidgetState();
}

class _SomeWidgetState extends State<SomeWidget> {
    @override
    Widget build(BuildContext context) {
        return NetworkHandler(
            onChanged: (NetworkStatus status) {
                // Handle network status changes here
                if (status == NetworkStatus.connected) {
                    // ...

                } else if (status == NetworkStatus.disconnected) {
                    // ...

                } else {
                    // ...
                }
            },
            child: WrappedWidget()
        );
    }
}
```

## How does it work?
Once `NetworkHandler` is added to your widget tree, it pings a host ([example.com](example.com "example.com") by default) every x milliseconds (2000 by default) and determines whether the connection was successful.

This process is executed on a separate event loop, using an [Isolate](https://api.dart.dev/stable/2.10.5/dart-isolate/Isolate-class.html "Isolate class"). No external libraries were used, only native Dart/Flutter modules.

## Known issues and limitations
- This package assumes that the host will always be online.
- Cannot pause/resume network status checks.
- A `refreshTimer` parameter can be provided to `NetworkHandler`, however it is currently being ignored.
- `NetworkHandler` does not discern between different types of network connection, e.g. Wi-Fi and mobile data. This behaviour is intentional for simplicity. I suggest looking into [connectivity](https://pub.dev/packages/connectivity "connectivity") for this purpose.

## License
MIT
