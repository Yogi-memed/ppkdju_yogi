import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
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

  String locationAddress = 'Mendeteksi lokasi...';

  final Geocoding geocoding = Geocoding(locale: const Locale('id', 'ID'));

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      locationAddress = 'Mendeteksi lokasi...';
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          locationAddress = 'GPS belum aktif';
          isLoading = false;
        });

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;

        setState(() {
          locationAddress = 'Izin lokasi ditolak';
          isLoading = false;
        });

        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          locationAddress = 'Izin lokasi ditolak permanen';
          isLoading = false;
        });

        return;
      }

      final position = await Geolocator.getCurrentPosition();

      String addressText = 'Lokasi PPKD JU';

      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          final parts = [
            place.street,
            place.subLocality,
            place.locality,
            place.subAdministrativeArea,
          ].whereType<String>().toList();

          if (parts.isNotEmpty) {
            addressText = parts.join(', ');
          }
        }
      } catch (_) {
        addressText = 'Lokasi PPKD JU';
      }

      if (!mounted) return;

      setState(() {
        currentPosition = position;
        locationAddress = addressText;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        locationAddress = 'Gagal mendapatkan lokasi';
        isLoading = false;
      });
    }
  }

  Future<void> checkIn() async {
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi GPS belum tersedia')),
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
        address: locationAddress,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Check In berhasil')));

        Navigator.pop(context);
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
      if (mounted) {
        setState(() {
          isCheckInLoading = false;
        });
      }
    }
  }

  Future<void> checkOut() async {
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi GPS belum tersedia')),
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
        address: locationAddress,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Check Out berhasil')));

        Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Check Out gagal: $error')));
    } finally {
      if (mounted) {
        setState(() {
          isCheckOutLoading = false;
        });
      }
    }
  }

  Future<void> izinSakit() async {
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi GPS belum tersedia')),
      );

      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Izin Sakit',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Apakah kamu yakin ingin mengajukan izin sakit hari ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ajukan'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token login tidak ditemukan')),
        );

        return;
      }

      final response = await ApiServices().izinSakit(
        token: token,
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
        address: locationAddress,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin sakit berhasil diajukan')),
        );

        Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) return;

      String message = 'Izin sakit gagal diajukan';

      if (error.toString().contains('409')) {
        message = 'Anda sudah melakukan absensi atau izin hari ini';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          isIzinLoading = false;
        });
      }
    }
  }

  void openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GoogleMapsScreenDay19()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Kehadiran',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 22),

            _buildLocationCard(),

            const SizedBox(height: 14),

            _buildMapButton(),

            const SizedBox(height: 24),

            const Text(
              'Aksi Absensi',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    title: 'Check In',
                    icon: Icons.login_rounded,
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    loading: isCheckInLoading,
                    onPressed:
                        isCheckInLoading || isCheckOutLoading || isIzinLoading
                        ? null
                        : checkIn,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    title: 'Check Out',
                    icon: Icons.logout_rounded,
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    loading: isCheckOutLoading,
                    onPressed:
                        isCheckInLoading || isCheckOutLoading || isIzinLoading
                        ? null
                        : checkOut,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildIzinButton(),

            const SizedBox(height: 22),

            _buildLocationStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();

    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Absensi Hari Ini',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 5),
        Text(
          '${now.day} ${months[now.month - 1]} ${now.year}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lokasi PPKD JU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Lokasi GPS saat ini',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: isLoading ? null : getCurrentLocation,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_rounded, color: Colors.white, size: 19),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alamat terdeteksi',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        locationAddress,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (currentPosition != null)
            Row(
              children: [
                Expanded(
                  child: _buildCoordinate(
                    'Latitude',
                    currentPosition!.latitude.toStringAsFixed(6),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCoordinate(
                    'Longitude',
                    currentPosition!.longitude.toStringAsFixed(6),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCoordinate(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white60, fontSize: 9),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: openMap,
        icon: const Icon(Icons.map_rounded),
        label: const Text('Lihat Lokasi Saya di Peta'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required bool loading,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: loading
            ? SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Icon(icon),
        label: Text(loading ? 'Proses...' : title),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }

  Widget _buildIzinButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isCheckInLoading || isCheckOutLoading || isIzinLoading
            ? null
            : izinSakit,
        icon: isIzinLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.sick_rounded),
        label: Text(isIzinLoading ? 'Mengajukan Izin...' : 'Izin Sakit'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.45)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationStatus() {
    final success = currentPosition != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: success
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: success
              ? Colors.green.withValues(alpha: 0.18)
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: success
                  ? Colors.green.withValues(alpha: 0.13)
                  : Colors.grey.withValues(alpha: 0.13),
            ),
            child: Icon(
              success ? Icons.check_rounded : Icons.location_searching_rounded,
              color: success ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  success ? 'Lokasi berhasil ditemukan' : 'Mencari lokasi...',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  success
                      ? 'GPS siap digunakan untuk absensi'
                      : 'Mohon tunggu sebentar',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
