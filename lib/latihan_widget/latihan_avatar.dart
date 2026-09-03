import 'package:flutter/material.dart';

class LatihanAvatar extends StatelessWidget {
  const LatihanAvatar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aplikasi GIBRUN"),
        backgroundColor: Colors.orange,
        leading: Icon(Icons.arrow_back, color: Colors.white, size: 50),
        actions: [Icon(Icons.view_headline, color: Colors.black, size: 50)],
      ),
      body: Center(
        child: CircleAvatar(
          radius: 180,
          backgroundColor: Colors.amberAccent,
          backgroundImage: AssetImage("assets/image/a.jpg"),
        ),
      ),
    );
  }
}
