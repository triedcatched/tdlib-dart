import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flugram/particles/chat.dart';
import 'package:flugram/utils.dart';
import 'package:flugram/pages/home_page.dart';
import 'package:flugram/pages/login_page.dart';


Client client;
Chats chats = new Chats();


void main() {


  client = new Client();

  var subsc;
  subsc = client.streamController.stream.listen((data) async {
    if (data == "ClientStarted") {
      var req = {'@type': 'getAuthorizationState'};
      client.sendRequest(req, () => checkAuth);
      subsc.cancel();
      return;
    }
    var recJson = json.decode(data);
    // if(recJson["@type"] == "updateAuthorizationState"){
    //   testFun(recJson["authorization_state"]);
    //   return;
    // }
  });
}

void checkAuth(var received) {
  switch (received['@type']) {
    case "authorizationStateWaitTdlibParameters":
      client.sendRequest({
        '@type': 'setTdlibParameters',
        'parameters': {
          'use_test_dc': false,
          'api_id': 94575,
          'api_hash': 'a3406de8d171bb422bb6ddf3bbd800e2',
          'device_model': 'deviceModelHere',
          'system_version': 'SysVersion',
          'application_version': "0.1",
          'system_language_code': 'en',
          'database_directory': client.appDocDir.path,
          // 'database_directory': client.appExtDir.path + "/tgy",
          'files_directory': client.appExtDir.path + "/tgy",
          'use_file_database': true,
          'use_chat_info_database': true,
          'use_message_database': true,
          'ignore_file_names': true
        }
      }, () => checkAuth);
      break;
    case "authorizationStateWaitEncryptionKey":
      client.sendRequest({
        '@type': 'checkDatabaseEncryptionKey',
        'encryption_key': 'mostrandomencryption'
      }, () => checkAuth);

      break;
    case "authorizationStateReady":
      client.stopReceive();
      // runApp(HomePage());
      runApp(HomePage());
      break;
    case "authorizationStateWaitPhoneNumber":
    case "authorizationStateWaitCode":
    case "authorizationStateWaitPassword":
      client.stopReceive();
      // runApp(LoginPage(client));
      runApp(EnterNumberPage());
      
      break;
    case "ok":
      client.sendRequest({'@type': 'getAuthorizationState'}, () => checkAuth);
      break;
    default:
  }
  print(received);
}