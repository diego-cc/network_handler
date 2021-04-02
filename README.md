# network_handler
Notifies your app whenever your device's network connection status changes. It exposes a callback for you to handle those changes.

[![Example](https://user-images.githubusercontent.com/50987412/113434801-31c23500-9414-11eb-9054-c60bc1c03408.png)](https://user-images.githubusercontent.com/50987412/113434067-e8251a80-9412-11eb-91a8-3ee18cff67e7.mp4 "Example")

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
    build(BuildContext context) {
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
        )
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
