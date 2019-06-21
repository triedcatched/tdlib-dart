import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flugram/main.dart';
import 'package:flugram/particles/chat.dart';
import 'package:flugram/particles/chat_message.dart';

// Client client;
class ChatPage extends StatefulWidget {
  final Chat chat;
  ChatPage(this.chat);

  @override
  State<StatefulWidget> createState() => _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  var chats = new Chats();

  final TextEditingController textEditingController =
      new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  void _handleSubmit(String text) {
    // loadMore();
    textEditingController.clear();
    print(text);
    client.sendRequest(
        {
          '@type': 'sendMessage',
          'chat_id': widget.chat.id,
          'input_message_content': {
            '@type': 'inputMessageText',
            'text': {'@type': 'formattedText', 'text': text}
          }
        },
        () => (var r) {
              print(r);
            });
    // ChatMessage chatMessage =
    //     new ChatMessage(title: widget.chat.title, text: text);
    // setState(() {
    //   //used to rebuild our widget
    //   _messages.insert(0, chatMessage);
    // });
  }

  Widget _textComposerWidget() {
    return new IconTheme(
      data: new IconThemeData(color: Colors.blue),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                decoration: new InputDecoration.collapsed(
                    hintText: "Enter your message"),
                controller: textEditingController,
                onSubmitted: _handleSubmit,
              ),
            ),
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => _handleSubmit(textEditingController.text),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  dispose() {
    _subsc?.cancel();
    super.dispose();
  }

  var _subsc;

  @override
  void initState() {
    super.initState();

    _subsc = client.streamController.stream.listen((data) async {
      var recJson = json.decode(data);
      print(recJson['@type']);
      if (recJson['@type'] == 'updateNewMessage') {
        if (recJson['message']['chat_id'] != widget.chat.id) return;
        ChatMessage chatMessage;
        try {
          chatMessage = new ChatMessage(
            title: recJson['message']['sender_user_id'].toString(),
            text: recJson['message']['content']['text']['text'].toString(),
            is_outgoing: recJson['message']['is_outgoing'],
            chatType: widget.chat.chatType,
          );
        } catch (e) {
          chatMessage = new ChatMessage(
              title: recJson['message']['sender_user_id'].toString(),
              text: json.encode(recJson),
              is_outgoing: recJson['message']['is_outgoing'],
              chatType: widget.chat.chatType);
        }
        setState(() {
          //used to rebuild our widget
          _messages.insert(0, chatMessage);
        });
      }
    });

    loadMore();
  }

  int current_last_msg = 0;
  bool end_reached = false;
  bool is_loading = false;
  void loadMore() {
    if (is_loading) return;
    is_loading = true;
    print("Load more?");

    if (end_reached) {
      print("ended long back! not loading more");
      return;
    }
    client.sendRequest(
        {
          '@type': 'getChatHistory',
          'chat_id': widget.chat.id,
          // 'from_message_id': 9,
          'from_message_id': current_last_msg,
          'offset': 0,
          // 'offset': 0,
          'limit': 50,
          // 'limit': 5,
        },
        () => (var received) {
              // print("\n\nThis is the result:\n========");
              // print(received);
              if (received['total_count'] == 0) {
                end_reached = true;
                return;
              }
              // print(received['messages'][0]['id']);
              // print(received['messages'][0]);
              // print(received['messages'][0]['sender_user_id']);
              // print(received['messages'][0]['content']);
              // print(received['messages'][0]['content']['text']['text']);
              ChatMessage chatMessage;
              for (int i = 0; i < received['total_count']; i++) {
                current_last_msg = received['messages'][i]['id'];
                try {
                  chatMessage = new ChatMessage(
                    title: received['messages'][i]['sender_user_id'].toString(),
                    text: received['messages'][i]['content']['text']['text']
                        .toString(),
                    is_outgoing: received['messages'][i]['is_outgoing'],
                    chatType: widget.chat.chatType,
                  );
                } catch (e) {
                  chatMessage = new ChatMessage(
                      title:
                          received['messages'][i]['sender_user_id'].toString(),
                      text: "unknown message type"+json.encode(received['messages'][i]),
                      is_outgoing: received['messages'][i]['is_outgoing'],
                      chatType: widget.chat.chatType);
                }

                setState(() {
                  //used to rebuild our widget
                  _messages.add(chatMessage);
                });
              }
              is_loading = false;
              if (received['total_count'] < 50) {
                loadMore();
              }
            });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Tele Y',
        // navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: Colors.white,
            fontFamily: "Quicksand",
            primarySwatch: Colors.purple),
        // routes: <String, WidgetBuilder>{
        //   "/mytabs": (BuildContext _context) => new ProfilePage(),
        // },

        home: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_left),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(widget.chat.title),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  tooltip: 'Search',
                  // onPressed: _restitchDress,
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  tooltip: 'more',
                  // onPressed: _repairDress,
                ),
              ],
            ),
            // key: _scaffoldContext,
            body: Column(
              children: <Widget>[
                new Flexible(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      // print("some notification came");

                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                        print("maxed out already");
                        loadMore();
                      }
                    },
                    child: new ListView.builder(
                      padding: new EdgeInsets.all(8.0),
                      reverse: true,
                      itemBuilder: (_, int index) => _messages[index],
                      itemCount: _messages.length,
                    ),
                  ),
                ),
                new Divider(
                  height: 1.0,
                ),
                new Container(
                  decoration: new BoxDecoration(
                    color: Theme.of(context).cardColor,
                  ),
                  child: _textComposerWidget(),
                )
              ],
            )));
  }
}
