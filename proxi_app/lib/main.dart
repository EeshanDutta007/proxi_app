import 'package:flutter/material.dart';
import 'dart:async';

import 'package:all_sensors/all_sensors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensors Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _proximityValues = false;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  Stream<int> stopWatchStream() {
    StreamController<int> streamController;
    Timer timer;
    Duration timerInterval = Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
        counter = 0;
        streamController.close();
      }
    }

    void tick(_) {
      counter++;
      streamController.add(counter);
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }

  bool isS = false;
  int k = 0;
  var hoursStr = '00', minutesStr = '00', secondsStr = '00';
  var timerStream, timerSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flip to focus")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$hoursStr:$minutesStr:$secondsStr",
              style: TextStyle(
                fontSize: 90.0,
              ),
            ),
            SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  onPressed: () {
                    Timer(Duration(seconds: 3), (){
                      if (_proximityValues == true) {
                        timerStream = stopWatchStream();
                        timerSubscription = timerStream.listen((int newTick) {
                          setState(() {
                            if (_proximityValues == true) {
                              hoursStr = ((newTick / (60 * 60)) % 60)
                                  .floor()
                                  .toString()
                                  .padLeft(2, '0');
                              minutesStr = ((newTick / 60) % 60)
                                  .floor()
                                  .toString()
                                  .padLeft(2, '0');
                              secondsStr = (newTick % 60)
                                  .floor()
                                  .toString()
                                  .padLeft(2, '0');
                            }
                          });
                        });
                      } else {
                        timerSubscription.pause();
                      }
                    });

                  },
                  color: Colors.green,
                  child: Text(
                    'START',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
                SizedBox(width: 40.0),
                RaisedButton(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  onPressed: () {
                    timerSubscription.cancel();
                    timerStream = null;
                    setState(() {
                      hoursStr = '00';
                      minutesStr = '00';
                      secondsStr = '00';
                      k = 0;
                    });
                  },
                  color: Colors.red,
                  child: Text(
                    'RESET',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(proximityEvents.listen((ProximityEvent event) {
      setState(() {
        _proximityValues = event.getValue();
      });
    }));
  }
}
