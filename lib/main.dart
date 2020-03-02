import 'package:flutter/material.dart';

import './screens/map_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Maps',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        accentColor: Colors.lightBlue,
      ),
      home: MapScreen(),
    );
  }
}

