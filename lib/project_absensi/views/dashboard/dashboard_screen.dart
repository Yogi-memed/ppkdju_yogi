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
  String userName = 'Memuat...';

  bool isLoading = true;

  List<AttendanceModel> attendanceList = [];

  AttendanceModel? todayAttendance;

  String locationAddress = 'Mengambil lokasi...';

  String locationCoordinate = '';

  Position? currentPosition;

  GoogleMapController? mapController;

  static const LatLng defaultLocation = LatLng(-6.2000, 106.816666);

  @override
  void initState() {
    super.initState();

    loadDashboard();

    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          locationAddress = 'GPS belum aktif';
          locationCoordinate = '';
          currentPosition = null;
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
          locationCoordinate = '';
          currentPosition = null;
        });

        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          locationAddress = 'Izin lokasi ditolak permanen';
          locationCoordinate = '';
          currentPosition = null;
        });

        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        currentPosition = position;

        locationAddress = 'Lokasi Anda';

        locationCoordinate =
            '${position.latitude.toStringAsFixed(6)}, '
            '${position.longitude.toStringAsFixed(6)}';
      });

      if (mapController != null) {
        await mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 17,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        locationAddress = 'Gagal mengambil lokasi';
        locationCoordinate = '';
        currentPosition = null;
      });
    }
  }

  Future<void> loadDashboard() async {
    try {
      final token = await StorageServices.getToken();

      if (token == null) {
        return;
      }

      final profileResponse = await ApiServices().getProfile(token: token);

      final now = DateTime.now();

      final historyResponse = await ApiServices().getHistory(
        token: token,
        start: '${now.year}-01-01',
        end: '${now.year}-12-31',
      );

      if (profileResponse.statusCode == 200 &&
          historyResponse.statusCode == 200) {
        final user = profileResponse.data['data'];

        final List data = historyResponse.data['data'];

        final List<AttendanceModel> history = data
            .map((item) => AttendanceModel.fromJson(item))
            .toList();

        AttendanceModel? today;

        for (final item in history) {
          if (item.checkIn != null) {
            final checkInDate = DateTime.tryParse(item.checkIn!);

            if (checkInDate != null &&
                checkInDate.year == now.year &&
                checkInDate.month == now.month &&
                checkInDate.day == now.day) {
              today = item;
              break;
            }
          }
        }

        if (!mounted) return;

        setState(() {
          userName = user['name'] ?? '-';

          attendanceList = history;

          todayAttendance = today;

          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data dashboard: $e')),
      );
    }
  }

  String get todayDate {
    final now = DateTime.now();

    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';
  }

  int get totalAttendance {
    return attendanceList.length;
  }

  int get totalCheckIn {
    return attendanceList.where((item) => item.checkIn != null).length;
  }

  int get totalCheckOut {
    return attendanceList.where((item) => item.checkOut != null).length;
  }

  Set<Marker> get currentMarker {
    if (currentPosition == null) {
      return {};
    }

    return {
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        infoWindow: const InfoWindow(
          title: 'Lokasi Anda',
          snippet: 'Posisi GPS saat ini',
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9E9E9E),

      appBar: AppBar(
        backgroundColor: const Color(0xFF757575),
        foregroundColor: Colors.white,
        title: const Text(
          'Absensi Black PPKDJU',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await loadDashboard();
                await getCurrentLocation();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning, $userName!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Tanggal hari ini: $todayDate',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // GOOGLE MAPS
                    // =========================
                    Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: defaultLocation,
                          zoom: 14,
                        ),
                        onMapCreated: (controller) {
                          mapController = controller;

                          if (currentPosition != null) {
                            controller.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(
                                    currentPosition!.latitude,
                                    currentPosition!.longitude,
                                  ),
                                  zoom: 17,
                                ),
                              ),
                            );
                          }
                        },
                        markers: currentMarker,
                        myLocationEnabled: currentPosition != null,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        compassEnabled: true,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // =========================
                    // INFO LOKASI
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
                            size: 28,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Lokasi Anda',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  locationAddress,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),

                                if (locationCoordinate.isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Text(
                                    locationCoordinate,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // =========================
                    // CHECK IN / CHECK OUT
                    // =========================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF424242),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _AttendanceButton(
                              title: 'Check In',
                              icon: Icons.login,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AttendanceScreen(),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _AttendanceButton(
                              title: 'Check Out',
                              icon: Icons.logout,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AttendanceScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // =========================
                    // STATISTIK
                    // =========================
                    const Text(
                      'Statistik Absensi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _StatisticCard(
                            title: 'Total',
                            value: totalAttendance.toString(),
                            icon: Icons.calendar_month,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _StatisticCard(
                            title: 'Check In',
                            value: totalCheckIn.toString(),
                            icon: Icons.login,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _StatisticCard(
                            title: 'Check Out',
                            value: totalCheckOut.toString(),
                            icon: Icons.logout,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // ABSENSI HARI INI
                    // =========================
                    const Text(
                      'Absensi Hari Ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF616161),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: todayAttendance == null
                          ? const Text(
                              'Belum ada absensi hari ini',
                              style: TextStyle(color: Colors.white),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status: '
                                  '${todayAttendance!.status}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  'Check In: '
                                  '${todayAttendance!.checkIn ?? '-'}',
                                  style: const TextStyle(color: Colors.white),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  'Check Out: '
                                  '${todayAttendance!.checkOut ?? '-'}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // RIWAYAT
                    // =========================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Riwayat Kehadiran',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HistoryScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Lihat Semua',
                            style: TextStyle(
                              color: Color(0xFF66B5A5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    if (attendanceList.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF616161),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.history_toggle_off,
                              color: Colors.white70,
                              size: 42,
                            ),

                            SizedBox(height: 10),

                            Text(
                              'Belum ada riwayat absensi',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              'Riwayat absensi kamu akan '
                              'muncul di sini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: attendanceList
                            .take(3)
                            .map((item) => _HistoryCard(item: item))
                            .toList(),
                      ),

                    if (attendanceList.length > 3)
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HistoryScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Lihat semua riwayat'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF66B5A5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF424242),
        selectedItemColor: const Color(0xFF66B5A5),
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Kehadiran',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AttendanceScreen()),
            );
          }
        },
      ),
    );
  }
}

// ==================================================
// ATTENDANCE BUTTON
// ==================================================

class _AttendanceButton extends StatelessWidget {
  final String title;

  final IconData icon;

  final VoidCallback onPressed;

  const _AttendanceButton({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF66B5A5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ==================================================
// STATISTIC CARD
// ==================================================

class _StatisticCard extends StatelessWidget {
  final String title;

  final String value;

  final IconData icon;

  const _StatisticCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF616161),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 25),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ==================================================
// HISTORY CARD
// ==================================================

class _HistoryCard extends StatelessWidget {
  final AttendanceModel item;

  const _HistoryCard({required this.item});

  String formatDate(String? value) {
    if (value == null) {
      return '-';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  String formatTime(String? value) {
    if (value == null) {
      return '-';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF616161),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          // HEADER
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF66B5A5).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: Color(0xFF66B5A5),
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
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white60,
                          size: 14,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            item.checkInAddress ?? 'Lokasi tidak tersedia',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
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
                  color: const Color(0xFF66B5A5).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF66B5A5),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // CHECK IN / CHECK OUT
          Row(
            children: [
              Expanded(
                child: _TimeCard(
                  icon: Icons.login,
                  iconColor: Colors.greenAccent,
                  title: 'Check In',
                  time: formatTime(item.checkIn),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _TimeCard(
                  icon: Icons.logout,
                  iconColor: Colors.orangeAccent,
                  title: 'Check Out',
                  time: formatTime(item.checkOut),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================================================
// TIME CARD
// ==================================================

class _TimeCard extends StatelessWidget {
  final IconData icon;

  final Color iconColor;

  final String title;

  final String time;

  const _TimeCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),

              const SizedBox(height: 3),

              Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
