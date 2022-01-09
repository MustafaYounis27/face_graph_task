import 'dart:convert';

import 'package:face_gragh_task/modules/home_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  static Map<String, Function> rules = {
    '/': (context, params) {
      return HomeScreen();
    },
  };

  static Route<dynamic>? getRoutes(RouteSettings settings) {
    final String? key = settings.name;
    final dynamic params = settings.arguments;
    final fn = rules[key];

    print("route: $key , ${jsonEncode(params)}");

    if (fn == null) {
      print("route not founded =============");
      return null;
    }

    return MaterialPageRoute(
      builder: (context) {
        return fn(context, params);
      },
    );
  }
}
