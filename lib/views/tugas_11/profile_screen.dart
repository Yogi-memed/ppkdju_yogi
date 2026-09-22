import 'package:flutter/material.dart';
import 'package:ogi_ppkd_app_dev/db/services/preferencens_handler.dart';
import 'package:ogi_ppkd_app_dev/views/tugas_11/splash_screen.dart';
import 'package:shared_preferences_windows/shared_preferences_windows.dart';

class TugasSessionProfileScreen extends StatefulWidget {
  const TugasSessionProfileScreen({super.key});

  @override
  State<TugasSessionProfileScreen> createState() =>
      _TugasSessionProfileScreenState();
}

class _TugasSessionProfileScreenState extends State<TugasSessionProfileScreen> {
  String _userEmail = '';
  String _token = '';
  String _loginTime = '';

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  void _loadSessionData() {
    setState(() {
      _userEmail = PreferenceHandler.userEmail.isEmpty
          ? 'user@flutter.dev'
          : PreferenceHandler.userEmail;
      _token = PreferenceHandler.authToken.isEmpty
          ? 'jwt_token_ppkd_active_default'
          : PreferenceHandler.authToken;
      _loginTime = PreferenceHandler.loginTime.isEmpty
          ? 'Baru saja'
          : PreferenceHandler.loginTime;
    });
  }

  Future<void> _handleLogout() async {
    // 1. Hapus status login & token dari SharedPreferences
    await PreferenceHandler.logOut();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Token & Sesi berhasil dihapus (Logout).'),
        backgroundColor: Colors.redAccent,
      ),
    );

    // 2. Arahkan kembali ke Splash Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreenDay15()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Sesi & Token Aktif'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Active Session Badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 20,
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'STATUS: TOKEN AKTIF',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'SharedPreferences menyimpan sesi secara persisten di storage lokal.',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Token & Account Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Akun & Token',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      icon: Icons.person_outline,
                      label: 'Email Pengguna',
                      value: _userEmail,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.access_time,
                      label: 'Waktu Login',
                      value: _loginTime,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.vpn_key_outlined,
                      label: 'Auth Token (Bearer)',
                      value: _token,
                      isToken: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Interactive Flow Test Card
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.blue.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Uji Coba Alur Splash Screen:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ketika Anda membuka kembali Splash Screen saat token masih aktif, sistem akan langsung mengenali status login dan melakukan auto-redirect ke halaman ini tanpa melewati form login lagi.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'Buka Ulang Splash Screen (Auto-Redirect)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SplashScreenDay15(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Logout Button
            OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Hapus Sesi & Logout Token',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isToken = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              if (isToken)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}