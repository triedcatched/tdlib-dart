import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flugram/main.dart';
import 'package:flugram/particles/circle_head.dart';

// void main() => runApp(HeroApp());

class HomePage extends StatelessWidget {
  HomePage() {
    client.startReceive();
  }

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
        home: Scaffold(
            body: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
              Container(
                height: 50,
                color: Colors.black,
              ),
              Container(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(color: Colors.black54, width: 2.0)),
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                      ),
                      Text("Tap here to search.."),
                      CircleHead(),
                    ],
                  ),
                ),
                padding: EdgeInsets.all(10.0),
                // color: Colors.grey,
              ),
              Flexible(
                child: 
                CustomScrollView(
  slivers: <Widget>[
    new SliverAppBar(
      pinned: true,
      expandedHeight: 250.0,
      flexibleSpace: new FlexibleSpaceBar(
        title: new Text("sdfasdf"),
        // background: new Image.network(_imageUrl),
      ),
    ),
    new SliverPadding(
      padding: new EdgeInsets.all(16.0),
      sliver: new SliverList(
        delegate: new SliverChildListDelegate([
          new Text("asdfasdf"),
          new Text("sfdasf"),
          new Text("asdfasfd"),
          new Text("asdfasdfasdf"),
        ]),
      ),
    ),
  ],
),
              )
            ])));
    // return MaterialApp(
    //   title: 'Transition Demo',
    //   home: MainScreen(),
    // );
  }
}

// class MainScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Main Screen'),
//       ),
//       body: GestureDetector(
//         child: Hero(
//           tag: 'imageHero',
//           child: Image.network(
//             'https://picsum.photos/250?image=9',
//           ),
//         ),
//         onTap: () {
//           Navigator.push(context, MaterialPageRoute(builder: (_) {
//             return DetailScreen();
//           }));
//         },
//       ),
//     );
//   }
// }

// class DetailScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GestureDetector(
//         child: Center(
//           child: Hero(
//             tag: 'imageHero',
//             child: Image.network(
//               'https://picsum.photos/250?image=9',
//             ),
//           ),
//         ),
//         onTap: () {
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }
// }
