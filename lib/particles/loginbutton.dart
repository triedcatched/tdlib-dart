import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  String buttonText;
  var testFun;
  AnimatedButton(_buttonText, VoidCallback _testFun) {
    this.buttonText = _buttonText;
    this.testFun = _testFun;
  }

  @override
  State<StatefulWidget> createState() => _AnimatedButton();
}

class _AnimatedButton extends State<AnimatedButton>
    with TickerProviderStateMixin {
  AnimationController controller;

  Animation buttomZoomOut;
  Animation buttonSqueezeanimation;

  @override
  void initState() {
    super.initState();

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

  @override
  dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    await controller.forward();
    await controller.reverse();

    print("tapped");
    var testFun1 = widget.testFun();
    print(testFun1);
    testFun1("yolo");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(18.0),
            child: TextField(
              keyboardType: TextInputType.phone,
              style: new TextStyle(fontSize: 25.0, color: Colors.black),
              decoration: new InputDecoration(
                  hintText: "",
                  labelText: "Phone number",
                  labelStyle: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          InkWell(
              onTap: () {
                print("Tapped");
                _playAnimation();
              },
              child: Container(
                width: buttonSqueezeanimation.value,
                height: 60.0,
                // decoration: new BoxDecoration(color: animation.value),
                alignment: FractionalOffset.center,
                decoration: new BoxDecoration(
                  color: Colors.black,
                  // color: animation.value,
                  borderRadius:
                      new BorderRadius.all(const Radius.circular(30.0)),
                ),
                child: buttonSqueezeanimation.value > 80.0
                    ? new Text(
                        widget.buttonText,
                        style: new TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.3,
                        ),
                      )
                    : new CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white)),
              ))
        ],
      ),
    );
  }
}
