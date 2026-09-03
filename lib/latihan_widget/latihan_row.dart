import 'package:flutter/material.dart';

class LatihanRow extends StatelessWidget {
const LatihanRow({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.amberAccent,
      title: Text("Belajar widget row"),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100,),
          Text(
            "ini text widget kiri", style: TextStyle(color: Colors.blue)
            ),
          Text(
            "ini text widget tengah", style: TextStyle(color: Colors.deepOrange)
            ),
          Text(
            "ini text widget kanan", style: TextStyle(color: Colors.green)
            ),
        ],
      ),
    );
  }
}