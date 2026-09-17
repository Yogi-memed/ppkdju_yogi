import 'package:flutter/material.dart';

class LatihanIcon extends StatelessWidget {
const LatihanIcon({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Belajar Widget Icon"),
        backgroundColor: Colors.deepPurpleAccent,
        leading: Icon(Icons.arrow_back, color: Colors.white, size: 50,),
        actions: [Icon(Icons.view_headline, color: Colors.black, size: 50,)],
      ),
    );
  }
}