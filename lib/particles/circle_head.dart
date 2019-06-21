import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flugram/main.dart';
import 'package:flugram/pages/profile_page.dart';

class CircleHead extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CircleHead();
}

class _CircleHead extends State<CircleHead> {
  String filename = "", username;
  int user_id;

  @override
  dispose() {
    _subsc?.cancel();
    super.dispose();
  }

  var _subsc;
  @override
  void initState() {
    super.initState();

    client.sendRequest(
        {'@type': 'getMe'},
        () => (var received) {
              user_id = received["id"];
              username = received["first_name"];
              if (!received["profile_photo"]["small"]['local']
                  ['is_downloading_completed']) {
                _subsc = client.streamController.stream.listen((data) async {
                  var recJson = json.decode(data);
                  if (recJson["@type"] == "updateFile" &&
                      received["profile_photo"]["small"]['id'] ==
                          recJson['file']['id'] &&
                      recJson['file']['local']['is_downloading_completed']) {
                    _subsc.cancel();
                    filename = recJson['file']['local']['path'];
                    setState(() {});
                  }
                });
                client.sendRequest({
                  '@type': 'downloadFile',
                  'file_id': received["profile_photo"]["small"]['id'],
                  'priority': 32
                }, () => (var r) {});
              } else {
                print("this is the else workd");
                filename = received["profile_photo"]["small"]["local"]["path"];
                setState(() {});
              }
            });
  }

  void onPressed() {
    print("tapped on propic");
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return ProfilePage(filename, user_id, username);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onPressed,
        child: Container(
            height: 50.0,
            width: 50.0,
            padding: EdgeInsets.all(5.0),
            child: Hero(
                tag: 'imageHero',
                child: filename == ""
                    ? CircleAvatar(
                        backgroundColor: Colors.blueGrey,
                        radius: 40.0,
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.blueGrey,
                        radius: 40.0,
                        backgroundImage: FileImage(File(filename)),
                      ))));
  }
}
