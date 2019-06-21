import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flugram/main.dart';
import 'package:flugram/particles/app_bar.dart';
import 'package:flugram/particles/chat.dart';
import 'package:flugram/particles/chat_raw.dart';
import 'package:flugram/particles/drawer.dart';

class MyScaf extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyScaf();
}

class _MyScaf extends State<MyScaf> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  dispose() {
    _subsc.cancel();
    super.dispose();
  }

  var _subsc;

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);

    _subsc = client.streamController.stream.listen((data) async {
      var recJson = json.decode(data);

      switch (recJson["@type"]) {
        case "updateChatLastMessage":
          chats.updateLastMessage(recJson);
          // print(recJson);
          setState(() {});
          break;
        case "updateNewChat":
          chats.addChat(new Chat(recJson));
          setState(() {});
          break;
        case "updateChatOrder":
          chats.updateOrder(recJson);
          setState(() {});
          // print(recJson);
          break;
        case "updateChatReadInbox":
          chats.updateChatReadInbox(recJson);
          break;
        default:
          // print(recJson["@type"]);
          break;
      }
    });

    client.sendRequest(
        {
          '@type': 'getChats',
          'offset_order': offset_order,
          'offset_chat_id': offset_chat_id,
          'limit': 100,
        },
        () => (var received) {
              print(received);
              chats.refreshOrder();
              print(chats.chats[chats.chats.length-1].order);
              print(chats.chats[chats.chats.length-1].id);
              print(chats.chats[chats.chats.length-1].title);
              print(chats.chats.length);
              offset_chat_id = chats.chats[chats.chats.length-1].id;
              offset_order = chats.chats[chats.chats.length-1].order;
            });

    super.initState();

    // Chat c1 = new Chat.man();
    // c1.title = "Title yo";
    // c1.lastMessage = "once upon a time there was a message";
    // c1.profilePic = "";
    // chats.addChat(c1);
  }
  int offset_chat_id = 0;
  int offset_order = (pow(2, 63) - 1);

  String current_page = "Inbox";

  void drawerCallback(String c) {
    print("Called callback");
    current_page = c;
    print(c);
    cur_chats = new List();
    for (Chat _c in chats.chats) {
      switch (c) {
        case "Inbox":
          cur_chats.add(_c);
          break;
        case "Unread":
          if (_c.unread_count > 0) cur_chats.add(_c);
          break;
        case "Private Chats":
          if (_c.chatType == "chatTypePrivate") cur_chats.add(_c);
          break;
        case "Basic Groups":
          if (_c.chatType == "chatTypeBasicGroup") cur_chats.add(_c);
          break;
        case "Super Groups":
          if (_c.chatType == "chatTypeSuperGroup") cur_chats.add(_c);
          break;
        case "Channels":
          if (_c.chatType == "chatTypeChannel") cur_chats.add(_c);
          break;
        default:
          break;
      }
      if (_c.labels.contains(c)) cur_chats.add(_c);
      setState(() {});
    }
  }

  void onLongPresse(Chat chat, TextEditingController label_controller) {
    print("long pressed");
    print(chat);
    label_controller.text = "";

    client.sendRequest(
        {
          '@type': 'getChat',
          'chat_id': chat.id,
        },
        () => (var r) {
              var client_data =
                  r['client_data'] != "" ? json.decode(r['client_data']) : {};
              if (client_data['labels'] != null) {
                for (String l in client_data['labels']) {
                  label_controller.text = label_controller.text + l + ", ";
                }
              }
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  // return object of type Dialog
                  return AlertDialog(
                    title: new Text("Labels"),
                    content: TextField(controller: label_controller),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text("Save"),
                        onPressed: () {
                          client_data['labels'] = [];
                          List<String> splitted =
                              label_controller.text.split(",");
                          for (String s in splitted) {
                            String st = s.trim();
                            print(st);
                            if (st != "") {
                              if (!client_data['labels'].contains(st))
                                client_data['labels'].add(st);
                              // if (!globaLabels.contains(st))
                              //   globaLabels.add(st);
                            }
                          }
                          chat.labels = client_data['labels'];
                          chats.addChat(chat);
                          client.sendRequest(
                              {
                                '@type': 'setChatClientData',
                                'chat_id': chat.id,
                                'client_data': json.encode(client_data),
                              },
                              () => (var r) {
                                    drawerCallback(current_page);
                                    chats.updateChat(chat.id);
                                    setState(() {});
                                  });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            });
  }

  ScrollController _controller;

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      print("Reach bottom");
      client.sendRequest(
        {
          '@type': 'getChats',
          'offset_order': offset_order,
          'offset_chat_id': offset_chat_id,
          'limit': 100,
        },
        () => (var received) {
              print(received);
              chats.refreshOrder();
              print(chats.chats[chats.chats.length-1].order);
              print(chats.chats[chats.chats.length-1].id);
              print(chats.chats[chats.chats.length-1].title);
              print(chats.chats.length);
              offset_chat_id = chats.chats[chats.chats.length-1].id;
              offset_order = chats.chats[chats.chats.length-1].order;
            });
            
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      print("Reach top");
    }
  }

  List<Chat> cur_chats = chats.chats;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.white,
        drawer: LeftDraw(drawerCallback),
        key: _scaffoldKey,
        body: CustomScrollView(
          controller: _controller,
          slivers: <Widget>[
            MyAppBar(_scaffoldKey),
            // Text("sadfasf"),
            SliverFixedExtentList(
              itemExtent: 70.0,
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return ChatRow(cur_chats[index], onLongPresse);
                },
                childCount: cur_chats.length,
              ),
            ),
          ],
        ));
  }
}
