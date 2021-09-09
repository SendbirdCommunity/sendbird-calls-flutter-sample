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
  String? callerId;
  String? callerNickname;

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
        print('home_screen: _handleNativeMethods: receiving call detected.');

        setState(() {
          callerId = call.arguments['caller_id'];
          callerNickname = call.arguments['caller_nickname'];
          _areReceivingCall = true;
        });
        return new Future.value("");
      case "direct_call_connected":
        print('home_screen: _handleNativeMethods: call connected.');

        setState(() {
          _areReceivingCall = false;
          _isCallActive = true;
        });
        return new Future.value("");
      case "direct_call_ended":
        setState(() {
          _isCallActive = false;
          callerId = null;
          callerNickname = null;
        });
        return new Future.value("");
      case "error":
        print("${call.arguments}");
        return new Future.value("");
      default:
        return new Future.value("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Sendbird Calls'))),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              statusField(),
              Row(children: [
                SizedBox(width: 80, child: Text("Call")),
                Container(width: 10),
                SizedBox(width: 150, child: calleeIdField(_calleeController)),
                Container(width: 10),
                Expanded(
                    child: _isCalleeAvailable
                        ? _isCallActive
                            ? Container()
                            : callButton(_calleeController)
                        : Container()),
              ]),
              Container(height: 20),
              Row(children: [
                SizedBox(width: 80, child: Text('Receiving')),
                Container(width: 10),
                SizedBox(
                  width: 150,
                  child: callerNickname != null
                      ? Text('$callerNickname')
                      : callerId != null
                          ? Text("$callerId")
                          : Text("<No incoming calls>"),
                ),
                Expanded(
                    child: _areReceivingCall
                        ? receivingCallButton()
                        : Container()),
                Container(height: 20),
              ]),
              Container(height: 10),
              _isCallActive ? hangupButton() : Container(),
            ]),
      ),
    );
  }

  Widget dialRow() {
    return Expanded(
      child: Row(children: [
        Text("Dial"),
        Container(width: 10),
        calleeIdField(_calleeController),
        Container(width: 10),
        _isCallActive ? hangupButton() : callButton(_calleeController)
      ]),
    );
  }

  Widget receiveRow() {
    return Expanded(
      child: Row(children: [
        Text('Receiving calls'),
        Container(width: 10),
        callerNickname != null
            ? Text('$callerNickname')
            : callerId != null
                ? Text("$callerId")
                : Container(),
        _areReceivingCall ? receivingCallButton() : Container(),
        callerId != null && _isCallActive ? hangupButton() : Container(),
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
      // padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
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
      child: ElevatedButton(
        onPressed: () {
          startCall(controller.text);
        },
        child: Icon(
          Icons.call,
          color: Colors.white,
          size: 20.0,
        ),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          primary: Colors.green, // <-- Button color
          onPrimary: Colors.green, // <-- Splash color
        ),
      ),
    );
  }

  Widget receivingCallButton() {
    return Container(
      child: ElevatedButton(
        onPressed: () {
          pickupCall();
        },
        child: Icon(
          Icons.call,
          color: Colors.blue,
          size: 20.0,
        ),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          primary: Colors.white, // <-- Button color
          onPrimary: Colors.white, // <-- Splash color
        ),
      ),
    );
  }

  Widget hangupButton() {
    return Container(
      padding: EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {
          endCall();
        },
        child: Icon(
          Icons.call_end,
          color: Colors.white,
          // size: 40.0,
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(20),
          shape: CircleBorder(),
          primary: Colors.red, // <-- Button color
          onPrimary: Colors.red, // <-- Splash color
        ),
      ),
    );
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
