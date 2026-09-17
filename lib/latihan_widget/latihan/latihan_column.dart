import 'package:flutter/material.dart';

class LatihanColumn extends StatelessWidget {
const LatihanColumn({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text("Belajar Column"),
      ),
      body: Column(
        children: [
          Text("Hallo ini baris pertama"),
          Text("Hallo ini baris kedua"),
          Text("Hallo ini baris ketiga"),
          Text("Hallo ini baris keempat"),
          Text("Hallo ini baris kelima"),
          Text("Hallo ini baris keenam"),
          Text("Hallo ini baris ketujuh")
        ],
      ),
    );
  }
}