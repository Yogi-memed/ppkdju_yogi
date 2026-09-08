import 'package:flutter/material.dart';

class Tugas1 extends StatelessWidget {
  const Tugas1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Saya"),
        backgroundColor: Colors.brown,
        leading: Icon(Icons.arrow_back, color: Colors.blueGrey, size: 50),
        actions: [Icon(Icons.view_headline, color: Colors.cyan, size: 52)],
      ),
      body: Column(
        children: [
          SizedBox(height: 25),
          Center(
            child: CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage("assets/image/a.jpg"),
            ),
          ),
          Text(
            "Yogi",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 27, color: Colors.red),
              SizedBox(width: 10),
              Text("Bandung", style: TextStyle(fontSize: 15)),
            ],
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromARGB(250, 0, 0, 0)),
            ),
            child: Text(
              "Bandung Lautan Api",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
