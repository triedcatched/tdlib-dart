import 'package:flutter/material.dart';
import 'package:flugram/main.dart';
import 'package:flugram/particles/chat.dart';

class LeftDraw extends StatelessWidget {
  // final int inbox;
  // final int starred;
  // final int unmutted;
  List counts;
  void Function(String) drawerCallback;
  LeftDraw(this.drawerCallback);

  @override
  Widget build(BuildContext context) {

    counts = chats.getCountsArray();

    var drawerItems = [
      [Icons.inbox, "Inbox", 0, Colors.red.value],
      // [Icons.star, "Starred", 0, Colors.amber.value],
      [Icons.volume_up, "Unread", counts[0], Colors.lightBlueAccent.value],
      [],
      ["CATEGORIES"],
      [Icons.person, "Private Chats", counts[1]],
      [Icons.people, "Basic Groups", counts[2]],
      [Icons.group_work, "Super Groups", counts[3]],
      [Icons.announcement, "Channels", counts[4]],
      [],
      ["LABELS"],
      // [Icons.label, "Friends", 0],
      // [Icons.label, "Family", 0],
      // [Icons.label, "Work", 0],
    ];

    List<String> labels = new List();
    for (Chat _c in chats.chats){
      for(String l in _c.labels){
        if (!labels.contains(l)) labels.add(l);
      }
    }
    labels.sort();

    for(String l in labels){
      drawerItems.add([Icons.label, l, 0]);
    }

    return Drawer(
        child: SafeArea(
            child: Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 30.0, left: 20.0, bottom: 5),
          alignment: Alignment.topLeft,
          child: Text(
            "FluGram",
            style: TextStyle(fontSize: 20, color: Colors.red),
          ),
        ),
        Divider(height: 1),
        Expanded(
          flex: 2,
          child: ListView.builder(
              padding: EdgeInsets.only(top: 0.0),
              itemCount: drawerItems.length,
              itemBuilder: (context, position) {
                if (drawerItems[position].length == 0) {
                  return Divider(
                    height: 5.0,
                  );
                } else if (drawerItems[position].length == 1) {
                  return Container(
                    padding: EdgeInsets.only(left: 15.0, top: 5.0),
                    child: Text(
                      drawerItems[position][0],
                      style: TextStyle(
                        fontSize: 10,
                        // fontWeight: FontWeight.bold
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.only(top: 2.0, bottom: 2.0, right: 5.0),
                    child: Container(
                      // height: 40.0,
                      decoration: new BoxDecoration(
                          // color: Colors.red[100],
                          borderRadius: new BorderRadius.only(
                              bottomRight: const Radius.circular(40.0),
                              topRight: const Radius.circular(40.0))),
                      child: ListTile(
                        leading: Icon(
                          drawerItems[position][0],
                          color: drawerItems[position].length == 4
                              ? Color(drawerItems[position][3])
                              : Colors.grey,
                        ),
                        title: Text(drawerItems[position][1],
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.bold)),
                        trailing: (drawerItems[position][2] != 0)
                            ? Container(
                                // padding: EdgeInsets.only(left: 3.0, right: 3.0, bottom: 3.0),
                                padding: EdgeInsets.all(3.0),
                                decoration: new BoxDecoration(
                                    color: Colors.teal[600],
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(50.0))),
                                child: Text(
                                  drawerItems[position][2].toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.white),
                                ))
                            : Text(""),
                        onTap: () {
                          // setState(() {
                          //   titleBarContent = drawerText[position];
                          // });
                          Navigator.pop(context);
                          drawerCallback(drawerItems[position][1]);
                        },
                      ),
                    ),
                  );
                }
              }),
        )
      ],
    )));
  }
}
