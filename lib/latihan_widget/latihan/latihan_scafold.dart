import 'package:flutter/material.dart';

class LatihanScafold extends StatelessWidget {
  const LatihanScafold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Belajar Scafold"),
        backgroundColor: Colors.amberAccent,
      ),
      body: Column(
        children: [
          Text(
            "Halo, ini sebuah text yang dibungkus oleh widget column dan scafold",
          ),
        ],
      ),
    );
  }
}
