import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/attendance_model.dart';
import '../../services/api_services.dart';
import '../../services/storage_services.dart';

import '../attendance/attendance_screen.dart';
import '../attendance/history_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // =========================
  // WARNA
  // =========================

  static const Color bgColor = Color(0xFF071010);
  static const Color cardColor = Color(0xFF101A1A);
  static const Color cardColor2 = Color(0xFF142020);
  static const Color accentColor = Color(0xFF10B981);
  static const Color accentLight = Color(0xFF34D399);

  // =========================
  // DATA
  // =========================

  String userName = 'Pengguna';

  bool isLoading = false;
  bool isLocationLoading = false;

  List<AttendanceModel> attendanceList = [];

  AttendanceModel? todayAttendance;

  String locationAddress = 'Mencari lokasi...';

  Position? currentPosition;

  GoogleMapController? mapController;

  final LatLng defaultLocation = const LatLng(-6.2000, 106.816666);

  // =========================
  // INIT
  // =========================

  @override
  void initState() {
    super.initState();

    loadDashboard();
    getCurrentLocation();
  }

  // =========================
  // LOAD DASHBOARD
  // =========================

  Future<void> loadDashboard() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final token = await StorageServices.getToken();

      if (token == null || token.isEmpty) {
        return;
      }

      // =========================
      // PROFILE
      // =========================

      final profileResponse = await ApiServices().getProfile(token: token);

      if (profileResponse.statusCode == 200) {
        final profileData = profileResponse.data['data'];

        if (profileData != null && mounted) {
          setState(() {
            userName = profileData['name']?.toString() ?? 'Pengguna';
          });
        }
      }

      // =========================
      // HISTORY
      // =========================

      final now = DateTime.now();

      final historyResponse = await ApiServices().getHistory(
        token: token,
        start: '${now.year}-01-01',
        end: '${now.year}-12-31',
      );

      if (historyResponse.statusCode == 200) {
        final data = historyResponse.data['data'];

        if (data is List) {
          final list = data
              .map(
                (item) =>
                    AttendanceModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();

          AttendanceModel? today;

          for (final item in list) {
            if (item.checkIn != null && item.checkIn!.isNotEmpty) {
              final parsedDate = DateTime.tryParse(item.checkIn!);

              if (parsedDate != null &&
                  parsedDate.year == now.year &&
                  parsedDate.month == now.month &&
                  parsedDate.day == now.day) {
                today = item;
                break;
              }
            }
          }

          if (mounted) {
            setState(() {
              attendanceList = list;
              todayAttendance = today;
            });
          }
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat dashboard: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =========================
  // GPS
  // =========================

  Future<void> getCurrentLocation() async {
    if (mounted) {
      setState(() {
        isLocationLoading = true;
        locationAddress = 'Mencari lokasi...';
      });
    }

    try {
      // Cek GPS
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            locationAddress = 'GPS belum aktif';
            isLocationLoading = false;
          });
        }

        return;
      }

      // Cek permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            locationAddress = 'Izin lokasi ditolak';
            isLocationLoading = false;
          });
        }

        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            locationAddress = 'Izin lokasi ditolak permanen';
            isLocationLoading = false;
          });
        }

        return;
      }

      // Ambil posisi GPS terbaru
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        currentPosition = position;
        locationAddress = 'PPKD JU';
        isLocationLoading = false;
      });

      // Pindahkan kamera
      if (mapController != null) {
        await mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          locationAddress = 'Gagal mendapatkan lokasi';
          isLocationLoading = false;
        });
      }
    }
  }

  // =========================
  // STATISTIK
  // =========================

  int get totalAttendance {
    return attendanceList.where((item) {
      return item.status?.toLowerCase() == 'masuk';
    }).length;
  }

  int get totalCheckOut {
    return attendanceList.where((item) {
      return item.checkOut != null && item.checkOut!.isNotEmpty;
    }).length;
  }

  int get totalIzinSakit {
    return attendanceList.where((item) {
      return item.status?.toLowerCase() == 'izin';
    }).length;
  }

  String get todayStatus {
    if (todayAttendance == null) {
      return 'Belum Absen';
    }

    final status = todayAttendance!.status?.toLowerCase();

    if (status == 'izin') {
      return 'Izin Sakit';
    }

    if (status == 'masuk') {
      return 'Hadir';
    }

    return todayAttendance!.status ?? 'Belum Absen';
  }

  // =========================
  // FORMAT TANGGAL
  // =========================

  String formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return '-';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // =========================
  // FORMAT JAM
  // =========================

  String formatTime(String? value) {
    if (value == null || value.isEmpty) {
      return '-';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  // =========================
  // MARKER GPS
  // =========================

  Set<Marker> get currentMarker {
    if (currentPosition == null) {
      return {};
    }

    return {
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        infoWindow: const InfoWindow(title: 'Lokasi Saya', snippet: 'PPKD JU'),
      ),
    };
  }

  // =========================
  // NAVIGATION
  // =========================

  void openAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AttendanceScreen()),
    );
  }

  void openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      body: SafeArea(
        child: RefreshIndicator(
          color: accentColor,
          backgroundColor: cardColor,
          onRefresh: () async {
            await loadDashboard();
            await getCurrentLocation();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(height: 22),

                _buildWelcomeCard(),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  'Statistik Absensi',
                  'Ringkasan kehadiran kamu',
                ),

                const SizedBox(height: 12),

                _buildStatistics(),

                const SizedBox(height: 26),

                _buildSectionTitle(
                  'Absensi Hari Ini',
                  'Status kehadiran hari ini',
                ),

                const SizedBox(height: 12),

                _buildTodayAttendance(),

                const SizedBox(height: 26),

                _buildSectionTitle('Lokasi Saya', 'Lokasi GPS perangkat kamu'),

                const SizedBox(height: 12),

                _buildLocationCard(),

                const SizedBox(height: 14),

                _buildMapPreview(),

                const SizedBox(height: 26),

                _buildSectionTitle('Riwayat Kehadiran', 'Absensi terbaru kamu'),

                const SizedBox(height: 8),

                _buildHistoryHeader(),

                const SizedBox(height: 12),

                if (attendanceList.isEmpty)
                  _buildEmptyHistory()
                else
                  ...attendanceList
                      .take(3)
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildHistoryCard(item),
                        ),
                      ),

                if (attendanceList.length > 3) _buildSeeAllButton(),
              ],
            ),
          ),
        ),
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // =========================
  // SECTION TITLE
  // =========================

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // =========================
  // HEADER
  // =========================

  Widget _buildHeader() {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF10B981), Color(0xFF047857)],
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang 👋',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.50),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: openProfile,
          style: IconButton.styleFrom(backgroundColor: cardColor),
          icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
        ),
      ],
    );
  }

  // =========================
  // WELCOME CARD
  // =========================

  Widget _buildWelcomeCard() {
    final now = DateTime.now();

    final weekdays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

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

    final dateText =
        '${weekdays[now.weekday - 1]}, '
        '${now.day} '
        '${months[now.month - 1]} '
        '${now.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF123A32), Color(0xFF101A1A)],
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dateText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, size: 14, color: accentLight),
                    SizedBox(width: 5),
                    Text(
                      'Absensi',
                      style: TextStyle(
                        color: accentLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            'Tetap semangat hari ini!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Jangan lupa lakukan absensi '
            'sesuai kondisi kamu.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.60),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: openAttendance,
              icon: const Icon(Icons.fingerprint_rounded),
              label: const Text('Buka Absensi'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // STATISTICS
  // =========================

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Hadir',
            value: totalAttendance.toString(),
            icon: Icons.check_circle_outline,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildStatCard(
            title: 'Pulang',
            value: totalCheckOut.toString(),
            icon: Icons.logout_rounded,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildStatCard(
            title: 'Izin',
            value: totalIzinSakit.toString(),
            icon: Icons.event_note_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: accentLight, size: 19),
          ),

          const SizedBox(height: 13),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // TODAY ATTENDANCE
  // =========================

  Widget _buildTodayAttendance() {
    final isHadir = todayStatus == 'Hadir';

    final isIzin = todayStatus == 'Izin Sakit';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isHadir
                  ? accentColor.withValues(alpha: 0.12)
                  : isIzin
                  ? Colors.orange.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              isHadir
                  ? Icons.check_circle_rounded
                  : isIzin
                  ? Icons.event_note_rounded
                  : Icons.access_time_rounded,
              color: isHadir
                  ? accentLight
                  : isIzin
                  ? Colors.orange
                  : Colors.white54,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Hari Ini',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  todayAttendance == null
                      ? 'Kamu belum melakukan absensi.'
                      : 'Data absensi hari ini tersedia.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: isHadir
                  ? accentColor.withValues(alpha: 0.12)
                  : isIzin
                  ? Colors.orange.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              todayStatus,
              style: TextStyle(
                color: isHadir
                    ? accentLight
                    : isIzin
                    ? Colors.orange
                    : Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // LOCATION CARD
  // =========================

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: accentLight,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lokasi Saat Ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      locationAddress,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              if (isLocationLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accentLight,
                  ),
                )
              else
                IconButton(
                  onPressed: getCurrentLocation,
                  icon: const Icon(Icons.refresh_rounded, color: accentLight),
                ),
            ],
          ),

          if (currentPosition != null) ...[
            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.gps_fixed_rounded,
                    color: accentLight,
                    size: 17,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      '${currentPosition!.latitude.toStringAsFixed(6)}, '
                      '${currentPosition!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================
  // MAP PREVIEW
  // =========================

  Widget _buildMapPreview() {
    final mapPosition = currentPosition != null
        ? LatLng(currentPosition!.latitude, currentPosition!.longitude)
        : defaultLocation;

    return Container(
      width: double.infinity,
      height: 245,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withValues(alpha: 0.08)),
      ),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: mapPosition,
              zoom: 16,
            ),
            markers: currentMarker,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              mapController = controller;

              if (currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(
                      currentPosition!.latitude,
                      currentPosition!.longitude,
                    ),
                  ),
                );
              }
            },
          ),

          // =========================
          // LABEL PPKD JU
          // =========================
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accentColor.withValues(alpha: 0.18)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded, color: accentLight, size: 17),

                  SizedBox(width: 6),

                  Text(
                    'PPKD JU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =========================
          // TOMBOL LOKASI
          // =========================
          Positioned(
            right: 14,
            bottom: 14,
            child: Material(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () async {
                  await getCurrentLocation();

                  if (currentPosition != null) {
                    mapController?.animateCamera(
                      CameraUpdate.newLatLng(
                        LatLng(
                          currentPosition!.latitude,
                          currentPosition!.longitude,
                        ),
                      ),
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.my_location_rounded,
                    color: accentLight,
                    size: 21,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // HISTORY HEADER
  // =========================

  Widget _buildHistoryHeader() {
    return Row(
      children: [
        Text(
          '${attendanceList.length} data absensi',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.40),
            fontSize: 11,
          ),
        ),

        const Spacer(),

        if (attendanceList.isNotEmpty)
          TextButton(
            onPressed: openHistory,
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                color: accentLight,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }

  // =========================
  // HISTORY CARD
  // =========================

  Widget _buildHistoryCard(AttendanceModel item) {
    final isIzin = item.status?.toLowerCase() == 'izin';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isIzin
                      ? Colors.orange.withValues(alpha: 0.12)
                      : accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isIzin ? Icons.event_note_rounded : Icons.check_rounded,
                  color: isIzin ? Colors.orange : accentLight,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(item.checkIn),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      isIzin ? 'Izin Sakit' : 'Kehadiran',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isIzin
                      ? Colors.orange.withValues(alpha: 0.12)
                      : accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isIzin ? 'Izin' : 'Hadir',
                  style: TextStyle(
                    color: isIzin ? Colors.orange : accentLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _buildTimeItem(
                  icon: Icons.login_rounded,
                  title: 'Masuk',
                  value: formatTime(item.checkIn),
                ),
              ),

              Container(
                width: 1,
                height: 30,
                color: Colors.white.withValues(alpha: 0.06),
              ),

              Expanded(
                child: _buildTimeItem(
                  icon: Icons.logout_rounded,
                  title: 'Pulang',
                  value: formatTime(item.checkOut),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // TIME ITEM
  // =========================

  Widget _buildTimeItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(icon, size: 17, color: accentLight),

          const SizedBox(width: 7),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.40),
                  fontSize: 10,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // EMPTY HISTORY
  // =========================

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            color: Colors.white.withValues(alpha: 0.25),
            size: 40,
          ),

          const SizedBox(height: 10),

          const Text(
            'Belum ada riwayat absensi',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 4),

          Text(
            'Data absensi kamu akan muncul '
            'di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.40),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // SEE ALL
  // =========================

  Widget _buildSeeAllButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: openHistory,
        style: OutlinedButton.styleFrom(
          foregroundColor: accentLight,
          side: BorderSide(color: accentColor.withValues(alpha: 0.20)),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Lihat Semua Riwayat',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
        ),
      ),
    );
  }

  // =========================
  // BOTTOM NAVIGATION
  // =========================

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Row(
            children: [
              // HOME
              Expanded(
                child: _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  active: true,
                  onTap: () {},
                ),
              ),

              // KEHADIRAN
              Expanded(
                child: _buildNavItem(
                  icon: Icons.fingerprint_rounded,
                  label: 'Kehadiran',
                  active: false,
                  onTap: openAttendance,
                ),
              ),

              // RIWAYAT
              Expanded(
                child: _buildNavItem(
                  icon: Icons.history_rounded,
                  label: 'Riwayat',
                  active: false,
                  onTap: openHistory,
                ),
              ),

              // PROFILE
              Expanded(
                child: _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  active: false,
                  onTap: openProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // NAV ITEM
  // =========================

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: active
                  ? accentLight
                  : Colors.white.withValues(alpha: 0.35),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                color: active
                    ? accentLight
                    : Colors.white.withValues(alpha: 0.35),
                fontSize: 10,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// import '../../models/attendance_model.dart';
// import '../../services/api_services.dart';
// import '../../services/storage_services.dart';

// import '../attendance/attendance_screen.dart';
// import '../attendance/history_screen.dart';
// import '../profile/profile_screen.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   static const Color bgColor = Color(0xFF071010);
//   static const Color cardColor = Color(0xFF101A1A);
//   static const Color accentColor = Color(0xFF10B981);
//   static const Color accentLight = Color(0xFF34D399);

//   String userName = 'Pengguna';

//   bool isLoading = false;
//   bool isLocationLoading = false;

//   List<AttendanceModel> attendanceList = [];
//   AttendanceModel? todayAttendance;

//   String locationAddress = 'Mencari lokasi...';

//   Position? currentPosition;

//   GoogleMapController? mapController;

//   final LatLng defaultLocation = const LatLng(-6.2000, 106.816666);

//   @override
//   void initState() {
//     super.initState();

//     loadDashboard();
//     getCurrentLocation();
//   }

//   Future<void> loadDashboard() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final token = await StorageServices.getToken();

//       if (token == null || token.isEmpty) {
//         return;
//       }

//       final profileResponse = await ApiServices().getProfile(token: token);

//       if (profileResponse.statusCode == 200) {
//         final profileData = profileResponse.data['data'];

//         if (profileData != null && mounted) {
//           setState(() {
//             userName = profileData['name']?.toString() ?? 'Pengguna';
//           });
//         }
//       }

//       final now = DateTime.now();

//       final historyResponse = await ApiServices().getHistory(
//         token: token,
//         start: '${now.year}-01-01',
//         end: '${now.year}-12-31',
//       );

//       if (historyResponse.statusCode == 200) {
//         final data = historyResponse.data['data'];

//         if (data is List) {
//           final list = data
//               .map(
//                 (item) =>
//                     AttendanceModel.fromJson(Map<String, dynamic>.from(item)),
//               )
//               .toList();

//           AttendanceModel? today;

//           for (final item in list) {
//             if (item.checkIn != null) {
//               final parsedDate = DateTime.tryParse(item.checkIn!);

//               if (parsedDate != null &&
//                   parsedDate.year == now.year &&
//                   parsedDate.month == now.month &&
//                   parsedDate.day == now.day) {
//                 today = item;
//                 break;
//               }
//             }
//           }

//           if (mounted) {
//             setState(() {
//               attendanceList = list;
//               todayAttendance = today;
//             });
//           }
//         }
//       }
//     } catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Gagal memuat dashboard: $error')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> getCurrentLocation() async {
//     setState(() {
//       isLocationLoading = true;
//     });

//     try {
//       final serviceEnabled = await Geolocator.isLocationServiceEnabled();

//       if (!serviceEnabled) {
//         if (mounted) {
//           setState(() {
//             locationAddress = 'GPS belum aktif';
//             isLocationLoading = false;
//           });
//         }
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();

//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }

//       if (permission == LocationPermission.denied) {
//         if (mounted) {
//           setState(() {
//             locationAddress = 'Izin lokasi ditolak';
//             isLocationLoading = false;
//           });
//         }
//         return;
//       }

//       if (permission == LocationPermission.deniedForever) {
//         if (mounted) {
//           setState(() {
//             locationAddress = 'Izin lokasi ditolak permanen';
//             isLocationLoading = false;
//           });
//         }
//         return;
//       }

//       final position = await Geolocator.getCurrentPosition();

//       if (!mounted) return;

//       setState(() {
//         currentPosition = position;

//         locationAddress =
//             '${position.latitude.toStringAsFixed(6)}, '
//             '${position.longitude.toStringAsFixed(6)}';

//         isLocationLoading = false;
//       });

//       if (mapController != null) {
//         mapController!.animateCamera(
//           CameraUpdate.newCameraPosition(
//             CameraPosition(
//               target: LatLng(position.latitude, position.longitude),
//               zoom: 15,
//             ),
//           ),
//         );
//       }
//     } catch (error) {
//       if (mounted) {
//         setState(() {
//           locationAddress = 'Gagal mendapatkan lokasi';

//           isLocationLoading = false;
//         });
//       }
//     }
//   }

//   int get totalAttendance {
//     return attendanceList
//         .where((item) => item.status.toLowerCase() == 'masuk')
//         .length;
//   }

//   int get totalCheckOut {
//     return attendanceList
//         .where((item) => item.checkOut != null && item.checkOut!.isNotEmpty)
//         .length;
//   }

//   int get totalIzinSakit {
//     return attendanceList
//         .where((item) => item.status.toLowerCase() == 'izin')
//         .length;
//   }

//   String get todayStatus {
//     if (todayAttendance == null) {
//       return 'Belum Absen';
//     }

//     if (todayAttendance!.status.toLowerCase() == 'izin') {
//       return 'Izin Sakit';
//     }

//     if (todayAttendance!.status.toLowerCase() == 'masuk') {
//       return 'Hadir';
//     }

//     return todayAttendance!.status;
//   }

//   String formatDate(String? value) {
//     if (value == null || value.isEmpty) {
//       return '-';
//     }

//     final date = DateTime.tryParse(value);

//     if (date == null) {
//       return value;
//     }

//     return '${date.day.toString().padLeft(2, '0')}/'
//         '${date.month.toString().padLeft(2, '0')}/'
//         '${date.year}';
//   }

//   String formatTime(String? value) {
//     if (value == null || value.isEmpty) {
//       return '-';
//     }

//     final date = DateTime.tryParse(value);

//     if (date == null) {
//       return value;
//     }

//     return '${date.hour.toString().padLeft(2, '0')}:'
//         '${date.minute.toString().padLeft(2, '0')}';
//   }

//   void openAttendance() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const AttendanceScreen()),
//     );
//   }

//   void openHistory() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const HistoryScreen()),
//     );
//   }

//   void openProfile() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const ProfileScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: bgColor,

//       body: SafeArea(
//         child: RefreshIndicator(
//           color: accentColor,
//           backgroundColor: cardColor,
//           onRefresh: loadDashboard,

//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),

//             padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),

//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,

//               children: [
//                 _buildHeader(),

//                 const SizedBox(height: 24),

//                 _buildWelcomeCard(),

//                 const SizedBox(height: 26),

//                 _buildSectionTitle(
//                   'Statistik Absensi',
//                   'Ringkasan kehadiran kamu',
//                 ),

//                 const SizedBox(height: 14),

//                 _buildStatistics(),

//                 const SizedBox(height: 26),

//                 _buildSectionTitle(
//                   'Absensi Hari Ini',
//                   'Status kehadiran hari ini',
//                 ),

//                 const SizedBox(height: 14),

//                 _buildTodayAttendance(),

//                 const SizedBox(height: 26),

//                 _buildSectionTitle('Lokasi Saya', 'Lokasi GPS perangkat kamu'),

//                 const SizedBox(height: 14),

//                 _buildLocationCard(),

//                 // ============================
//                 // MAP PREVIEW DITAMBAHKAN DI SINI
//                 // ============================
//                 const SizedBox(height: 12),

//                 _buildMapPreview(),

//                 const SizedBox(height: 26),

//                 _buildSectionTitle(
//                   'Riwayat Kehadiran',
//                   'Aktivitas absensi terbaru',
//                 ),

//                 const SizedBox(height: 14),

//                 if (attendanceList.isEmpty)
//                   _buildEmptyHistory()
//                 else
//                   ...attendanceList
//                       .take(3)
//                       .map(
//                         (item) => Padding(
//                           padding: const EdgeInsets.only(bottom: 12),
//                           child: _buildHistoryCard(item),
//                         ),
//                       ),

//                 if (attendanceList.length > 3) _buildSeeAllButton(),
//               ],
//             ),
//           ),
//         ),
//       ),

//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }

//   Widget _buildHeader() {
//     final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

//     return Row(
//       children: [
//         Container(
//           width: 52,
//           height: 52,

//           decoration: BoxDecoration(
//             color: accentColor.withValues(alpha: 0.14),
//             borderRadius: BorderRadius.circular(18),
//             border: Border.all(color: accentColor.withValues(alpha: 0.35)),
//             boxShadow: [
//               BoxShadow(
//                 color: accentColor.withValues(alpha: 0.10),
//                 blurRadius: 18,
//               ),
//             ],
//           ),

//           child: Center(
//             child: Text(
//               initial,
//               style: const TextStyle(
//                 color: accentLight,
//                 fontSize: 21,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//           ),
//         ),

//         const SizedBox(width: 13),

//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,

//             children: [
//               Text(
//                 'Selamat datang 👋',
//                 style: TextStyle(
//                   color: Colors.white.withValues(alpha: 0.50),
//                   fontSize: 12,
//                 ),
//               ),

//               const SizedBox(height: 3),

//               Text(
//                 userName,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,

//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 19,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         IconButton(
//           onPressed: openProfile,

//           style: IconButton.styleFrom(
//             backgroundColor: cardColor,
//             side: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
//           ),

//           icon: const Icon(Icons.person_outline_rounded, color: accentLight),
//         ),
//       ],
//     );
//   }

//   Widget _buildWelcomeCard() {
//     final now = DateTime.now();

//     const months = [
//       'Januari',
//       'Februari',
//       'Maret',
//       'April',
//       'Mei',
//       'Juni',
//       'Juli',
//       'Agustus',
//       'September',
//       'Oktober',
//       'November',
//       'Desember',
//     ];

//     final dateText = '${now.day} ${months[now.month - 1]} ${now.year}';

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(22),

//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(28),

//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFF12352E), Color(0xFF09201D)],
//         ),

//         border: Border.all(color: accentColor.withValues(alpha: 0.22)),

//         boxShadow: [
//           BoxShadow(
//             color: accentColor.withValues(alpha: 0.08),
//             blurRadius: 28,
//             offset: const Offset(0, 12),
//           ),
//         ],
//       ),

//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,

//         children: [
//           Row(
//             children: [
//               const Icon(
//                 Icons.calendar_today_rounded,
//                 color: accentLight,
//                 size: 16,
//               ),

//               const SizedBox(width: 8),

//               Expanded(
//                 child: Text(
//                   dateText,
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),

//               _badge('AKTIF', accentColor),
//             ],
//           ),

//           const SizedBox(height: 22),

//           const Text(
//             'Tetap semangat hari ini!',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 23,
//               fontWeight: FontWeight.w900,
//             ),
//           ),

//           const SizedBox(height: 7),

//           Text(
//             'Jangan lupa lakukan absensi sesuai kondisi kamu.',
//             style: TextStyle(
//               color: Colors.white.withValues(alpha: 0.58),
//               fontSize: 12,
//             ),
//           ),

//           const SizedBox(height: 20),

//           SizedBox(
//             width: double.infinity,
//             height: 52,

//             child: ElevatedButton.icon(
//               onPressed: openAttendance,

//               icon: const Icon(Icons.fingerprint_rounded),

//               label: const Text(
//                 'Buka Absensi',
//                 style: TextStyle(fontWeight: FontWeight.w800),
//               ),

//               style: ElevatedButton.styleFrom(
//                 backgroundColor: accentColor,
//                 foregroundColor: Colors.black,
//                 elevation: 0,

//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title, String subtitle) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,

//       children: [
//         Text(
//           title,

//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.w900,
//           ),
//         ),

//         const SizedBox(height: 3),

//         Text(
//           subtitle,

//           style: TextStyle(
//             color: Colors.white.withValues(alpha: 0.40),
//             fontSize: 11,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatistics() {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildStatCard(
//             'Hadir',
//             '$totalAttendance',
//             Icons.check_circle_rounded,
//           ),
//         ),

//         const SizedBox(width: 10),

//         Expanded(
//           child: _buildStatCard(
//             'Check Out',
//             '$totalCheckOut',
//             Icons.logout_rounded,
//           ),
//         ),

//         const SizedBox(width: 10),

//         Expanded(
//           child: _buildStatCard('Izin', '$totalIzinSakit', Icons.sick_rounded),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard(String title, String value, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(15),

//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(20),

//         border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
//       ),

//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,

//         children: [
//           Container(
//             width: 38,
//             height: 38,

//             decoration: BoxDecoration(
//               color: accentColor.withValues(alpha: 0.12),
//               borderRadius: BorderRadius.circular(12),
//             ),

//             child: Icon(icon, color: accentLight, size: 19),
//           ),

//           const SizedBox(height: 14),

//           Text(
//             value,

//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.w900,
//             ),
//           ),

//           const SizedBox(height: 2),

//           Text(
//             title,

//             style: TextStyle(
//               color: Colors.white.withValues(alpha: 0.42),
//               fontSize: 10,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTodayAttendance() {
//     if (todayAttendance == null) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(20),

//         decoration: _cardDecoration(),

//         child: Row(
//           children: [
//             _iconBox(
//               Icons.access_time_rounded,
//               Colors.white.withValues(alpha: 0.08),
//               Colors.white54,
//             ),

//             const SizedBox(width: 13),

//             const Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,

//                 children: [
//                   Text(
//                     'Belum Absen',

//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),

//                   SizedBox(height: 4),

//                   Text(
//                     'Kamu belum melakukan absensi hari ini.',
//                     style: TextStyle(color: Colors.white54, fontSize: 11),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     final hadir = todayAttendance!.status.toLowerCase() == 'masuk';

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),

//       decoration: _cardDecoration(),

//       child: Column(
//         children: [
//           Row(
//             children: [
//               _iconBox(
//                 hadir ? Icons.check_circle_rounded : Icons.info_rounded,
//                 accentColor.withValues(alpha: 0.12),
//                 accentLight,
//               ),

//               const SizedBox(width: 13),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,

//                   children: [
//                     const Text(
//                       'Status Hari Ini',

//                       style: TextStyle(color: Colors.white54, fontSize: 10),
//                     ),

//                     const SizedBox(height: 3),

//                     Text(
//                       todayStatus,

//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 17,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               _badge(
//                 todayStatus.toUpperCase(),
//                 hadir ? accentColor : Colors.orange,
//               ),
//             ],
//           ),

//           const SizedBox(height: 18),

//           Row(
//             children: [
//               Expanded(
//                 child: _buildMiniInfo(
//                   'Check In',
//                   formatTime(todayAttendance!.checkIn),
//                   Icons.login_rounded,
//                 ),
//               ),

//               const SizedBox(width: 10),

//               Expanded(
//                 child: _buildMiniInfo(
//                   'Check Out',
//                   formatTime(todayAttendance!.checkOut),
//                   Icons.logout_rounded,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMiniInfo(String title, String value, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(12),

//       decoration: BoxDecoration(
//         color: Colors.black.withValues(alpha: 0.16),
//         borderRadius: BorderRadius.circular(14),
//       ),

//       child: Row(
//         children: [
//           Icon(icon, color: accentLight, size: 16),

//           const SizedBox(width: 8),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,

//               children: [
//                 Text(
//                   title,

//                   style: const TextStyle(color: Colors.white38, fontSize: 9),
//                 ),

//                 const SizedBox(height: 2),

//                 Text(
//                   value,

//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLocationCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(19),

//       decoration: _cardDecoration(),

//       child: Column(
//         children: [
//           Row(
//             children: [
//               _iconBox(
//                 Icons.location_on_rounded,
//                 accentColor.withValues(alpha: 0.12),
//                 accentLight,
//               ),

//               const SizedBox(width: 12),

//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,

//                   children: [
//                     Text(
//                       'Lokasi GPS',

//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 15,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),

//                     SizedBox(height: 3),

//                     Text(
//                       'Lokasi perangkat saat ini',

//                       style: TextStyle(color: Colors.white38, fontSize: 10),
//                     ),
//                   ],
//                 ),
//               ),

//               IconButton(
//                 onPressed: isLocationLoading ? null : getCurrentLocation,

//                 icon: isLocationLoading
//                     ? const SizedBox(
//                         width: 17,
//                         height: 17,

//                         child: CircularProgressIndicator(
//                           color: accentLight,
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : const Icon(Icons.refresh_rounded, color: accentLight),
//               ),
//             ],
//           ),

//           const SizedBox(height: 15),

//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(14),

//             decoration: BoxDecoration(
//               color: Colors.black.withValues(alpha: 0.16),
//               borderRadius: BorderRadius.circular(15),
//             ),

//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,

//               children: [
//                 const Icon(
//                   Icons.my_location_rounded,
//                   color: accentLight,
//                   size: 18,
//                 ),

//                 const SizedBox(width: 9),

//                 Expanded(
//                   child: Text(
//                     locationAddress,

//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           if (currentPosition != null) ...[
//             const SizedBox(height: 10),

//             Row(
//               children: [
//                 Expanded(
//                   child: _coordinate(
//                     'LATITUDE',
//                     currentPosition!.latitude.toStringAsFixed(6),
//                   ),
//                 ),

//                 const SizedBox(width: 10),

//                 Expanded(
//                   child: _coordinate(
//                     'LONGITUDE',
//                     currentPosition!.longitude.toStringAsFixed(6),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildMapPreview() {
//     final LatLng mapPosition = currentPosition != null
//         ? LatLng(currentPosition!.latitude, currentPosition!.longitude)
//         : defaultLocation;

//     return Container(
//       width: double.infinity,
//       height: 230,

//       clipBehavior: Clip.antiAlias,

//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(21),

//         border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
//       ),

//       child: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: mapPosition,
//               zoom: 15,
//             ),

//             myLocationEnabled: true,

//             myLocationButtonEnabled: false,

//             zoomControlsEnabled: false,

//             compassEnabled: false,

//             mapToolbarEnabled: false,

//             markers: currentPosition != null
//                 ? {
//                     Marker(
//                       markerId: const MarkerId('currentLocation'),

//                       position: LatLng(
//                         currentPosition!.latitude,
//                         currentPosition!.longitude,
//                       ),

//                       infoWindow: const InfoWindow(title: 'Lokasi Saya'),
//                     ),
//                   }
//                 : {},

//             onMapCreated: (GoogleMapController controller) {
//               mapController = controller;

//               if (currentPosition != null) {
//                 controller.animateCamera(
//                   CameraUpdate.newCameraPosition(
//                     CameraPosition(
//                       target: LatLng(
//                         currentPosition!.latitude,
//                         currentPosition!.longitude,
//                       ),
//                       zoom: 15,
//                     ),
//                   ),
//                 );
//               }
//             },
//           ),

//           // Label Lokasi Saya
//           Positioned(
//             top: 12,
//             left: 12,

//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

//               decoration: BoxDecoration(
//                 color: Colors.black.withValues(alpha: 0.75),
//                 borderRadius: BorderRadius.circular(12),
//               ),

//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,

//                 children: [
//                   Icon(Icons.location_on_rounded, color: accentLight, size: 16),

//                   SizedBox(width: 6),

//                   Text(
//                     'Lokasi Saya',

//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Tombol posisi GPS
//           Positioned(
//             bottom: 12,
//             right: 12,

//             child: FloatingActionButton.small(
//               heroTag: 'dashboardMapLocation',

//               backgroundColor: accentColor,

//               foregroundColor: Colors.black,

//               elevation: 3,

//               onPressed: getCurrentLocation,

//               child: const Icon(Icons.my_location_rounded, size: 18),
//             ),
//           ),

//           // Overlay ketika GPS belum tersedia
//           if (currentPosition == null)
//             Positioned.fill(
//               child: IgnorePointer(
//                 child: Container(
//                   color: Colors.black.withValues(alpha: 0.25),

//                   child: Center(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 15,
//                         vertical: 10,
//                       ),

//                       decoration: BoxDecoration(
//                         color: Colors.black.withValues(alpha: 0.75),
//                         borderRadius: BorderRadius.circular(14),
//                       ),

//                       child: const Row(
//                         mainAxisSize: MainAxisSize.min,

//                         children: [
//                           SizedBox(
//                             width: 16,
//                             height: 16,

//                             child: CircularProgressIndicator(
//                               color: accentLight,
//                               strokeWidth: 2,
//                             ),
//                           ),

//                           SizedBox(width: 9),

//                           Text(
//                             'Mencari lokasi...',

//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _coordinate(String title, String value) {
//     return Container(
//       padding: const EdgeInsets.all(11),

//       decoration: BoxDecoration(
//         color: accentColor.withValues(alpha: 0.06),

//         borderRadius: BorderRadius.circular(13),

//         border: Border.all(color: accentColor.withValues(alpha: 0.10)),
//       ),

//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,

//         children: [
//           Text(
//             title,

//             style: const TextStyle(
//               color: Colors.white38,
//               fontSize: 8,
//               fontWeight: FontWeight.w700,
//             ),
//           ),

//           const SizedBox(height: 3),

//           Text(
//             value,

//             style: const TextStyle(
//               color: accentLight,
//               fontSize: 10,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHistoryCard(AttendanceModel item) {
//     final isIzin = item.status.toLowerCase() == 'izin';

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(17),

//       decoration: _cardDecoration(),

//       child: Row(
//         children: [
//           _iconBox(
//             isIzin ? Icons.sick_rounded : Icons.calendar_month_rounded,
//             accentColor.withValues(alpha: 0.10),
//             accentLight,
//           ),

//           const SizedBox(width: 12),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,

//               children: [
//                 Text(
//                   formatDate(item.checkIn ?? item.createdAt),

//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),

//                 const SizedBox(height: 4),

//                 Text(
//                   isIzin
//                       ? 'Izin Sakit'
//                       : 'Check In ${formatTime(item.checkIn)}',

//                   style: const TextStyle(color: Colors.white54, fontSize: 10),
//                 ),
//               ],
//             ),
//           ),

//           _badge(
//             item.status.toUpperCase(),
//             isIzin ? Colors.orange : accentColor,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyHistory() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(25),

//       decoration: _cardDecoration(),

//       child: Column(
//         children: [
//           const Icon(Icons.history_rounded, color: Colors.white24, size: 42),

//           const SizedBox(height: 10),

//           const Text(
//             'Belum ada riwayat',

//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
//           ),

//           const SizedBox(height: 4),

//           Text(
//             'Riwayat absensi akan muncul di sini.',

//             style: TextStyle(
//               color: Colors.white.withValues(alpha: 0.40),
//               fontSize: 11,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSeeAllButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 48,

//       child: OutlinedButton(
//         onPressed: openHistory,

//         style: OutlinedButton.styleFrom(
//           foregroundColor: accentLight,

//           side: BorderSide(color: accentColor.withValues(alpha: 0.25)),

//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//         ),

//         child: const Text(
//           'Lihat Semua Riwayat',

//           style: TextStyle(fontWeight: FontWeight.w800),
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomNavigationBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: bgColor,

//         border: Border(
//           top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
//         ),
//       ),

//       child: NavigationBarTheme(
//         data: NavigationBarThemeData(
//           backgroundColor: bgColor,

//           indicatorColor: accentColor.withValues(alpha: 0.15),

//           labelTextStyle: WidgetStateProperty.all(
//             const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
//           ),

//           iconTheme: WidgetStateProperty.resolveWith((states) {
//             if (states.contains(WidgetState.selected)) {
//               return const IconThemeData(color: accentLight);
//             }

//             return const IconThemeData(color: Colors.white38);
//           }),
//         ),

//         child: NavigationBar(
//           height: 70,

//           selectedIndex: 0,

//           onDestinationSelected: (index) {
//             if (index == 1) {
//               openHistory();
//             } else if (index == 2) {
//               openAttendance();
//             } else if (index == 3) {
//               openProfile();
//             }
//           },

//           destinations: const [
//             NavigationDestination(
//               icon: Icon(Icons.home_outlined),
//               selectedIcon: Icon(Icons.home_rounded),
//               label: 'Home',
//             ),

//             NavigationDestination(
//               icon: Icon(Icons.history_outlined),
//               selectedIcon: Icon(Icons.history_rounded),
//               label: 'Riwayat',
//             ),

//             NavigationDestination(
//               icon: Icon(Icons.fingerprint_outlined),
//               selectedIcon: Icon(Icons.fingerprint_rounded),
//               label: 'Absensi',
//             ),

//             NavigationDestination(
//               icon: Icon(Icons.person_outline_rounded),
//               selectedIcon: Icon(Icons.person_rounded),
//               label: 'Profil',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _iconBox(IconData icon, Color background, Color foreground) {
//     return Container(
//       width: 43,
//       height: 43,

//       decoration: BoxDecoration(
//         color: background,
//         borderRadius: BorderRadius.circular(14),
//       ),

//       child: Icon(icon, color: foreground, size: 20),
//     );
//   }

//   Widget _badge(String text, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),

//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.10),
//         borderRadius: BorderRadius.circular(20),
//       ),

//       child: Text(
//         text,

//         style: TextStyle(
//           color: color,
//           fontSize: 8,
//           fontWeight: FontWeight.w900,
//         ),
//       ),
//     );
//   }

//   BoxDecoration _cardDecoration() {
//     return BoxDecoration(
//       color: cardColor,

//       borderRadius: BorderRadius.circular(21),

//       border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// import '../../models/attendance_model.dart';
// import '../../services/api_services.dart';
// import '../../services/storage_services.dart';
// import '../attendance/attendance_screen.dart';
// import '../attendance/history_screen.dart';
// import '../profile/profile_screen.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   String userName = 'Pengguna';

//   bool isLoading = false;
//   bool isLocationLoading = false;

//   List<AttendanceModel> attendanceList = [];
//   AttendanceModel? todayAttendance;

//   String locationAddress = 'Mencari lokasi...';

//   Position? currentPosition;
//   GoogleMapController? mapController;

//   final LatLng defaultLocation = const LatLng(-6.2000, 106.816666);

//   @override
//   void initState() {
//     super.initState();
//     loadDashboard();
//     getCurrentLocation();
//   }

//   Future<void> loadDashboard() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final token = await StorageServices.getToken();

//       if (token == null || token.isEmpty) {
//         return;
//       }

//       final profileResponse = await ApiServices().getProfile(token: token);

//       if (profileResponse.statusCode == 200) {
//         final profileData = profileResponse.data['data'];

//         if (profileData != null && mounted) {
//           setState(() {
//             userName = profileData['name']?.toString() ?? 'Pengguna';
//           });
//         }
//       }

//       final now = DateTime.now();

//       final historyResponse = await ApiServices().getHistory(
//         token: token,
//         start: '${now.year}-01-01',
//         end: '${now.year}-12-31',
//       );

//       if (historyResponse.statusCode == 200) {
//         final data = historyResponse.data['data'];

//         if (data is List) {
//           final list = data
//               .map(
//                 (item) =>
//                     AttendanceModel.fromJson(Map<String, dynamic>.from(item)),
//               )
//               .toList();

//           AttendanceModel? today;

//           for (final item in list) {
//             if (item.checkIn != null) {
//               final parsedDate = DateTime.tryParse(item.checkIn!);

//               if (parsedDate != null &&
//                   parsedDate.year == now.year &&
//                   parsedDate.month == now.month &&
//                   parsedDate.day == now.day) {
//                 today = item;
//                 break;
//               }
//             }
//           }

//           if (mounted) {
//             setState(() {
//               attendanceList = list;
//               todayAttendance = today;
//             });
//           }
//         }
//       }
//     } catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Gagal memuat dashboard: $error')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> getCurrentLocation() async {
//     setState(() {
//       isLocationLoading = true;
//     });

//     try {
//       final serviceEnabled = await Geolocator.isLocationServiceEnabled();

//       if (!serviceEnabled) {
//         if (mounted) {
//           setState(() {
//             locationAddress = 'GPS belum aktif';
//             isLocationLoading = false;
//           });
//         }
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();

//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }

//       if (permission == LocationPermission.denied) {
//         if (mounted) {
//           setState(() {
//             locationAddress = 'Izin lokasi ditolak';
//             isLocationLoading = false;
//           });
//         }
//         return;
//       }

//       if (permission == LocationPermission.deniedForever) {
//         if (mounted) {
//           setState(() {
//             locationAddress = 'Izin lokasi ditolak permanen';
//             isLocationLoading = false;
//           });
//         }
//         return;
//       }

//       final position = await Geolocator.getCurrentPosition();

//       if (!mounted) return;

//       setState(() {
//         currentPosition = position;
//         locationAddress =
//             '${position.latitude.toStringAsFixed(6)}, '
//             '${position.longitude.toStringAsFixed(6)}';
//         isLocationLoading = false;
//       });

//       mapController?.animateCamera(
//         CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
//       );
//     } catch (error) {
//       if (mounted) {
//         setState(() {
//           locationAddress = 'Gagal mendapatkan lokasi';
//           isLocationLoading = false;
//         });
//       }
//     }
//   }

//   int get totalAttendance {
//     return attendanceList
//         .where((item) => item.status?.toLowerCase() == 'masuk')
//         .length;
//   }

//   int get totalCheckOut {
//     return attendanceList
//         .where((item) => item.checkOut != null && item.checkOut!.isNotEmpty)
//         .length;
//   }

//   int get totalIzinSakit {
//     return attendanceList
//         .where((item) => item.status?.toLowerCase() == 'izin')
//         .length;
//   }

//   String get todayStatus {
//     if (todayAttendance == null) {
//       return 'Belum Absen';
//     }

//     if (todayAttendance!.status?.toLowerCase() == 'izin') {
//       return 'Izin Sakit';
//     }

//     if (todayAttendance!.status?.toLowerCase() == 'masuk') {
//       return 'Hadir';
//     }

//     // ignore: dead_code
//     return todayAttendance!.status ?? 'Belum Absen';
//   }

//   String formatDate(String? value) {
//     if (value == null || value.isEmpty) {
//       return '-';
//     }

//     final date = DateTime.tryParse(value);

//     if (date == null) {
//       return value;
//     }

//     return '${date.day.toString().padLeft(2, '0')}/'
//         '${date.month.toString().padLeft(2, '0')}/'
//         '${date.year}';
//   }

//   String formatTime(String? value) {
//     if (value == null || value.isEmpty) {
//       return '-';
//     }

//     final date = DateTime.tryParse(value);

//     if (date == null) {
//       return value;
//     }

//     return '${date.hour.toString().padLeft(2, '0')}:'
//         '${date.minute.toString().padLeft(2, '0')}';
//   }

//   Set<Marker> get currentMarker {
//     if (currentPosition == null) {
//       return {};
//     }

//     return {
//       Marker(
//         markerId: const MarkerId('currentLocation'),
//         position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
//         infoWindow: const InfoWindow(title: 'Lokasi Saya'),
//       ),
//     };
//   }

//   void openAttendance() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const AttendanceScreen()),
//     );
//   }

//   void openHistory() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const HistoryScreen()),
//     );
//   }

//   void openProfile() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const ProfileScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: loadDashboard,
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeader(),

//                 const SizedBox(height: 22),

//                 _buildWelcomeCard(),

//                 const SizedBox(height: 22),

//                 const Text(
//                   'Statistik Absensi',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
//                 ),

//                 const SizedBox(height: 12),

//                 _buildStatistics(),

//                 const SizedBox(height: 24),

//                 const Text(
//                   'Absensi Hari Ini',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
//                 ),

//                 const SizedBox(height: 12),

//                 _buildTodayAttendance(),

//                 const SizedBox(height: 24),

//                 const Text(
//                   'Lokasi Saya',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
//                 ),

//                 const SizedBox(height: 12),

//                 _buildLocationCard(),

//                 const SizedBox(height: 24),

//                 const Text(
//                   'Riwayat Kehadiran',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
//                 ),

//                 const SizedBox(height: 8),

//                 _buildHistoryHeader(),

//                 const SizedBox(height: 12),

//                 if (attendanceList.isEmpty)
//                   _buildEmptyHistory()
//                 else
//                   ...attendanceList
//                       .take(3)
//                       .map(
//                         (item) => Padding(
//                           padding: const EdgeInsets.only(bottom: 12),
//                           child: _buildHistoryCard(item),
//                         ),
//                       ),

//                 if (attendanceList.length > 3) _buildSeeAllButton(),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       children: [
//         Container(
//           width: 48,
//           height: 48,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             gradient: const LinearGradient(
//               colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
//             ),
//           ),
//           child: Center(
//             child: Text(
//               userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Selamat datang 👋',
//                 style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 userName,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontSize: 19,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         IconButton(
//           onPressed: openProfile,
//           style: IconButton.styleFrom(
//             backgroundColor: Theme.of(context)
//                 .colorScheme
//                 .surfaceContainerHighest,
//           ),
//           icon: const Icon(Icons.person_outline),
//         ),
//       ],
//     );
//   }

//   Widget _buildWelcomeCard() {
//     final now = DateTime.now();

//     final weekdays = [
//       'Senin',
//       'Selasa',
//       'Rabu',
//       'Kamis',
//       'Jumat',
//       'Sabtu',
//       'Minggu',
//     ];

//     final months = [
//       'Januari',
//       'Februari',
//       'Maret',
//       'April',
//       'Mei',
//       'Juni',
//       'Juli',
//       'Agustus',
//       'September',
//       'Oktober',
//       'November',
//       'Desember',
//     ];

//     final dateText =
//         '${weekdays[now.weekday - 1]}, '
//         '${now.day} '
//         '${months[now.month - 1]} '
//         '${now.year}';

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(26),
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color.fromARGB(255, 54, 63, 82),
//             Color.fromARGB(255, 27, 25, 68),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: const Color.fromARGB(
//               255,
//               53,
//               64,
//               73,
//             ).withValues(alpha: 0.20),
//             blurRadius: 25,
//             offset: const Offset(0, 12),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   dateText,
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withValues(alpha: 0.16),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.verified_rounded, size: 14, color: Colors.white),
//                     SizedBox(width: 5),
//                     Text(
//                       'Absensi',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 11,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 18),
//           const Text(
//             'Tetap semangat hari ini!',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 23,
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//           const SizedBox(height: 6),
//           const Text(
//             'Jangan lupa lakukan absensi sesuai kondisi kamu.',
//             style: TextStyle(color: Colors.white70, fontSize: 13),
//           ),
//           const SizedBox(height: 18),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: openAttendance,
//               icon: const Icon(Icons.fingerprint),
//               label: const Text('Buka Absensi'),
//               style: ElevatedButton.styleFrom(
//                 elevation: 0,
//                 backgroundColor: Colors.white,
//                 foregroundColor: const Color(0xFF2563EB),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatistics() {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildStatCard(
//             title: 'Hadir',
//             value: '$totalAttendance',
//             icon: Icons.check_circle_rounded,
//             iconColor: Colors.green,
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: _buildStatCard(
//             title: 'Check Out',
//             value: '$totalCheckOut',
//             icon: Icons.logout_rounded,
//             iconColor: Colors.orange,
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: _buildStatCard(
//             title: 'Izin Sakit',
//             value: '$totalIzinSakit',
//             icon: Icons.sick_rounded,
//             iconColor: Colors.redAccent,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color iconColor,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey.withValues(alpha: 0.10)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 15,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               color: iconColor.withValues(alpha: 0.12),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, size: 20, color: iconColor),
//           ),
//           const SizedBox(height: 14),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
//           ),
//           const SizedBox(height: 3),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 11,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTodayAttendance() {
//     if (todayAttendance == null) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.surface,
//           borderRadius: BorderRadius.circular(22),
//           border: Border.all(color: Colors.grey.withValues(alpha: 0.10)),
//         ),
//         child: const Row(
//           children: [
//             CircleAvatar(
//               radius: 24,
//               backgroundColor: Color(0xFFFFF4E5),
//               child: Icon(Icons.event_available_rounded, color: Colors.orange),
//             ),
//             SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Belum ada absensi',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     'Kamu belum melakukan absensi hari ini.',
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     final isIzin = todayAttendance!.status?.toLowerCase() == 'izin';

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: isIzin
//               ? Colors.red.withValues(alpha: 0.15)
//               : Colors.green.withValues(alpha: 0.15),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.03),
//             blurRadius: 18,
//             offset: const Offset(0, 7),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: isIzin
//                       ? Colors.red.withValues(alpha: 0.10)
//                       : Colors.green.withValues(alpha: 0.10),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Icon(
//                   isIzin ? Icons.sick_rounded : Icons.check_circle_rounded,
//                   color: isIzin ? Colors.redAccent : Colors.green,
//                 ),
//               ),
//               const SizedBox(width: 13),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       todayStatus,
//                       style: const TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       formatDate(todayAttendance!.checkIn),
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               _statusBadge(
//                 isIzin ? 'Izin Sakit' : 'Hadir',
//                 isIzin ? Colors.redAccent : Colors.green,
//               ),
//             ],
//           ),

//           const SizedBox(height: 18),

//           if (isIzin)
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: Colors.red.withValues(alpha: 0.06),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Icon(
//                     Icons.medical_information_outlined,
//                     size: 20,
//                     color: Colors.redAccent,
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Alasan Izin',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey.shade600,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 3),
//                         Text(
//                           todayAttendance!.alasanIzin?.isNotEmpty == true
//                               ? todayAttendance!.alasanIzin!
//                               : 'Izin sakit',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           else
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildTimeInfo(
//                     icon: Icons.login_rounded,
//                     title: 'Check In',
//                     time: formatTime(todayAttendance!.checkIn),
//                     color: Colors.green,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: _buildTimeInfo(
//                     icon: Icons.logout_rounded,
//                     title: 'Check Out',
//                     time: formatTime(todayAttendance!.checkOut),
//                     color: Colors.orange,
//                   ),
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimeInfo({
//     required IconData icon,
//     required String title,
//     required String time,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.06),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 19, color: color),
//           const SizedBox(width: 9),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   time,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _statusBadge(String text, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.10),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: color,
//           fontSize: 10,
//           fontWeight: FontWeight.w800,
//         ),
//       ),
//     );
//   }

//   Widget _buildLocationCard() {
//     return Container(
//       width: double.infinity,
//       height: 235,
//       clipBehavior: Clip.antiAlias,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 18,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: currentPosition != null
//                   ? LatLng(
//                       currentPosition!.latitude,
//                       currentPosition!.longitude,
//                     )
//                   : defaultLocation,
//               zoom: 16,
//             ),
//             markers: currentMarker,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: false,
//             zoomControlsEnabled: false,
//             mapToolbarEnabled: false,
//             onMapCreated: (controller) {
//               mapController = controller;
//             },
//           ),

//           Positioned(
//             left: 14,
//             right: 14,
//             bottom: 14,
//             child: Container(
//               padding: const EdgeInsets.all(13),
//               decoration: BoxDecoration(
//                 color: Colors.white.withValues(alpha: 0.95),
//                 borderRadius: BorderRadius.circular(17),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 38,
//                     height: 38,
//                     decoration: BoxDecoration(
//                       color: Colors.blue.withValues(alpha: 0.10),
//                       borderRadius: BorderRadius.circular(11),
//                     ),
//                     child: const Icon(
//                       Icons.location_on_rounded,
//                       color: Colors.blue,
//                       size: 21,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Lokasi saat ini',
//                           style: TextStyle(fontSize: 11, color: Colors.black54),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           locationAddress,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w800,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: isLocationLoading ? null : getCurrentLocation,
//                     icon: isLocationLoading
//                         ? const SizedBox(
//                             width: 18,
//                             height: 18,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Icon(Icons.refresh_rounded, color: Colors.blue),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHistoryHeader() {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             'Absensi terbaru kamu',
//             style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//           ),
//         ),
//         TextButton(
//           onPressed: openHistory,
//           child: const Text(
//             'Lihat Semua',
//             style: TextStyle(fontWeight: FontWeight.w800),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildHistoryCard(AttendanceModel item) {
//     final isIzin = item.status?.toLowerCase() == 'izin';

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(17),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey.withValues(alpha: 0.10)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 42,
//                 height: 42,
//                 decoration: BoxDecoration(
//                   color: isIzin
//                       ? Colors.red.withValues(alpha: 0.10)
//                       : Colors.blue.withValues(alpha: 0.10),
//                   borderRadius: BorderRadius.circular(13),
//                 ),
//                 child: Icon(
//                   isIzin ? Icons.sick_rounded : Icons.calendar_today_rounded,
//                   size: 19,
//                   color: isIzin ? Colors.redAccent : Colors.blue,
//                 ),
//               ),
//               const SizedBox(width: 11),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       formatDate(item.checkIn),
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       isIzin ? 'Izin Sakit' : 'Absensi Kehadiran',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               _statusBadge(
//                 isIzin ? 'Izin Sakit' : 'Hadir',
//                 isIzin ? Colors.redAccent : Colors.green,
//               ),
//             ],
//           ),

//           const SizedBox(height: 13),

//           if (isIzin)
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 item.alasanIzin?.isNotEmpty == true
//                     ? item.alasanIzin!
//                     : 'Izin sakit',
//                 style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
//               ),
//             )
//           else
//             Row(
//               children: [
//                 Expanded(
//                   child: _smallTimeCard(
//                     title: 'Masuk',
//                     value: formatTime(item.checkIn),
//                     icon: Icons.login_rounded,
//                     color: Colors.green,
//                   ),
//                 ),
//                 const SizedBox(width: 9),
//                 Expanded(
//                   child: _smallTimeCard(
//                     title: 'Pulang',
//                     value: formatTime(item.checkOut),
//                     icon: Icons.logout_rounded,
//                     color: Colors.orange,
//                   ),
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _smallTimeCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(11),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.06),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 17, color: color),
//           const SizedBox(width: 7),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyHistory() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: const Column(
//         children: [
//           Icon(Icons.history_rounded, size: 42, color: Colors.grey),
//           SizedBox(height: 10),
//           Text(
//             'Belum ada riwayat absensi',
//             style: TextStyle(fontWeight: FontWeight.w800),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSeeAllButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: OutlinedButton(
//         onPressed: openHistory,
//         style: OutlinedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//         ),
//         child: const Text(
//           'Lihat Semua Riwayat',
//           style: TextStyle(fontWeight: FontWeight.w800),
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomNavigationBar() {
//     return NavigationBar(
//       selectedIndex: 0,
//       onDestinationSelected: (index) {
//         if (index == 1) {
//           openHistory();
//         } else if (index == 2) {
//           openAttendance();
//         } else if (index == 3) {
//           openProfile();
//         }
//       },
//       destinations: const [
//         NavigationDestination(
//           icon: Icon(Icons.home_outlined),
//           selectedIcon: Icon(Icons.home_rounded),
//           label: 'Home',
//         ),
//         NavigationDestination(
//           icon: Icon(Icons.history_outlined),
//           selectedIcon: Icon(Icons.history_rounded),
//           label: 'Riwayat',
//         ),
//         NavigationDestination(
//           icon: Icon(Icons.fingerprint_outlined),
//           selectedIcon: Icon(Icons.fingerprint_rounded),
//           label: 'Absensi',
//         ),
//         NavigationDestination(
//           icon: Icon(Icons.person_outline_rounded),
//           selectedIcon: Icon(Icons.person_rounded),
//           label: 'Profil',
//         ),
//       ],
//     );
//   }
// }
