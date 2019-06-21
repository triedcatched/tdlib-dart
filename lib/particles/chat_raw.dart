import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flugram/main.dart';
import 'package:flugram/pages/chat_page.dart';
import 'package:flugram/particles/chat.dart';

void onTappedItem(Chat chat, BuildContext context) {
  print("Tapped here");

  Navigator.push(context, MaterialPageRoute(builder: (_) {
    return ChatPage(chat);
  }));
}

class ChatRow extends StatefulWidget {
  Chat chat;
  void Function(Chat, TextEditingController) onLongPresse;
  ChatRow(this.chat, this.onLongPresse);
  @override
  State<StatefulWidget> createState() => _ChatRow();
}

class _ChatRow extends State<ChatRow> {
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

    if (widget.chat.profilePic == "") {
      Chat _chat_temp = widget.chat;
      client.sendRequest(
          {'@type': 'getChat', 'chat_id': _chat_temp.id},
          () => (var _chat) {
                if (_chat['photo'] != null) {
                  print(_chat['photo']['small']['local']['path']);
                  if (_chat['photo']['small']['local']['path'] == "") {
                    _subsc =
                        client.streamController.stream.listen((data) async {
                      var recJson = json.decode(data);
                      if (recJson["@type"] == "updateFile" &&
                          _chat['photo']['small']['id'] ==
                              recJson['file']['id'] &&
                          recJson['file']['local']
                              ['is_downloading_completed']) {
                        _subsc.cancel();
                        _chat_temp.profilePic =
                            recJson['file']['local']['path'];
                        setState(() {});
                        chats.addChat(_chat_temp);
                      }
                    });
                    client.sendRequest({
                      '@type': 'downloadFile',
                      'file_id': _chat['photo']['small']['id'],
                      'priority': 32
                    }, () => (var r) {});
                  }
                } else {
                  _chat_temp.profilePic = null;
                  chats.addChat(_chat_temp);
                }
              });
    }
  }

  TextEditingController label_controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    var timestamp =
        DateTime.fromMicrosecondsSinceEpoch((widget.chat.date * 1000000));
    String processedTime = timestamp.hour.toString() + ":";
    if (timestamp.minute.toString().length == 1)
      processedTime = processedTime + "0";
    processedTime = processedTime + timestamp.minute.toString();
    return Container(
        child: Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 1.0, top: 5.0),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        // // crossAxisAlignment: CrossAxisAlignment.baseline,
        // mainAxisSize: MainAxisSize.max,
        // // crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            // height: 50.0,
            // width: 50.0,
            padding: EdgeInsets.only(right: 5.0),
            child: (widget.chat.profilePic == null ||
                    widget.chat.profilePic == "")
                ? CircleAvatar(
                    child: (widget.chat.title == "")
                        ? Text("deleted!")
                        : Text(widget.chat.title[0]),
                    backgroundColor: Colors.blueGrey,
                    radius: 20.0,
                  )
                : CircleAvatar(
                    backgroundImage: FileImage(File(widget.chat.profilePic)),
                    backgroundColor: Colors.blueGrey,
                    radius: 20.0,
                  ),
          ),
          Expanded(
            child: InkWell(
              onLongPress: () =>
                  widget.onLongPresse(widget.chat, label_controller),
              onTap: () => onTappedItem(widget.chat, context),
              child: Container(
                // height: maxHeight,
                // color: Colors.blue,

                // decoration: BoxDecoration(
                //   gradient: LinearGradient(
                //     begin: Alignment.topLeft,
                //     end: Alignment.bottomRight,
                //     colors: [Colors.black, Colors.white]
                //   )
                // ),

                child: Stack(
                  children: <Widget>[
                    Positioned(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.chat.title,
                              style: new TextStyle(
                                  fontWeight: (widget.chat.unread_count > 0)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 17.0,
                                  color: (widget.chat.unread_count > 0)
                                      ? Colors.black
                                      : Colors.black38)),
                          Text(widget.chat.lastMessage,
                              maxLines: 2,
                              style: new TextStyle(
                                  fontWeight: (widget.chat.unread_count > 0)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 12.0,
                                  // color: ((widget.chat.unread_count > 0)
                                  //     ? Colors.black
                                  //     : Colors.black38),

                                  foreground: Paint()
                                    ..shader = LinearGradient(colors: [
                                      Colors.black,
                                      Colors.white
                                    ]).createShader(Rect.fromLTWH(0, 0,
                                        MediaQuery.of(context).size.width, 1))))
                        ],
                      ),
                      top: 0.0,
                      left: 0.0,
                    ),
                    // Positioned(
                    //   child: Container(
                    //     // width: 1.0,
                    //     // height: 1.0,
                    //     child: Icon(
                    //       widget.chat.chatType == "chatTypePrivate"
                    //           ? Icons.person
                    //           : widget.chat.chatType == "chatTypeChannel"
                    //               ? Icons.group_work
                    //               : Icons.people,
                    //       size: 15,
                    //     ),
                    //   ),
                    //   top: 0.0,
                    //   right: 0.0,
                    // ),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  // new Container(
                  //   // padding: new EdgeInsets.all(2.0),
                  //   child: new Icon(
                  //     Icons.access_time,
                  //     size: 10.0,
                  //   ),
                  // ),
                  new Container(
                    // padding: new EdgeInsets.all(2.0),

                    child: Text(processedTime),
                  ),
                ],
              ),
              widget.chat.unread_count > 0
                  ? Container(
                      height: 14.0,
                      padding: EdgeInsets.only(top: 2, right: 2.5, left: 2.5),
                      decoration: new BoxDecoration(
                        color: Colors.grey,
                        // color: animation.value,
                        borderRadius:
                            new BorderRadius.all(const Radius.circular(5)),
                      ),
                      child: Text(widget.chat.unread_count.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 10.0)))
                  : Container(),
              // IconButton(
              //   // alignment: Alignment.topRight,
              //   //  alignment: new FractionalOffset(10.0, 10.0),
              //   icon: Icon(Icons.star),
              //   color: Colors.white,
              // )
            ],
          )
        ],
      ),
    ));
  }
}
