import 'package:flutter/material.dart';

class TitleSection extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'FluGram',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Raleway",
                        fontSize: 32),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: Text(
                    'Yet Another Telegram Client!',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
          /*3*/
        ],
      ),
    );
  }
}
