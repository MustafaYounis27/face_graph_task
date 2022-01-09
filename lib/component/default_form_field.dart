import 'package:flutter/material.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required String title,
}) =>
    Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          15.0,
        ),
        border: Border.all(
          width: 1.0,
          color: Colors.grey,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: InputDecoration(
          hintText: title,
          border: InputBorder.none,
        ),
      ),
    );