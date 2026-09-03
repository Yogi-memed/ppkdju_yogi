import 'package:flutter/material.dart';

class LatihanRitchtext extends StatelessWidget {
const LatihanRitchtext({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Belajar RitchText"),
        backgroundColor: Colors.yellow,
      ),
      body: RichText(
        text:TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 18),
          children: <TextSpan>[
           const TextSpan(text: "Belajar"),
           TextSpan(
            text: "Flutter",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            )
           ),
           const TextSpan(text: "itu"),
           const TextSpan(
            text: "Mudah!",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.green
            )
           )
          ]
        )
        ),
    );
  }
}