import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/api_services.dart';
import '../../services/storage_services.dart';
import '../maps_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Position? currentPosition;

  bool isLoading = false;
  bool isCheckInLoading = false;
  bool isCheckOutLoading = false;
  bool isIzinLoading = false;

  String locationMessage = 'Lokasi belum diambil';

  @override
  void initState() {
    super.initState();

    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    setState(() {
      isLoading = true;
      locationMessage = 'Mengambil lokasi...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          locationMessage = 'GPS belum aktif';
          isLoading = false;
        });

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          locationMessage = 'Izin lokasi ditolak';
          isLoading = false;
        });

        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          locationMessage =
              'Izin lokasi ditolak permanen. Aktifkan melalui pengaturan.';
          isLoading = false;
        });

        return;
      }

      final position = await Geolocator.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        currentPosition = position;

        locationMessage =
            'Latitude: ${position.latitude}\n'
            'Longitude: ${position.longitude}';

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        locationMessage = 'Gagal mengambil lokasi: $error';
        isLoading = false;
      });
    }
  }

  Future<void> checkIn() async {
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ambil lokasi GPS terlebih dahulu')),
      );

      return;
    }

    setState(() {
      isCheckInLoading = true;
    });

    try {
      final token = await StorageServices.getToken();

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token login tidak ditemukan')),
        );

        return;
      }

      final response = await ApiServices().checkIn(
        token: token,
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
        address: locationMessage,
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Check In berhasil')));
      }
    } catch (error) {
      if (!mounted) return;

      String message = 'Check In gagal';

      if (error.toString().contains('409')) {
        message = 'Anda sudah melakukan absensi hari ini';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (!mounted) return;

      setState(() {
        isCheckInLoading = false;
      });
    }
  }

  Future<void> checkOut() async {
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ambil lokasi GPS terlebih dahulu')),
      );

      return;
    }

    setState(() {
      isCheckOutLoading = true;
    });

    try {
      final token = await StorageServices.getToken();

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token login tidak ditemukan')),
        );

        return;
      }

      final response = await ApiServices().checkOut(
        token: token,
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
        address: locationMessage,
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Check Out berhasil')));
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Check Out gagal: $error')));
    } finally {
      if (!mounted) return;

      setState(() {
        isCheckOutLoading = false;
      });
    }
  }

  Future<void> izinSakit() async {
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ambil lokasi GPS terlebih dahulu')),
      );

      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Izin Sakit'),
          content: const Text(
            'Yakin ingin mengajukan izin sakit untuk hari ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Ajukan Izin'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      isIzinLoading = true;
    });

    try {
      final token = await StorageServices.getToken();

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token login tidak ditemukan')),
        );

        return;
      }

      final response = await ApiServices().izinSakit(
        token: token,
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
        address: locationMessage,
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin sakit berhasil diajukan')),
        );
      }
    } catch (error) {
      if (!mounted) return;

      String message = 'Gagal mengajukan izin sakit';

      if (error.toString().contains('409')) {
        message = 'Anda sudah melakukan absensi atau izin hari ini';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (!mounted) return;

      setState(() {
        isIzinLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9E9E9E),

      appBar: AppBar(
        backgroundColor: const Color(0xFF757575),
        foregroundColor: Colors.white,
        title: const Text(
          'Kehadiran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Absensi Hari Ini',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // LOKASI
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF424242),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.redAccent,
                    size: 30,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      locationMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // AMBIL LOKASI
            // =========================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: Text(
                  isLoading ? 'Mengambil Lokasi...' : 'Ambil Lokasi GPS',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66B5A5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // GOOGLE MAPS
            // =========================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GoogleMapsScreenDay19(),
                    ),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text('Lihat Lokasi Saya di Peta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66B5A5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // CHECK IN
            // =========================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isCheckInLoading ? null : checkIn,
                icon: isCheckInLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.login),
                label: Text(
                  isCheckInLoading ? 'Memproses Check In...' : 'Check In',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // CHECK OUT
            // =========================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isCheckOutLoading ? null : checkOut,
                icon: isCheckOutLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.logout),
                label: Text(
                  isCheckOutLoading ? 'Memproses Check Out...' : 'Check Out',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // IZIN SAKIT
            // =========================
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isIzinLoading ? null : izinSakit,
                icon: isIzinLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sick),
                label: Text(
                  isIzinLoading ? 'Mengajukan Izin...' : 'Izin Sakit',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // STATUS GPS
            // =========================
            if (currentPosition != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF616161),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.greenAccent),
                    SizedBox(width: 10),
                    Text(
                      'Lokasi berhasil ditemukan!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
