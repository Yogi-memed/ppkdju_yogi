import 'package:flutter/material.dart';

class Tugas4Flutter extends StatefulWidget {
  const Tugas4Flutter({super.key});

  @override
  State<Tugas4Flutter> createState() => _TugasFlutterState();
}

class _TugasFlutterState extends State<Tugas4Flutter> {
  // ===== STATE UNTUK ELEVATEDBUTTON (toggle teks rahasia) =====
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Lab Interaksi Flutter",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF00BFFF),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ============================================
          // 1. ELEVATEDBUTTON — Toggle teks rahasia
          // ============================================
          const Text(
            "1. ElevatedButton",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // Toggle: kalau lagi tampil -> sembunyikan, kalau tersembunyi -> tampilkan
              setState(() {
                _tampilkanTeksRahasia = !_tampilkanTeksRahasia;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D5B),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
            child: const Text(
              "Klik Saya!",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          // Teks rahasia hanya muncul kalau state true
          if (_tampilkanTeksRahasia)
            const Text(
              "Halo, saya Developer!",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),

          const Divider(height: 32),

          // ============================================
          // 2. ICONBUTTON — Perubahan warna & status favorit
          // ============================================
          const Text(
            "2. IconButton",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                iconSize: 32,
                icon: Icon(
                  // Ikon berubah bentuk juga (kosong/isi) selain warnanya
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
                  "Disukai!",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),

          const Divider(height: 32),

          // ============================================
          // 3. TEXTBUTTON — Tampilkan info tambahan
          // ============================================
          const Text(
            "3. TextButton",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _tampilkanInfoTambahan = !_tampilkanInfoTambahan;
              });
            },
            child: Text(
              _tampilkanInfoTambahan
                  ? "Sembunyikan Info"
                  : "Lihat Info Tambahan",
            ),
          ),
          if (_tampilkanInfoTambahan)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "Kualitas udara dipengaruhi oleh emisi kendaraan, "
                "aktivitas industri, dan cuaca. Pantau AQI secara rutin "
                "untuk menjaga kesehatan pernapasan Anda.",
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ),

          const Divider(height: 32),

          // ============================================
          // 4. INKWELL — Visual feedback + print ke debug console
          // ============================================
          const Text(
            "4. InkWell",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // Cetak pesan rahasia ke Debug Console
                print("Sentuhan terdeteksi pada kotak InkWell!");
                setState(() {
                  _pesanInkWell = "Kotak berhasil disentuh!";
                });
              },
              child: Container(
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D5B),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Sentuh Kotak Ini",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_pesanInkWell.isNotEmpty)
            Text(
              _pesanInkWell,
              style: const TextStyle(color: Color(0xFF2E7D5B)),
            ),

          const Divider(height: 32),

          // ============================================
          // 5 & 6. GESTUREDETECTOR + FLOATINGACTIONBUTTON — Counter
          // ============================================
          const Text(
            "5. GestureDetector",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              // Tap tunggal: +1
              onTap: () {
                setState(() {
                  _counter += 1;
                });
                print("Ditekan sekali");
              },
              // Tap dua kali: +2
              onDoubleTap: () {
                setState(() {
                  _counter += 2;
                });
                print("Ditekan dua kali");
              },
              // Tekan lama: +3
              onLongPress: () {
                setState(() {
                  _counter += 3;
                });
                print("Tahan lama");
              },
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade400,
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

          const SizedBox(
            height: 40,
          ), // ruang ekstra biar FAB gak nutupin konten
        ],
      ),

      // ============================================
      // 6. FLOATINGACTIONBUTTON — Mengurangi nilai counter
      // ============================================
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D5B),
        onPressed: () {
          setState(() {
            _counter -= 1;
          });
          print("FAB ditekan, counter dikurangi");
        },
        child: const Icon(Icons.remove, color: Colors.white),
      ),
    );
  }
}
