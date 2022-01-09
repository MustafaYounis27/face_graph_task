import 'package:flutter/material.dart';

Widget slidBackground(bool isRight) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: 10.0,
    ),
    color: Colors.red,
    child: Row(
      mainAxisAlignment:
      isRight ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Icon(
          Icons.delete,
          color: Colors.white,
        ),
        Text(
          'Delete',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}