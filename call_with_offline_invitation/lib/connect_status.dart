import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZegoNetworkStatus {
  final valueNotifier = ValueNotifier<bool>(false);

  factory ZegoNetworkStatus() => instance;
  static final ZegoNetworkStatus instance = ZegoNetworkStatus._internal();

  ZegoNetworkStatus._internal() {
    initConnectivity();

    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      return;
    }

    _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    debugPrint('_updateConnectionStatus:$result');
    _connectionStatus = result;

    valueNotifier.value =
        _connectionStatus.contains(ConnectivityResult.mobile) ||
            _connectionStatus.contains(ConnectivityResult.wifi) ||
            _connectionStatus.contains(ConnectivityResult.ethernet);
  }

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
}

class ZegoNetworkLoading extends StatefulWidget {
  final Widget child;
  final String? tips;

  const ZegoNetworkLoading({
    required this.child,
    this.tips,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ZegoNetworkLoadingState();
}

class ZegoNetworkLoadingState extends State<ZegoNetworkLoading> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ZegoNetworkStatus().valueNotifier,
      builder: (context, isConnected, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final height = double.infinity == constraints.maxHeight
                ? 10.0
                : constraints.maxHeight;
            final fontSize = height > 20.0 ? 20.0 : height;

            return Stack(
              children: [
                widget.child,
                if (!isConnected)
                  Container(
                    width: constraints.maxWidth,
                    height: height,
                    color: Colors.black54,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const CircularProgressIndicator(),
                        Text(
                          widget.tips ?? 'Network Loading...',
                          style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.white,
                          ), // White text for contrast
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
