import 'package:flutter/material.dart';
import 'package:flugram/main.dart';

class ChatMessage extends StatefulWidget {
  final String title, text, chatType;
  final bool is_outgoing;

  ChatMessage({this.text, this.title, this.is_outgoing, this.chatType});

  @override
  State<StatefulWidget> createState() => _ChatMessage();
}

class _ChatMessage extends State<ChatMessage> {
  String title = "";

  @override
  void initState() {
    super.initState();
    client.sendRequest(
        {
          '@type': 'getUser',
          'user_id': widget.title,
        },
        () => (var r) {
              print(r);
              setState(() {
                title = r['first_name'];
              });
            });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: Colors.grey[100],
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: widget.is_outgoing
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(right: 16.0),
                // child: new CircleAvatar(
                //   child: new Text(title[0]),
                // ),
              ),
              Container(
                  alignment: widget.is_outgoing
                      ? Alignment.topRight
                      : Alignment.topLeft,
                  margin: const EdgeInsets.only(top: 5.0),
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      widget.chatType == "chatTypePrivate" ||
                              widget.chatType == "chatTypeChannel"
                          ? Text("")
                          : Text(title,
                              style: Theme.of(context).textTheme.subhead),
                      Text(widget.text),
                    ],
                  )),
            ]));
  }
}
