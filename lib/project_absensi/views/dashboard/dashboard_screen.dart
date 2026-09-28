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
  String userName = 'Pengguna';

  bool isLoading = false;
  bool isLocationLoading = false;

  List<AttendanceModel> attendanceList = [];
  AttendanceModel? todayAttendance;

  String locationAddress = 'Mencari lokasi...';

  Position? currentPosition;
  GoogleMapController? mapController;

  final LatLng defaultLocation = const LatLng(-6.2000, 106.816666);

  @override
  void initState() {
    super.initState();
    loadDashboard();
    getCurrentLocation();
  }

  Future<void> loadDashboard() async {
    setState(() {
      isLoading = true;
    });

    try {
      final token = await StorageServices.getToken();

      if (token == null || token.isEmpty) {
        return;
      }

      final profileResponse = await ApiServices().getProfile(token: token);

      if (profileResponse.statusCode == 200) {
        final profileData = profileResponse.data['data'];

        if (profileData != null && mounted) {
          setState(() {
            userName = profileData['name']?.toString() ?? 'Pengguna';
          });
        }
      }

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
            if (item.checkIn != null) {
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

  Future<void> getCurrentLocation() async {
    setState(() {
      isLocationLoading = true;
    });

    try {
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

      final position = await Geolocator.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        currentPosition = position;
        locationAddress =
            '${position.latitude.toStringAsFixed(6)}, '
            '${position.longitude.toStringAsFixed(6)}';
        isLocationLoading = false;
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          locationAddress = 'Gagal mendapatkan lokasi';
          isLocationLoading = false;
        });
      }
    }
  }

  int get totalAttendance {
    return attendanceList
        .where((item) => item.status?.toLowerCase() == 'masuk')
        .length;
  }

  int get totalCheckOut {
    return attendanceList
        .where((item) => item.checkOut != null && item.checkOut!.isNotEmpty)
        .length;
  }

  int get totalIzinSakit {
    return attendanceList
        .where((item) => item.status?.toLowerCase() == 'izin')
        .length;
  }

  String get todayStatus {
    if (todayAttendance == null) {
      return 'Belum Absen';
    }

    if (todayAttendance!.status?.toLowerCase() == 'izin') {
      return 'Izin Sakit';
    }

    if (todayAttendance!.status?.toLowerCase() == 'masuk') {
      return 'Hadir';
    }

    // ignore: dead_code
    return todayAttendance!.status ?? 'Belum Absen';
  }

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

  Set<Marker> get currentMarker {
    if (currentPosition == null) {
      return {};
    }

    return {
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        infoWindow: const InfoWindow(title: 'Lokasi Saya'),
      ),
    };
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(height: 22),

                _buildWelcomeCard(),

                const SizedBox(height: 22),

                const Text(
                  'Statistik Absensi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 12),

                _buildStatistics(),

                const SizedBox(height: 24),

                const Text(
                  'Absensi Hari Ini',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 12),

                _buildTodayAttendance(),

                const SizedBox(height: 24),

                const Text(
                  'Lokasi Saya',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 12),

                _buildLocationCard(),

                const SizedBox(height: 24),

                const Text(
                  'Riwayat Kehadiran',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),

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
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
            ),
          ),
          child: Center(
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
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
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: openProfile,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
          ),
          icon: const Icon(Icons.person_outline),
        ),
      ],
    );
  }

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
          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.20),
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
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
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
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      'Absensi',
                      style: TextStyle(
                        color: Colors.white,
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
          const Text(
            'Jangan lupa lakukan absensi sesuai kondisi kamu.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: openAttendance,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Buka Absensi'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2563EB),
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

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Hadir',
            value: '$totalAttendance',
            icon: Icons.check_circle_rounded,
            iconColor: Colors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            title: 'Check Out',
            value: '$totalCheckOut',
            icon: Icons.logout_rounded,
            iconColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            title: 'Izin Sakit',
            value: '$totalIzinSakit',
            icon: Icons.sick_rounded,
            iconColor: Colors.redAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAttendance() {
    if (todayAttendance == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.10)),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFFFF4E5),
              child: Icon(Icons.event_available_rounded, color: Colors.orange),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Belum ada absensi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kamu belum melakukan absensi hari ini.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isIzin = todayAttendance!.status?.toLowerCase() == 'izin';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isIzin
              ? Colors.red.withValues(alpha: 0.15)
              : Colors.green.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isIzin
                      ? Colors.red.withValues(alpha: 0.10)
                      : Colors.green.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  isIzin ? Icons.sick_rounded : Icons.check_circle_rounded,
                  color: isIzin ? Colors.redAccent : Colors.green,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todayStatus,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(todayAttendance!.checkIn),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(
                isIzin ? 'Izin Sakit' : 'Hadir',
                isIzin ? Colors.redAccent : Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (isIzin)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.medical_information_outlined,
                    size: 20,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alasan Izin',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          todayAttendance!.alasanIzin?.isNotEmpty == true
                              ? todayAttendance!.alasanIzin!
                              : 'Izin sakit',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildTimeInfo(
                    icon: Icons.login_rounded,
                    title: 'Check In',
                    time: formatTime(todayAttendance!.checkIn),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTimeInfo(
                    icon: Icons.logout_rounded,
                    title: 'Check Out',
                    time: formatTime(todayAttendance!.checkOut),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      height: 235,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentPosition != null
                  ? LatLng(
                      currentPosition!.latitude,
                      currentPosition!.longitude,
                    )
                  : defaultLocation,
              zoom: 16,
            ),
            markers: currentMarker,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              mapController = controller;
            },
          ),

          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.blue,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lokasi saat ini',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          locationAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: isLocationLoading ? null : getCurrentLocation,
                    icon: isLocationLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Absensi terbaru kamu',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
        TextButton(
          onPressed: openHistory,
          child: const Text(
            'Lihat Semua',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(AttendanceModel item) {
    final isIzin = item.status?.toLowerCase() == 'izin';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isIzin
                      ? Colors.red.withValues(alpha: 0.10)
                      : Colors.blue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isIzin ? Icons.sick_rounded : Icons.calendar_today_rounded,
                  size: 19,
                  color: isIzin ? Colors.redAccent : Colors.blue,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(item.checkIn),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isIzin ? 'Izin Sakit' : 'Absensi Kehadiran',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(
                isIzin ? 'Izin Sakit' : 'Hadir',
                isIzin ? Colors.redAccent : Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 13),

          if (isIzin)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.alasanIzin?.isNotEmpty == true
                    ? item.alasanIzin!
                    : 'Izin sakit',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _smallTimeCard(
                    title: 'Masuk',
                    value: formatTime(item.checkIn),
                    icon: Icons.login_rounded,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _smallTimeCard(
                    title: 'Pulang',
                    value: formatTime(item.checkOut),
                    icon: Icons.logout_rounded,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _smallTimeCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.history_rounded, size: 42, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            'Belum ada riwayat absensi',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildSeeAllButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: openHistory,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Lihat Semua Riwayat',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        if (index == 1) {
          openHistory();
        } else if (index == 2) {
          openAttendance();
        } else if (index == 3) {
          openProfile();
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history_rounded),
          label: 'Riwayat',
        ),
        NavigationDestination(
          icon: Icon(Icons.fingerprint_outlined),
          selectedIcon: Icon(Icons.fingerprint_rounded),
          label: 'Absensi',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}
