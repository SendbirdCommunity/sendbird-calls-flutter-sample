import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.sendbird.calls/method');
  // static const directCallChannel = MethodChannel('com.sendbird.calls/direct');
  String statusString = "Loading...";
  bool initRequested = false;

  @override
  void initState() {
    if (initRequested == false) {
      initRequested = true;
      initSendbird().then((value) => setState(() {
            statusString = "Sendbird status online: ${value.toString()}";
            initRequested = true;
          }));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sendbird Calls')),
      body: Text('$statusString'),
    );
  }

  Future<bool> initSendbird() async {
    try {
      final bool result = await platform.invokeMethod(
        "init",
        {
          "app_id": "YOUR_APP_ID",
          "user_id": "A_USER_ID",
        },
      );
      return result;
    } catch (e) {
      throw e;
    }
  }
}
