import 'package:flutter/material.dart';

class TugasFlutter extends StatefulWidget {
  const TugasFlutter({super.key});

  @override
  State<TugasFlutter> createState() => _TugasFlutterState();
}

class _TugasFlutterState extends State<TugasFlutter> {
  // ===== CONTROLLER UNTUK FORM INPUT =====
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _skorAqiController = TextEditingController();
  final TextEditingController _pelaporController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  // ===== DATA RIWAYAT LAPORAN (DUMMY) =====
  final List<Map<String, dynamic>> _riwayatLaporan = [
    {
      "lokasi": "Jakarta Pusat",
      "info": "AQI: 156 - Tidak Sehat. Dilaporkan 5 menit lalu.",
      "icon": Icons.error,
      "color": Colors.red,
    },
    {
      "lokasi": "Bandung Kota",
      "info": "AQI: 95 - Sedang. Dilaporkan 30 menit lalu.",
      "icon": Icons.wb_cloudy,
      "color": Colors.orange,
    },
    {
      "lokasi": "Yogyakarta",
      "info": "AQI: 42 - Baik. Dilaporkan 1 hari lalu.",
      "icon": Icons.check_circle,
      "color": Colors.green,
    },
    {
      "lokasi": "Semarang",
      "info": "AQI: 120 - Sensitif. Dilaporkan 1 hari lalu.",
      "icon": Icons.warning,
      "color": Colors.deepOrange,
    },
    {
      "lokasi": "Lampung",
      "info": "AQI: 30 - Baik. Dilaporkan 2 hari lalu.",
      "icon": Icons.check_circle,
      "color": Colors.green,
    },
  ];

  @override
  void dispose() {
    _lokasiController.dispose();
    _skorAqiController.dispose();
    _pelaporController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Laporan & Riwayat Udara",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D5B),
      ),

      // =====================================================
      // ROOT WIDGET WAJIB: ListView (bukan Column/SingleChildScrollView)
      // =====================================================
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ============================================
          // BAGIAN 1: FORM LAPORAN (4 TextField sebagai item pertama)
          // ============================================
          const Text(
            "Laporan Kondisi Udara",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // ----- Input 1: Titik Lokasi -----
          TextField(
            controller: _lokasiController,
            decoration: InputDecoration(
              hintText: "Titik Lokasi (Nama Jalan/Gedung)",
              prefixIcon: const Icon(Icons.location_on_outlined),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ----- Input 2: Skor AQI -----
          TextField(
            controller: _skorAqiController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Skor AQI Teramati",
              prefixIcon: const Icon(Icons.speed_outlined),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ----- Input 3: Nama Pelapor -----
          TextField(
            controller: _pelaporController,
            decoration: InputDecoration(
              hintText: "Nama Pelapor",
              prefixIcon: const Icon(Icons.person_outline),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ----- Input 4: Catatan Tambahan -----
          TextField(
            controller: _catatanController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: "Catatan Tambahan (Misal: Berkabut...",
              prefixIcon: const Icon(Icons.notes_outlined),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ============================================
          // BAGIAN 2: DAFTAR RIWAYAT (5 ListTile)
          // ============================================
          const Text(
            "Riwayat Laporan Terakhir",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // ----- Generate 5 ListTile dari data riwayat -----
          ..._riwayatLaporan.map((item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                // Leading: ikon status kualitas udara
                leading: CircleAvatar(
                  backgroundColor: (item["color"] as Color).withValues(
                    alpha: 0.15,
                  ),
                  child: Icon(
                    item["icon"] as IconData,
                    color: item["color"] as Color,
                  ),
                ),
                // Title: nama lokasi
                title: Text(
                  item["lokasi"] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                // Subtitle: info AQI + waktu laporan
                subtitle: Text(item["info"] as String),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            );
          }),
        ],
      ),
    );
  }
}
