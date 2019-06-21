import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flugram/main.dart';
import 'package:flugram/particles/title_section.dart';
import 'package:flugram/utils.dart';
import 'package:flugram/particles/chat.dart';
import 'package:flugram/particles/chat_raw.dart';

// Client client;
class ProfilePage extends StatefulWidget {

  final String filename, username;
  final int current_user_id;
  ProfilePage(this.filename, this.current_user_id, this.username);


  @override
  State<StatefulWidget> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  var chats = new Chats();

  // int current_user_id;
  @override
  void initState() {
    super.initState();
    client.startReceive();
    filename = widget.filename;

    print("that long number:");
    print(pow(2, 63) - 1);
    onPressd();

    // client.sendRequest(
    //     {'@type': 'getMe'},
    //     () => (var received) {
    //           username = received["first_name"];
    //           current_user_id = received["id"];
    //           setState(() {});
    //           onPressd();
    //           if (!received["profile_photo"]["small"]['local']
    //               ['is_downloading_completed']) {
    //             var _subsc;
    //             _subsc = client.streamController.stream.listen((data) async {
    //               var recJson = json.decode(data);
    //               if (recJson["@type"] == "updateFile" &&
    //                   received["profile_photo"]["small"]['id'] ==
    //                       recJson['file']['id'] &&
    //                   recJson['file']['local']['is_downloading_completed']) {
    //                 _subsc.cancel();
    //                 filename = recJson['file']['local']['path'];
    //                 setState(() {});
    //               }
    //             });
    //             client.sendRequest({
    //               '@type': 'downloadFile',
    //               'file_id': received["profile_photo"]["small"]['id'],
    //               'priority': 32
    //             }, () => (var r) {});
    //           } else {
    //             print("this is the else workd");
    //             filename = received["profile_photo"]["small"]["local"]["path"];
    //             setState(() {});
    //           }
    //         });

    // clientSend({'@type': 'getAuthorizationState', '@extra': 1.01234});
    // clientSend({
    //   '@type': 'getChats',
    //   'offset_order': (pow(2, 63) - 1),
    //   'offset_chat_id': 0,
    //   'limit': 10,
    //   '@extra': "getchatresultfor10"
    // });
  }

  String filename = "";
  void onPressdelete() {
    print("\n\ndeleting " + filename);
    File f = File(filename);
    f.delete();
  }

  var pro_pics = [];

  void proPicDownloader(file) {
    print("==================downlaoder\n\n");
    print(pro_pics);
    if (!file['local']['is_downloading_completed']) {
      var _subsc;
      _subsc = client.streamController.stream.listen((data) async {
        var recJson = json.decode(data);
        if (recJson["@type"] == "updateFile" &&
            file['id'] == recJson['file']['id'] &&
            recJson['file']['local']['is_downloading_completed']) {
          _subsc.cancel();
          if (!pro_pics.contains(recJson['file']['local']['path']))
            pro_pics.add(recJson['file']['local']['path']);
          // filename = recJson['file']['local']['path'];
          setState(() {});
        }
      });
      client.sendRequest(
          {'@type': 'downloadFile', 'file_id': file['id'], 'priority': 32},
          () => (var r) {});
    } else {
      if (!pro_pics.contains(file["local"]["path"]))
        pro_pics.add(file["local"]["path"]);
      setState(() {});
    }
  }

  void onPressd() {
    print("pressed");
    // return;
    client.sendRequest(
        {
          '@type': 'getUserProfilePhotos',
          'user_id': widget.current_user_id,
          'limit': 50
        },
        () => (var r) {
              print("\n\nProfile pics\n\n");
              print(r);
              print("\n\n\nLength:");
              print(r['photos'].length);
              print(r['photos'][0]['sizes'][0]['photo']);
              for (var photo in r['photos']) {
                proPicDownloader(photo['sizes'][0]['photo']);
              }
              // proPicDownloader(r['photos'][1]['sizes'][0]['photo']);
              // for (var a in r['photos'][0]['sizes']) {
              //   print("\n\n");
              //   print(a);
              // }
            });
  }

  String username = "";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Tele Y',
        // navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: Colors.black,
            fontFamily: "Quicksand",
            primarySwatch: Colors.amber),
        // routes: <String, WidgetBuilder>{
        //   "/mytabs": (BuildContext _context) => new ProfilePage(),
        // },
        home: Scaffold(
            // key: _scaffoldContext,
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
              Container(
                height: 50,
                color: Colors.black,
              ),
              // profileHeader(),
              // FlatButton(
              //   child: Text("Press"),
              //   onPressed: onPressd,
              // ),
              // FlatButton(
              //   child: Text("delete"),
              //   onPressed: onPressdelete,
              // ),
              // Container(
              //   padding: const EdgeInsets.only(bottom: 80.0, left: 20.0),
              //   child: Text(
              //     'Welcome ' + username,
              //     style: TextStyle(
              //       color: Colors.grey[800],
              //     ),
              //   ),
              // ),

              Container(
                // height: deviceSize.height / 4,
                height: 190,
                width: double.infinity,
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    color: Colors.black,
                    child: FittedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50.0),
                                  border: Border.all(
                                      width: 2.0, color: Colors.white)),
                              child: Hero(
                                tag: 'imageHero',
                                child: CircleAvatar(
                                  radius: 40.0,
                                  backgroundImage: FileImage(File(filename)),
                                ),
                              )),
                          Hero(
                            tag: 'titleHero',
                            child: Text(
                              widget.username,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 25.0),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 210,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Profile photos",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 18.0),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: pro_pics.length,
                            itemBuilder: (context, i) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.file(File(pro_pics[i]))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ])));

//     return MaterialApp(
//       title: 'Tele Y',
//       home: Scaffold(
//           appBar: AppBar(
// //          backgroundColor: Color.fromRGBO(76, 38, 102, 1),
//             backgroundColor: Colors.black87,
//             title: Text('Tele Y'),
//           ),
//           body: ListView.builder(
//               itemCount: chats.chats.length,
//               itemBuilder: (BuildContext ctxt, int i) {
//                 return ChatRow(chats.chats[i]);
//               })),
//     );
  }

  void _getChats() {
    print("getChats" + chats.chats.length.toString());

    // chats.sortArray();
    for (Chat _c in chats.chats) {
      print(_c.id.toString() + "| " + _c.title + ": " + _c.order.toString());
    }
    // clientSend({
    //   '@type': 'getChats',
    //   'offset_order': 2 ^ 63 - 1,
    //   'offset_chat_id': 261619290,
    //   'limit': 10,
    //   '@extra': "getchatresultfor10"
    // });

    // clientSend({
    //   '@type': 'getChat',
    //   'chat_id': -14592208,
    //   '@extra': "getchatresultone"
    // });
  }
}

// ListView(
//             children: <Widget>[
//               ListTile(
//                 leading: Icon(Icons.map),
//                 title: Text('Map'),
//               ),
//               ListTile(
//                 leading: Icon(Icons.photo_album),
//                 title: Text('Album'),
//               ),
//               ListTile(
//                 leading: Icon(Icons.phone),
//                 title: Text('Phone'),
//               ),
//             ],
//           )
