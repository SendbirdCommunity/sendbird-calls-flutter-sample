import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final String appId;
  final String userId;
  final String? accessToken;

  const HomeScreen({
    Key? key,
    required this.appId,
    required this.userId,
    this.accessToken,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel('com.sendbird.calls/method');
  String statusString = "Initializing Sendbird...";
  bool _areConnected = false;
  bool _isCalleeAvailable = false;
  bool _isCallActive = false;
  bool _areReceivingCall = false;
  final _calleeController = TextEditingController();
  List<String> _callees = [];

  @override
  void initState() {
    // Inform native Sendbird calls sdks to init and connect
    initSendbird().then((value) => setState(() {
          _areConnected = value;
          statusString =
              "Sendbird status online: ${value.toString().toUpperCase()}";
        }));

    _calleeController.addListener(() {});

    // Listen for incoming native events
    platform.setMethodCallHandler(_handleNativeMethods);

    super.initState();
  }

  Future<dynamic> _handleNativeMethods(MethodCall call) async {
    switch (call.method) {
      case "direct_call_received":
        setState(() {
          _areReceivingCall = true;
        });
        return new Future.value("");
        ;
      case "direct_call_connected":
        setState(() {
          _areReceivingCall = false;
          _isCallActive = true;
        });
        return new Future.value("");
      case "direct_call_ended":
        setState(() {
          _areReceivingCall = false;
          _isCallActive = false;
        });
        return new Future.value("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Sendbird Calls'))),
      body: Column(children: [
        statusField(),
        _areConnected ? calleeIdField(_calleeController) : Container(),
        dynamicButton(),
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
          "access_token": widget.accessToken,
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

  Widget dynamicButton() {
    if (_areReceivingCall) {
      return receivingCallButton(_calleeController);
    }
    if (_areConnected && _isCalleeAvailable && _isCallActive) {
      return hangupButton();
    }
    if (_areConnected && _isCalleeAvailable && !_isCallActive) {
      return callButton(_calleeController);
    }
    return Container();
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

  Widget receivingCallButton(TextEditingController controller) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: ElevatedButton(
        onPressed: () {
          startCall(controller.text);
        },
        child: Icon(Icons.call, color: Colors.blue),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(20),
          primary: Colors.white, // <-- Button color
          onPrimary: Colors.white, // <-- Splash color
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

  Future<bool> startCalls(List<String> callerIds) async {
    if (callerIds.length == 1) {
      return startCall(callerIds[0]);
    }
    return startGroupCall(callerIds);
  }

  Future<bool> startCall(String calleeId) async {
    try {
      final bool result = await platform.invokeMethod("start_direct_call", {
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

  Future<bool> startGroupCall(List<String> calleeIds) async {
    try {
      final bool result = await platform.invokeMethod("start_group_call", {
        "callee_ids": calleeIds,
      });
      setState(() {
        _isCallActive = true;
      });
      return result;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> pickupCall() async {
    try {
      final bool result = await platform.invokeMethod("answer_direct_call", {});
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
