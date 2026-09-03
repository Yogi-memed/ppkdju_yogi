import 'package:flutter/material.dart';

class LatihanScreen extends StatelessWidget {
const LatihanScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Toko"), 
        backgroundColor: Colors.blue,foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25,),

      const Center(
        child: Text("Harumony Mystic Emporium", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
      ),
      const SizedBox(height: 20,),
      const Text(
        "harumony.id", style: TextStyle(fontSize: 16, color: Colors.grey,
        ),
      ),
      const SizedBox(height: 25,),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Container(width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration()
      ),
      ),
          ],
        ),
      )
    );
  }
}