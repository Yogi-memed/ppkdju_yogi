import 'package:flutter/material.dart';

class Tugas3Flutter extends StatefulWidget {
  const Tugas3Flutter({Key? key}) : super(key: key);

  @override
  _Tugas3FlutterState createState() => _Tugas3FlutterState();
}

class _Tugas3FlutterState extends State<Tugas3Flutter> {
  bool _tampilkanTeksRahasia = false;

  // ===== STATE UNTUK ICONBUTTON (favorite) =====
  bool _isFavorite = false;

  // ===== STATE UNTUK TEXTBUTTON (info tambahan) =====
  bool _tampilkanInfoTambahan = false;

  // ===== STATE UNTUK INKWELL (pesan setelah disentuh) =====
  String _pesanInkWell = "";

  // ===== STATE UNTUK GESTUREDETECTOR (counter) =====
  int _counter = 10;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Interaksi Flutter",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFF00BFFF),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          Center(
            child: const Text(
              "Elevaton Button",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _tampilkanTeksRahasia = !_tampilkanTeksRahasia;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFFF),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
            child: const Text(
              "Klik Saya!",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          if (_tampilkanTeksRahasia)
            const Text(
              "Halo saya Yogi!",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.black,
              ),
            ),
          const Divider(height: 32),
          Center(
            child: Column(
              children: [
                const Text(
                  "Icon Button",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 32,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
              const SizedBox(width: 8),
              if (_isFavorite)
                const Text(
                  "Di Sukai!",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const Divider(height: 32),
          Center(
            child: const Text(
              "Text Button!",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _tampilkanInfoTambahan = !_tampilkanInfoTambahan;
              });
            },
            child: Text(
              _tampilkanInfoTambahan ? "Sembunyi Info" : "Lihat Info Tambahan",
            ),
          ),
          if (_tampilkanInfoTambahan)
            Padding(
              padding: const EdgeInsetsGeometry.only(top: 4),
              child: Text(
                "Kualitas udara dipengaruhi oleh abu vulkanik, "
                "Aktivitas sehari-hari terganggu, pantau AQI secara rutin "
                "untuk menjaga pernapasan anda",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          const Divider(height: 32),
          Center(
            child: const Text(
              "Inkwell",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _pesanInkWell = "Kotak Berhasil Disentuh";
                });
              },
              child: Container(
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF00BFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Sentuh kotak ini!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              _pesanInkWell,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
          const Divider(height: 32),
          const Text(
            "GestureDetector",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _counter += 1;
                });
                print("Ditekan Sekali!");
              },
              onDoubleTap: () {
                setState(() {
                  _counter += 2;
                });
                print("Ditekan dua kali!");
              },
              onLongPress: () {
                setState(() {
                  _counter += 3;
                });
                print("Tahan Lama!");
              },
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Color(0xFF00BFFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  "$_counter",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              "Tap = +1  |  Double Tap = +2  |  Long Press = +3",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00BFFF),
        onPressed: () {
          setState(() {
            _counter -= 1;
          });
          print("FAB ditekan, Counter dikurangi!");
        },
        child: const Icon(Icons.remove, color: Colors.white),
      ),
    );
  }
}
