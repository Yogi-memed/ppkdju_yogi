import 'package:flutter/material.dart';

class Tugas extends StatelessWidget {
  const Tugas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Luminous ",
          style: TextStyle(
            color: Color.fromARGB(255, 18, 104, 57),
            fontSize: 25,
            fontWeight: FontWeight.w600,
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
        backgroundColor: Colors.white,
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
              backgroundImage: AssetImage('assets/image/a.jpg'),
              backgroundColor: Colors.black,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("yogi191096@gmail.com", style: TextStyle(fontSize: 12)),
                SizedBox(width: 8),
                Icon(Icons.verified_user, size: 14, color: Colors.black),
              ],
            ),
            Divider(height: 20),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 14,
                  color: Color.fromARGB(255, 18, 104, 57),
                ),
                Text(
                  " Innovation",
                  style: TextStyle(color: Color.fromARGB(255, 18, 104, 57)),
                ),
              ],
            ),

            Wrap(
              children: [
                Text(
                  "Masa Depan Energi Terbarukan : Inovasi EcosSync di Tahun 2024",
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.date_range_outlined,
                  size: 16,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                Text(
                  " 24 Mar 2024 • Oleh Admin EcoSync",
                  style: TextStyle(color: Color.fromARGB(255, 131, 131, 131)),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/image/a.jpg',
                    width: 340,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Wrap(
              children: [
                Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
