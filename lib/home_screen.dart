import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final String appId;
  final String userId;

  const HomeScreen({Key? key, required this.appId, required this.userId})
      : super(key: key);

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
    final calleeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Sendbird Calls'))),
      body: Column(children: [
        Text('$statusString'),
        TextField(
          controller: calleeController,
          decoration: InputDecoration(labelText: "Callee User Id"),
        ),
        callButton(calleeController),
      ]),
    );
  }

  Future<bool> initSendbird() async {
    try {
      final bool result = await platform.invokeMethod(
        "init",
        {
          "app_id": widget.appId,
          "user_id": widget.userId,
        },
      );
      return result;
    } catch (e) {
      throw e;
    }
  }

  Widget callButton(TextEditingController controller) {
    return IconButton(
      icon: const Icon(Icons.call),
      onPressed: () {
        startCall(controller.text);
      },
    );
  }

  Future<bool> startCall(String calleeId) async {
    try {
      final bool result = await platform.invokeMethod(
        "voice_call",
        {
          "callee_id": calleeId,
        },
      );
      return result;
    } catch (e) {
      throw e;
    }
  }
}
