import 'package:flutter/material.dart';
import 'package:flugram/particles/circle_head.dart';

Widget MyAppBar(GlobalKey<ScaffoldState> _scaffoldKey) {
  return SliverAppBar(
    leading: new Container(),
    floating: true,
    elevation: 0.0,
    expandedHeight: 70.0,
    backgroundColor: Colors.transparent,
    flexibleSpace: FlexibleSpaceBar(
      background: SafeArea(
          child: Column(children: <Widget>[
        Container(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
                boxShadow: [
                  new BoxShadow(
                    color: Colors.black38,
                    blurRadius: 10.0,
                  ),
                ]),
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  // padding: EdgeInsets.only(left: 15.0),
                  child: IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () => _scaffoldKey.currentState.openDrawer(),
                    color: Colors.grey,
                  ),
                ),
                Text("Search "),
                CircleHead(),
              ],
            ),
          ),
          padding: EdgeInsets.all(10.0),
          // color: Colors.grey,
        ),
      ])),
    ),
  );
}
