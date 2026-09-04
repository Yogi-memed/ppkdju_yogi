import 'package:flutter/material.dart';

class TugasLyout extends StatelessWidget {
  const TugasLyout({super.key});

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
            letterSpacing: 5,
            shadows: [
              Shadow(
                color: Colors.black.withValues(
                  alpha: 0.3,
                ), // warna bayangan semi transparan
                offset: Offset(3, 3), // geser 3 ke kanan, 3 ke bawah
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
              backgroundImage: AssetImage('assets/profile/qingxiao.jpg'),
              backgroundColor: Colors.black,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // BIG TITLE HERE !
              Wrap(
                children: [
                  Text(
                    "Harmony Music Emperium",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // MESSAGE SECTION HERE !
              Container(
                height: 50,
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    //background here
                    Icon(Icons.email, size: 20),
                    SizedBox(width: 5),
                    Text("harumony.id"),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ===== GRUP 1 (Kiri) =====
                    Wrap(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.black),
                        SizedBox(width: 8),
                        Text('081212923623', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    // ===== GRUP 2 (Kanan) =====
                    Wrap(
                      children: [
                        Icon(Icons.location_pin, size: 14, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Jakarta, Indoensia',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(5),
                height: 120,
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Text("300+", textAlign: TextAlign.center),
                              Text(
                                "Book Sold per Month",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Text("4.8/5 🌏", textAlign: TextAlign.center),
                              Text(
                                "Book Sold per Month",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(6),
                child: Wrap(
                  children: [
                    Text(
                      "Lorem ipsum dolor sit amet, consectetuenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Curabitur pretium tincidunt lacus. Nulla gravida orci a odio. Nullam varius, turpis et commodo pharetra, est eros bibendum elit, nec luctus magna felis sollicitudin mauris. Integer in mauris eu nibh euismod gravida. Duis ac tellus et risus vulputate vehicula. Donec lobortis risus a elit. Etiam tempor. Ut ullamcorper, ligula eu tempor congue, eros est euismod turpis, id tincidunt sapien risus a quam. Maecenas fermentum consequat mi. Donec fermentum. Pellentesque malesuada nulla a mi. Duis sapien sem, aliquet nec, commodo eget, consequat quis, neque. Aliquam faucibus, elit ut dictum aliquet, felis nisl adipiscing sapien, sed malesuada diam lacus eget erat. Cras mollis scelerisque nunc. Nullam arcu. Aliquam consequat. Curabitur augue lorem, dapibus quis, laoreet et, pretium ac, nisi. Aenean magna nisl, mollis quis, molestie eu, feugiat in, orci. In hac habitasse platea dictumst.",
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Container(
                height: double.infinity,
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/profile/bg.png',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
