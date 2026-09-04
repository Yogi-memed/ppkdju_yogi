import 'package:flutter/material.dart';

class Toko extends StatelessWidget {
  const Toko({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Detail Toko",
          style: TextStyle(
            color: Color.fromARGB(255, 10, 10, 10),
            fontSize: 25,
            fontWeight: FontWeight.w400,
            letterSpacing: 8,
            shadows: [
              Shadow(
                color: Colors.black.withValues(
                  alpha: 0.3,
                ),
                offset: Offset(3, 3),
                blurRadius: 6,
              ),
             ],

          ),
        ),
        backgroundColor: Color.fromARGB(239, 69, 88, 153),
        leading: Icon(
          Icons.view_headline_rounded,
          color: Colors.black,
          size: 30,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage("assets/image/a.jpg"),
              backgroundColor: Colors.black,
            ),
            ),],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsetsGeometry.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                children: [
                  Text(
                    "Harmony Music Emperium",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                  )
                ],
              ),
          SizedBox(height: 10,),
          Container(
            height: 50,
            padding: const EdgeInsets.all (8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.deepOrangeAccent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.email, size: 20,),
                SizedBox(width: 5,),
                Text("Yogi@gmail.com"),
              ],
            ),
          ),
          SizedBox(height: 20,),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.black,),
                    SizedBox(width: 8,),
                    Text("081212926760", style: TextStyle(fontSize: 14),),
                  ],
                ),
                Wrap(
                  children: [
                    Icon(Icons.location_pin, size: 14, color: Colors.black,),
                    SizedBox(width: 10,),
                    Text("Jakarta, Indonesia", style: TextStyle(fontSize: 16),
                    ), 
                    ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),

          Container(
            padding: const EdgeInsets.all(5),
            height: 120,
            child: Row(
              children: [
                Expanded(child: Card(
                  child: Padding(padding: const EdgeInsetsGeometry.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text('300', textAlign: TextAlign.center,),
                      Text('Book Sold per Month', textAlign: TextAlign.center,),
                    ],
                  ),
                  ),
                ),
                ),
              Expanded(
                child: Card(
                  child: Padding(padding: padding),
                )
                ),  
              ],
            ),
          )
            ],
          ),
          ),
      ),
    );
  }
}
