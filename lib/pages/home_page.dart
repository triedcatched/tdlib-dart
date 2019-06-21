
import 'package:flutter/material.dart';
import 'package:flugram/main.dart';
import 'package:flugram/particles/chat.dart';
import 'package:flugram/particles/my_home_scaffold.dart';

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
            // fontFamily: "Quicksand",
            primarySwatch: Colors.amber),
        home: MyScaf());
  }
}
