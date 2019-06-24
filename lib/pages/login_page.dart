import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flugram/main.dart';
import 'package:flugram/pages/home_page.dart';
import 'package:flugram/particles/title_section.dart';

class EnterNumberPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EnterNumberPage();
}

class StateParam {
  String type = "number";
  String text_title = "";
  String button_title = "";
  String text_hidden = "";
  String text_message = "";
  String hint_text = "";
}

class _EnterNumberPage extends State<EnterNumberPage>
    with TickerProviderStateMixin {
  AnimationController controller;

  Animation buttomZoomOut;
  Animation buttonSqueezeanimation;
  StateParam stateParam = new StateParam();
  var subsc;
  @override
  void initState() {
    super.initState();
    _controller = new TextEditingController();

    subsc = client.streamController.stream.listen((data) async {
      var recJson = json.decode(data);
      if (recJson["@type"] == "updateAuthorizationState") {
        authStateProcessor(recJson["authorization_state"]);
        setState(() {});
      }
    });
    client.startReceive();
    client.sendRequest(
        {'@type': 'getAuthorizationState'},
        () => (data) {
              print(data);
              authStateProcessor(data);
              setState(() {});
            });

    controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: 320.0,
      end: 70.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: new Interval(
        0.0,
        0.250,
      ),
    ))
      ..addListener(() {
        setState(() {});
      });
  }

  void authStateProcessor(data) {
    _controller.text = "";
    switch (data['@type']) {
      case "authorizationStateReady":
        client.stopReceive();
        subsc.cancel();
        navigatorKey.currentState.pushAndRemoveUntil(
            new MaterialPageRoute(
                builder: (BuildContext context) => new HomePage()),
            (Route route) => route == null);
        break;
      case "authorizationStateWaitPhoneNumber":
        stateParam.button_title = "Get OTP";
        stateParam.text_title = "Phone Number";
        stateParam.type = "number";
        break;
      case "authorizationStateWaitCode":
        stateParam.button_title = "Submit OTP";
        stateParam.text_title = "Enter OTP";
        stateParam.type = "otp";
        stateParam.text_message =
            "OTP Sent to " + data["code_info"]["phone_number"];
        break;
      case "authorizationStateWaitPassword":
        stateParam.button_title = "Submit";
        stateParam.text_title = "Enter password";
        stateParam.text_message = "2SV";

        stateParam.hint_text = data["password_hint"];
        stateParam.type = "password";
        break;
      default:
    }
  }

  @override
  dispose() {
    controller?.dispose();
    super.dispose();
  }

  final _scaffoldContext = GlobalKey<ScaffoldState>();

  Future<Null> _playAnimation(context) async {
    // await controller.reset();
    switch (stateParam.type) {
      case "number":
        client.sendRequest(
            {
              '@type': 'setAuthenticationPhoneNumber',
              'phone_number': _controller.text,
              'allow_flash_call': false,
              'is_current_phone_number': false
            },
            () => (data) {
                  print("After submitting phone number");
                  print(data);
                  controller.reset();
                  switch (data['@type']) {
                    case "error":
                      final snackBar = SnackBar(content: Text(data["message"]));
                      _scaffoldContext.currentState.showSnackBar(snackBar);
                      break;
                  }
                });
        break;
      case "otp":
        client.sendRequest(
            {'@type': 'checkAuthenticationCode', 'code': _controller.text},
            () => (data) {
                  print("After submitting phone number");
                  print(data);
                  controller.reset();
                  switch (data['@type']) {
                    case "error":
                      final snackBar = SnackBar(content: Text(data["message"]));
                      _scaffoldContext.currentState.showSnackBar(snackBar);
                      break;
                  }
                });
        break;
      case "password":
        client.sendRequest(
            {
              '@type': 'checkAuthenticationPassword',
              'password': _controller.text
            },
            () => (data) {
                  print("After submitting phone number");
                  print(data);
                  controller.reset();
                  switch (data['@type']) {
                    case "error":
                      final snackBar = SnackBar(content: Text(data["message"]));
                      _scaffoldContext.currentState.showSnackBar(snackBar);
                      break;
                  }
                });
        break;
      default:
    }

    setState(() {});

    // SystemChannels.textInput.invokeMethod('TextInput.hide');
    // await controller.reverse();
    await controller.forward();
  }

  var _controller;
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FluGram',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.black,
          fontFamily: "Quicksand",
          primarySwatch: Colors.amber),
      routes: <String, WidgetBuilder>{
        "/mytabs": (BuildContext _context) => new HomePage(),
      },
      home: Scaffold(
          key: _scaffoldContext,
          body: SingleChildScrollView(
    child:Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(height: 50),
                TitleSection(),
                Container(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Text(
                    stateParam.text_message,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Raleway",
                        color: Colors.grey[800],
                        fontSize: 16),
                  ),
                ),
                Container(
                  width: 300,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(18.0),
                        child: TextField(
                          obscureText:
                              stateParam.type == "password" ? true : false,
                          controller: _controller,
                          style: new TextStyle(
                              fontSize: 25.0, color: Colors.black),
                          decoration: new InputDecoration(
                              hintText: stateParam.hint_text,
                              labelText: stateParam.text_title,
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            print("Tapped");
                            _playAnimation(context);
                          },
                          child: Container(
                            width: buttonSqueezeanimation.value,
                            height: 60.0,
                            alignment: FractionalOffset.center,
                            decoration: new BoxDecoration(
                              color: Colors.black,
                              // color: animation.value,
                              borderRadius: new BorderRadius.all(
                                  const Radius.circular(30.0)),
                            ),
                            child: buttonSqueezeanimation.value > 80.0
                                ? new Text(
                                    stateParam.button_title,
                                    style: new TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 0.3,
                                    ),
                                  )
                                : new CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.white)),
                          )),
                    ],
                  ),
                )
              ]))),
    );
  }
}
