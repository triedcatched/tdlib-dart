import 'dart:async';
import 'dart:convert';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:synchronized/synchronized.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

const platform = const MethodChannel('channel/to/betaturtle/in');
int clientId;

class Client {
  int _client_id;
  int _request_id = 0;
  bool _loopReceive = false;
  List _requests = new List();
  var _lock = new Lock();
  Directory appDocDir;
  Directory appExtDir;

  StreamController<String> streamController;

  Client() {
    _createClient();
    streamController = new StreamController.broadcast();
  }

  Future<void> _createClient() async {
    if (_client_id == null) {
      try {
        print("Creating client");
        _client_id = await platform.invokeMethod('createClient');
        print("created client");
        PermissionStatus res = await SimplePermissions.requestPermission(
            Permission.WriteExternalStorage);
        print("Permission status");
//        print(res);
        appDocDir = await getApplicationDocumentsDirectory();
        appExtDir = await getExternalStorageDirectory();
        streamController.add("ClientStarted");
        startReceive();
      } on PlatformException catch (e) {
        print(e);
      }
    }
  }

  stopReceive() {
    _loopReceive = false;
  }

  Future<void> startReceive() async {
    if (_loopReceive) return;
    _loopReceive = true;
    while (_loopReceive) {
      try {
        String res = await platform.invokeMethod('clientReceive', <String, int>{
          'client_id': _client_id,
        });
        // print(res);
        var receivedJson = json.decode(res);
        await _lock.synchronized(() async {
          for (int i = 0; i < _requests.length; i++) {
            if (_requests[i][0] == receivedJson['@extra']) {
              var f = _requests[i][1]();
              f(receivedJson);
              _requests.removeAt(i);
              break;
            }
          }
        });
        streamController.add(res);
      } on PlatformException catch (e) {
        print("That receive didnt work ");
        print(e);
      }
    }
  }

  Future<void> sendRequest(var request, VoidCallback callback) async {
    print("\n\nsendRequest:");
    print(request);
    if (callback != null) {
      await _lock.synchronized(() async {
        _request_id++;
        // request.addEntrd();
        request['@extra'] = _request_id.toString();
        _requests.add([_request_id.toString(), callback]);
      });
    }
    try {
      await platform.invokeMethod('clientSend', <String, Object>{
        'client_id': _client_id,
        'to_send': json.encode(request)
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }
}
