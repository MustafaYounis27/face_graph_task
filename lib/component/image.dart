
import 'package:flutter/material.dart';

Widget customImage(image) => Container(
  height: 100.0,
  width: 100.0,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(
      15.0,
    ),
    border: Border.all(
      width: 1.0,
      color: Colors.grey,
    ),
    image: DecorationImage(
      fit: BoxFit.fill,
      image: FileImage(
        image,
      ),
    ),
  ),
);