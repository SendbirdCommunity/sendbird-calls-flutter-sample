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
  bool _areConnected = false;
  bool _isCalleeAvailable = false;
  bool _isCallActive = false;
  final _calleeController = TextEditingController();

  @override
  void initState() {
    initSendbird().then((value) => setState(() {
          statusString =
              "Sendbird status online: ${value.toString().toUpperCase()}";
        }));
    _areConnected = true;

    _calleeController.addListener(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Sendbird Calls'))),
      body: Column(children: [
        statusField(),
        _areConnected ? calleeIdField(_calleeController) : Container(),
        _areConnected && _isCalleeAvailable
            ? (_isCallActive ? hangupButton() : callButton(_calleeController))
            : Container(),
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

  Widget statusField() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Text('$statusString'),
    );
  }

  Widget calleeIdField(TextEditingController calleeController) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: TextField(
        controller: calleeController,
        onChanged: (text) {
          setState(() {
            _isCalleeAvailable = text.isNotEmpty;
          });
        },
        decoration: InputDecoration(labelText: "Callee User Id"),
      ),
    );
  }

  Widget callButton(TextEditingController controller) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: ElevatedButton(
        onPressed: () {
          startCall(controller.text);
        },
        child: Icon(Icons.call, color: Colors.white),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(20),
          primary: Colors.green, // <-- Button color
          onPrimary: Colors.green, // <-- Splash color
        ),
      ),
    );
  }

  Widget hangupButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: ElevatedButton(
        onPressed: () {
          endCall();
        },
        child: Icon(Icons.call_end, color: Colors.white),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(20),
          primary: Colors.red, // <-- Button color
          onPrimary: Colors.red, // <-- Splash color
        ),
      ),
    );
  }

  Future<bool> startCall(String calleeId) async {
    try {
      final bool result = await platform.invokeMethod("direct_call", {
        "callee_id": calleeId,
      });
      setState(() {
        _isCallActive = true;
      });
      return result;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> endCall() async {
    try {
      final bool result = await platform.invokeMethod("end_direct_call", {});
      setState(() {
        _isCallActive = false;
      });
      return result;
    } catch (e) {
      throw e;
    }
  }
}
