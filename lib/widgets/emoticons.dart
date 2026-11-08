import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Emoticons extends StatelessWidget {
  final String emoticons;
  const Emoticons({
    Key? key,
    required this.emoticons,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue[600],
      ),
      padding: EdgeInsets.all(12),
      child: Center(
          child: Text(
            emoticons,
              style: TextStyle(
                  fontSize: 28),
          ),
      ),
    );
  }
}
