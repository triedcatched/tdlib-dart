import 'dart:convert';

import 'package:flugram/main.dart';

class Chat {
  int id;
  String title = "";
  String chatType = "";
  String lastMessage = "";
  String profilePic = "";
  int unread_count = 0;
  int date = 0;
  int order = 0;
  List labels = new List();

  Chat(receivedJson) {
    var _chat = receivedJson['chat'];
    // print(_chat['photo']);
    if (_chat['photo'] != null) {
      if (_chat['photo']['small']['local']['path'] != null) {
        this.profilePic = _chat['photo']['small']['local']['path'];
      }
    }
    this.id = _chat['id'];
    this.chatType = _chat['type']['@type'];
    this.title = _chat['title'];
    this.order = int.parse(_chat['order']);
    this.unread_count = _chat['unread_count'];

    switch (_chat['type']['@type']) {
      case "chatTypeBasicGroup":
        this.chatType = "chatTypeBasicGroup";
        break;
      case "chatTypePrivate":
        this.chatType = "chatTypePrivate";
        break;
      case "chatTypeSupergroup":
        if (_chat['type']['is_channel'])
          this.chatType = "chatTypeChannel";
        else
          this.chatType = "chatTypeSuperGroup";
        break;
    }
    if (_chat['client_data'] != "") {
      print("===================\nClient Data:");
      print(_chat['client_data']);
      var client_data = json.decode(_chat['client_data']);
      List _labels = client_data['labels'];
      for (String s in _labels) {
        String st = s.trim();
        if (st != "") {
          if (!this.labels.contains(st)) this.labels.add(st);
        }
      }
    }
  }
}

class Chats {
  List<Chat> chats = new List<Chat>();

  Chat get(int i) {
    return chats[i];
  }

  void updateChat(int chat_id) {
    client.sendRequest(
        {
          '@type': 'getChat',
          'chat_id': chat_id,
        },
        () => (var _chat) {
              var client_data = _chat['client_data'] != ""
                  ? json.decode(_chat['client_data'])
                  : {};
              int _chatExist = 0;
              for (int i = 0; i < chats.length; i++) {
                if (chats[i].id == chat_id) {
                  _chatExist = 1;
                  chats[i].labels = client_data['labels'];
                  return;
                }
              }
              if (_chatExist == 0) {
                print("SOMETHING IS TERRIBLY WRONG SOMEWHERE!!!!!");
              }
            });
  }

  int getInboxUnread() {
    print("Getting unread inbox count");
    int count = 0;
    for (Chat c in chats) {
      count += c.unread_count;
    }
    return count;
  }

  List getCountsArray() {
    int total = 0;
    int private = 0;
    int basic = 0;
    int supergroup = 0;
    int channel = 0;
    Map<String, int> labmap = new Map();

    for (Chat c in chats) {
      switch (c.chatType) {
        case "chatTypePrivate":
          private += c.unread_count;
          break;
        case "chatTypeBasicGroup":
          basic += c.unread_count;
          break;
        case "chatTypeChannel":
          channel += c.unread_count;
          break;
        case "chatTypeSuperGroup":
          supergroup += c.unread_count;
          break;
      }
      total += c.unread_count;
    }
    return [total, private, basic, supergroup, channel];
  }

  int getSize() {
    return chats.length;
  }

  void refreshOrder() {
    chats.sort((a, b) => b.order.compareTo(a.order));
  }

  void updateOrder(data) {
    int chatId = data['chat_id'];
    // String order = data['order'];
    for (int i = 0; i < chats.length; i++) {
      if (chats[i].id == chatId) {
        chats[i].order = int.parse(data['order']);
        break;
      }
    }

    this.refreshOrder();
  }

  void addChat(Chat chat) {
    int _chatExist = 0;
    for (int i = 0; i < chats.length; i++) {
      if (chats[i].id == chat.id) {
        _chatExist = 1;
        chats[i] = chat;
        return;
      }
    }
    if (_chatExist == 0) {
      chats.add(chat);
    }
    this.refreshOrder();
  }

  void updateLastMessage(recJson) {
    for (int i = 0; i < chats.length; i++) {
      if (chats[i].id == recJson['chat_id']) {
        if (recJson['last_message'] == null) {
          return;
        }
        var timestamp = DateTime.fromMicrosecondsSinceEpoch(
            (recJson['last_message']['date'] * 1000));
        chats[i].date = recJson['last_message']['date'];
        // timestamp.hour.toString() + ":" + timestamp.minute.toString();
        chats[i].order = int.parse(recJson['order']);
        // chats[i].unread_count = recJson['unread_count'];

        // print(recJson['last_message']['content']);
        // ToDo check other types of messages too
        try {
          if (recJson['last_message']['content'] != null &&
              recJson['last_message']['content']['text'] != null &&
              recJson['last_message']['content']['text']['text'] != null)
            chats[i].lastMessage =
                (recJson['last_message']['content']['text']['text']);
        } catch (e) {}
        break;
      }
    }
    this.refreshOrder();
  }

  void updateChatReadInbox(recJson) {
    for (int i = 0; i < chats.length; i++) {
      if (chats[i].id == recJson['chat_id']) {
        chats[i].unread_count = recJson['unread_count'];
        return;
      }
    }
  }
}
