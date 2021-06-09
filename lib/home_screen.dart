import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel('com.sendbird.calls/method');
  String statusString = "Initializing Sendbird...";

  @override
  void initState() {
    initSendbird().then((value) => setState(() {
          statusString = "Sendbird status online: ${value.toString()}";
        }));
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
          "app_id": "D56438AE-B4DB-4DC9-B440-E032D7B35CEB",
          "user_id": "jason",
        },
      );
      return result;
    } catch (e) {
      throw e;
    }
  }
}
