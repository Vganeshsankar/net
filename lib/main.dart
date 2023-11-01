import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
import 'package:net/tose_2.dart';
import 'package:signal_strength/signal_strength.dart';

void main() {
  runApp(const Tost_2());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterNetworkConnectivity _flutterNetworkConnectivity =
      FlutterNetworkConnectivity(
    isContinousLookUp: true,
    // optional, false if you cont want continous lookup
    lookUpDuration: const Duration(seconds: 5),
    // optional, to override default lookup duration
    lookUpUrl: 'example.com', // optional, to override default lookup url
  );

  bool? _isInternetAvailableOnCall;

  bool? _isInternetAvailableStreamStatus;

  StreamSubscription<bool>? _networkConnectionStream;

  final _signalStrengthPlugin = SignalStrength();

  NetworkStats? _stats;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _flutterNetworkConnectivity.getInternetAvailabilityStream().listen((event) {
      _isInternetAvailableStreamStatus = event;
      setState(() {});
    });

    init();

    _timer = Timer(const Duration(seconds: 1), _getNetworkStats);
  }

  @override
  void dispose() async {
    _networkConnectionStream?.cancel();
    _flutterNetworkConnectivity.unregisterAvailabilityListener();

    super.dispose();
  }

  void init() async {
    await _flutterNetworkConnectivity.registerAvailabilityListener();
  }

  void _getNetworkStats() async {
    _timer?.cancel();
    var stats = NetworkStats(
        await _signalStrengthPlugin.isOnCellular(),
        await _signalStrengthPlugin.isOnWifi(),
        await _signalStrengthPlugin.getWifiSignalStrength(),
        await _signalStrengthPlugin.getCellularSignalStrength());
    setState(() {
      _stats = stats;
    });
    _timer = Timer(const Duration(seconds: 1), _getNetworkStats);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _checkInternetAvailability() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      _isInternetAvailableOnCall =
          await _flutterNetworkConnectivity.isInternetConnectionAvailable();
    } on PlatformException {
      _isInternetAvailableOnCall = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Network Connectivity'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.black12,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24.0),
                      const Text(
                        'Internet Availability Stream',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            null == _isInternetAvailableStreamStatus
                                ? 'Unknown State'
                                : _isInternetAvailableStreamStatus!
                                    ? "You're Connected to Network"
                                    : "You're Offline",
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.lightGreen.shade400,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24.0),
                      const Text(
                        'Internet Availability Status on Call',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              null == _isInternetAvailableOnCall
                                  ? 'Unknown State'
                                  : _isInternetAvailableOnCall!
                                      ? "You're Connected to Network"
                                      : "You're Offline",
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 50.0),
                            ElevatedButton(
                              onPressed: _checkInternetAvailability,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amberAccent,
                              ),
                              child: const Text(
                                'Check Network State',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                if (_stats != null) ...[
                  Text('Cell strength: ${_stats?.cellularSignalStrength}'),
                  Text('Wifi strength: ${_stats?.wifiSignalStrength}'),
                  Text('On cellular: ${_stats?.hasCellular}'),
                  Text('On wifi: ${_stats?.hasWifi}'),
                ] else ...[
                  const Text('No stats available')
                ],
              ],
            )
          ],
        ),
      ),
    );
  }
}

class NetworkStats {
  NetworkStats(this.hasCellular, this.hasWifi, this.wifiSignalStrength,
      this.cellularSignalStrength);
  bool hasCellular;
  bool hasWifi;
  int? wifiSignalStrength;
  List<int>? cellularSignalStrength;
}

// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:signal_strength_indicator/signal_strength_indicator.dart';
//
// void main() => runApp(const App());
//
// class App extends StatelessWidget {
//   const App({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Signal strength indicator example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const HomePage(),
//     );
//   }
// }
//
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   double _signalStrength = 0.0;
//
//   void _changeValue(double value) {
//     setState(() {
//       _signalStrength = value;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Signal strength indicator example'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: <Widget>[
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 SignalStrengthIndicator.bars(value: _signalStrength, size: 20),
//                 SignalStrengthIndicator.bars(value: _signalStrength, size: 30),
//                 SignalStrengthIndicator.bars(value: _signalStrength, size: 40),
//                 SignalStrengthIndicator.bars(value: _signalStrength, size: 50),
//                 SignalStrengthIndicator.bars(value: _signalStrength, size: 70),
//               ],
//             ),
//             const SizedBox(height: 50),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 SignalStrengthIndicator.bars(
//                   value: _signalStrength,
//                   size: 20,
//                   barCount: 4,
//                   activeColor: Colors.blue,
//                   inactiveColor: Colors.blue[100],
//                 ),
//                 SignalStrengthIndicator.bars(
//                   value: _signalStrength,
//                   size: 50,
//                   barCount: 4,
//                   spacing: 0.5,
//                 ),
//                 SignalStrengthIndicator.bars(
//                   value: _signalStrength,
//                   size: 50,
//                   barCount: 4,
//                   radius: const Radius.circular(20.0),
//                 ),
//                 SignalStrengthIndicator.bars(
//                   value: _signalStrength,
//                   // ignore: prefer_const_literals_to_create_immutables
//                   levels: <num, Color>{
//                     0.25: Colors.red,
//                     0.50: Colors.yellow,
//                     0.75: Colors.green,
//                   },
//                   // radius: Radius.circular(20.0),
//                   size: 50,
//                 ),
//                 SignalStrengthIndicator.bars(
//                   value: _signalStrength,
//                   size: 50,
//                   barCount: 5,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 50),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 SignalStrengthIndicator.bars(
//                   value: _signalStrength,
//                   size: 50,
//                   barCount: 4,
//                   bevelled: true,
//                   activeColor: Colors.blue,
//                   inactiveColor: Colors.blue[100],
//                 ),
//                 SignalStrengthIndicator.bars(
//                   value: _signalStrength,
//                   size: 50,
//                   barCount: 4,
//                   bevelled: true,
//                   spacing: 0.5,
//                 ),
//                 SignalStrengthIndicator.bars(
//                   value: _signalStrength,
//                   size: 50,
//                   bevelled: true,
//                   spacing: -0.01,
//                 ),
//                 SignalStrengthIndicator.bars(
//                   value: _signalStrength,
//                   bevelled: true,
//                   // ignore: prefer_const_literals_to_create_immutables
//                   levels: <num, Color>{
//                     0.25: Colors.red,
//                     0.50: Colors.yellow,
//                     0.75: Colors.green,
//                   },
//                   // radius: Radius.circular(20.0),
//                   size: 50,
//                 ),
//                 SignalStrengthIndicator.bars(
//                   value: _signalStrength,
//                   size: 50,
//                   barCount: 5,
//                   bevelled: true,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 50),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 SignalStrengthIndicator.sector(
//                   value: _signalStrength,
//                   size: 50,
//                   barCount: 4,
//                   spacing: 0.5,
//                 ),
//                 RotatedBox(
//                   quarterTurns: 3,
//                   child: SignalStrengthIndicator.sector(
//                     value: _signalStrength,
//                     size: 50,
//                     barCount: 4,
//                     spacing: 0.5,
//                     rounded: true,
//                   ),
//                 ),
//                 Transform.rotate(
//                   angle: -45 * pi / 180,
//                   origin: const Offset(-15, 0),
//                   child: SignalStrengthIndicator.sector(
//                     value: _signalStrength,
//                     size: 50,
//                     spacing: -0.01,
//                   ),
//                 ),
//                 SignalStrengthIndicator.sector(
//                   value: _signalStrength,
//                   size: 50,
//                   spacing: 0.5,
//                   // ignore: prefer_const_literals_to_create_immutables
//                   levels: <num, Color>{
//                     0.25: Colors.red,
//                     0.50: Colors.yellow,
//                     0.75: Colors.green,
//                   },
//                 ),
//                 SignalStrengthIndicator.sector(
//                   value: _signalStrength,
//                   size: 50,
//                   barCount: 4,
//                   spacing: 0.5,
//                   rounded: true,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 50),
//             const SizedBox(height: 10),
//             Text(
//               'Signal strength: ${_signalStrength.toStringAsFixed(2)}',
//               style: const TextStyle(fontSize: 20.0),
//             ),
//             Slider(
//               value: _signalStrength,
//               onChanged: _changeValue,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
