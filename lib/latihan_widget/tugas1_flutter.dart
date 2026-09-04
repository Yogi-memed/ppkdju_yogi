import 'package:flutter/material.dart';

class TugasLyout extends StatefulWidget {
  const TugasLyout({super.key});

  @override
  State<TugasLyout> createState() => _TugasLyoutState();
}

class _TugasLyoutState extends State<TugasLyout> {
  // ===== CONTROLLER UNTUK FORM INPUT =====
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiPasswordController =
      TextEditingController();

  // Toggle untuk show/hide password
  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;

  // ===== DATA WILAYAH PEMANTAUAN KUALITAS UDARA =====
  final List<Map<String, dynamic>> _wilayahPemantauan = [
    {"label": "Jakarta", "color": Colors.blueGrey.shade400},
    {"label": "Bandung", "color": Colors.teal.shade400},
    {"label": "Yogyakarta", "color": Colors.orange.shade400},
    {"label": "Semarang", "color": Colors.indigo.shade400},
    {"label": "Lampung", "color": Colors.cyan.shade600},
    {"label": "Padang", "color": Colors.brown.shade400},
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Registrasi ${_namaController.text} berhasil dikirim!"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Registrasi & Edukasi",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D5B),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================
              // BAGIAN 1: FORM REGISTRASI
              // ============================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Form Registrasi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ----- Input 1: Nama Pengguna -----
                    TextField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        hintText: "Nama Pengguna",
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ----- Input 2: Email Pengguna -----
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email Pengguna",
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ----- Input 3: Telephone Pengguna -----
                    TextField(
                      controller: _teleponController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Telephone Pengguna",
                        prefixIcon: const Icon(Icons.phone_outlined),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ----- Input 4: Password -----
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Input Password",
                        prefixIcon: const Icon(Icons.key_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ----- Input 5: Konfirmasi Password -----
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6, left: 4),
                        child: Text(
                          "Konfirmasi Password",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      controller: _konfirmasiPasswordController,
                      obscureText: _obscureKonfirmasi,
                      decoration: InputDecoration(
                        hintText: "Masukkan Konfirmasi Passw...",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureKonfirmasi
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureKonfirmasi = !_obscureKonfirmasi;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ----- Tombol Submit -----
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D5B),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Daftar",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ============================================
              // BAGIAN 2: GALERI WILAYAH PEMANTAUAN
              // ============================================
              const Text(
                "Wilayah Pemantauan Kualitas Udara Terdekat",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
                children: _wilayahPemantauan.map((item) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Lapisan 1 (bawah): kotak warna sebagai pengganti foto kota
                        Container(
                          color: item["color"] as Color,
                          child: const Center(
                            child: Icon(
                              Icons.location_city,
                              size: 30,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        // Lapisan 2: gradient gelap tipis biar teks label terbaca
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.65),
                              ],
                            ),
                          ),
                        ),
                        // Lapisan 3 (atas): label nama kota
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Text(
                            item["label"] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
