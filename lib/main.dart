import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hive/hive.dart';
import 'package:timer/countdown.dart';
import 'package:intl/intl.dart';

void main() {
  Hive.openBox('db').then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        fontFamily: 'ProductSans',
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = Hive.box('db');

  DateTime _date = DateTime.now();
  bool _hasStarted = false;

  @override
  void initState() {
    int msSinceEpoch = db.get('time', defaultValue: 0);

    if (msSinceEpoch != 0) {
      setState(() {
        _date = DateTime.fromMicrosecondsSinceEpoch(msSinceEpoch);
        _hasStarted = true;
      });
    }

    super.initState();
  }

  void reset() {
    setState(() {
      _hasStarted = false;
      _date = DateTime.now();
      db.put('time', 0);
    });
  }

  void setTime(DateTime time) {
    setState(() {
      _hasStarted = true;
      _date = time;
      db.put('time', time.microsecondsSinceEpoch);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int estimateTs = _date.microsecondsSinceEpoch;
    final int now = DateTime.now().microsecondsSinceEpoch;
    final Duration remaining = Duration(microseconds: estimateTs - now);

    return Scaffold(
      body: Center(
        child: _hasStarted
            ? Timer(
                seconds: remaining.inSeconds,
                selectedDate: _date,
                onReset: () {
                  reset();
                },
              )
            : RaisedButton(
                onPressed: () {
                  DatePicker.showDateTimePicker(context,
                      showTitleActions: true,
                      onConfirm: setTime,
                      currentTime: DateTime.now());
                },
                child: Text(
                  'set time',
                ),
              ),
      ),
    );
  }
}

class Timer extends StatelessWidget {
  final int seconds;
  final Function onReset;
  final DateTime selectedDate;

  const Timer({Key key, this.seconds, this.onReset, this.selectedDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CountDownTimer(
            secondsRemaining: seconds,
            whenTimeExpires: () {},
            countDownTimerStyle:
                TextStyle(color: Color(0XFFf5a623), fontSize: 155),
          ),
          SizedBox(height: 15),
          Text(
            'until ${DateFormat('EEE, MMM d H:mm').format(selectedDate)}',
            style: TextStyle(color: Color(0XFFf5a623), fontSize: 24 ),
          ),
          SizedBox(height: 60),
          IconButton(
            onPressed: onReset,
            icon: Icon(Icons.restore),
          ),
        ],
      ),
    );
  }
}
