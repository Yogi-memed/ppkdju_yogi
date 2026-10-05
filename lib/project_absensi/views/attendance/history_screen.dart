import 'package:flutter/material.dart';

import '../../models/attendance_model.dart';
import '../../services/api_services.dart';
import '../../services/storage_services.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiServices _apiServices = ApiServices();

  List<AttendanceModel> attendanceList = [];

  bool isLoading = true;
  int? deletingId;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() {
      isLoading = true;
    });

    try {
      final token = await StorageServices.getToken();

      if (token == null || token.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final year = DateTime.now().year;

      final response = await _apiServices.getHistory(
        token: token,
        start: '$year-01-01',
        end: '$year-12-31',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        List<dynamic> historyData = [];

        if (data is List) {
          historyData = data;
        } else if (data is Map<String, dynamic>) {
          if (data['data'] is List) {
            historyData = data['data'];
          } else if (data['data'] is Map && data['data']['data'] is List) {
            historyData = data['data']['data'];
          }
        }

        setState(() {
          attendanceList = historyData
              .map(
                (item) =>
                    AttendanceModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        _showMessage('Gagal mengambil riwayat. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      _showMessage('Gagal mengambil riwayat: $e');
    }
  }

  Future<void> deleteHistory(AttendanceModel attendance) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Hapus Riwayat?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Apakah kamu yakin ingin menghapus riwayat absensi ini?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      deletingId = attendance.id;
    });

    try {
      final token = await StorageServices.getToken();

      if (token == null || token.isEmpty) {
        _showMessage('Token tidak ditemukan');
        return;
      }

      final response = await _apiServices.deleteAttendance(
        token: token,
        id: attendance.id,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          attendanceList.removeWhere((item) => item.id == attendance.id);
        });

        _showMessage('Riwayat berhasil dihapus');
      } else {
        _showMessage('Gagal menghapus riwayat. Status: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Gagal menghapus riwayat: $e');
    } finally {
      if (mounted) {
        setState(() {
          deletingId = null;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF142020),
      ),
    );
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return '-';
    }

    try {
      final parsedDate = DateTime.parse(date);

      return '${parsedDate.day.toString().padLeft(2, '0')}/'
          '${parsedDate.month.toString().padLeft(2, '0')}/'
          '${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }

  Widget buildStatus(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'hadir':
        color = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
        break;

      case 'izin':
        color = Colors.orange;
        icon = Icons.info_rounded;
        break;

      case 'sakit':
        color = Colors.blueAccent;
        icon = Icons.medical_services_rounded;
        break;

      default:
        color = Colors.grey;
        icon = Icons.help_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 17, color: Colors.white54),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHistoryCard(AttendanceModel attendance) {
    final bool isDeleting = deletingId == attendance.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF10B981),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(attendance.checkIn),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    buildStatus(attendance.status ?? 'Unknown'),
                  ],
                ),
              ),

              IconButton(
                tooltip: 'Hapus',
                onPressed: isDeleting ? null : () => deleteHistory(attendance),
                icon: isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.redAccent,
                        ),
                      )
                    : const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF142020),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                buildInfoRow(
                  Icons.login_rounded,
                  'Check In',
                  attendance.checkIn ?? '-',
                ),
                const SizedBox(height: 10),
                buildInfoRow(
                  Icons.logout_rounded,
                  'Check Out',
                  attendance.checkOut ?? '-',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummary() {
    int hadir = 0;
    int izin = 0;
    int pulang = 0;

    for (final item in attendanceList) {
      final status = (item.status ?? '').toLowerCase();

      if (status == 'hadir') {
        hadir++;
      }

      if (status == 'izin') {
        izin++;
      }

      if (item.checkOut != null && item.checkOut!.isNotEmpty) {
        pulang++;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryItem(
              Icons.check_circle_rounded,
              hadir.toString(),
              'Hadir',
              const Color(0xFF10B981),
            ),
          ),
          Container(
            width: 1,
            height: 45,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          Expanded(
            child: _summaryItem(
              Icons.logout_rounded,
              pulang.toString(),
              'Pulang',
              Colors.blueAccent,
            ),
          ),
          Container(
            width: 1,
            height: 45,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          Expanded(
            child: _summaryItem(
              Icons.info_rounded,
              izin.toString(),
              'Izin',
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(IconData icon, String value, String title, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071010),

      appBar: AppBar(
        backgroundColor: const Color(0xFF071010),
        elevation: 0,
        centerTitle: false,

        // TOMBOL BACK
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Riwayat Absensi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading ? null : loadHistory,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),

      body: RefreshIndicator(
        color: const Color(0xFF10B981),
        backgroundColor: const Color(0xFF101A1A),
        onRefresh: loadHistory,

        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF10B981)),
              )
            : attendanceList.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),
                  Icon(Icons.history_rounded, color: Colors.white24, size: 70),
                  SizedBox(height: 15),
                  Center(
                    child: Text(
                      'Belum ada riwayat absensi',
                      style: TextStyle(color: Colors.white54, fontSize: 15),
                    ),
                  ),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                children: [
                  buildSummary(),
                  ...attendanceList.map(
                    (attendance) => buildHistoryCard(attendance),
                  ),
                ],
              ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';

// import '../../models/attendance_model.dart';
// import '../../services/api_services.dart';
// import '../../services/storage_services.dart';

// class HistoryScreen extends StatefulWidget {
//   const HistoryScreen({super.key});

//   @override
//   State<HistoryScreen> createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends State<HistoryScreen> {
//   static const Color bgColor = Color(0xFF071010);
//   static const Color cardColor = Color(0xFF101A1A);
//   static const Color accentColor = Color(0xFF10B981);
//   static const Color accentLight = Color(0xFF34D399);

//   List<AttendanceModel> history = [];
//   bool isLoading = true;
//   int? deletingId;

//   @override
//   void initState() {
//     super.initState();
//     getHistory();
//   }

//   Future<void> getHistory() async {
//     try {
//       final token = await StorageServices.getToken();

//       if (token == null) {
//         if (!mounted) return;

//         setState(() {
//           isLoading = false;
//         });

//         return;
//       }

//       final response = await ApiServices().getHistory(
//         token: token,
//         start: '2026-01-01',
//         end: '2026-12-31',
//       );

//       if (response.statusCode == 200) {
//         final List data = response.data['data'];

//         if (!mounted) return;

//         setState(() {
//           history = data.map((item) => AttendanceModel.fromJson(item)).toList();
//           isLoading = false;
//         });
//       } else {
//         if (!mounted) return;

//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         isLoading = false;
//       });

//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Gagal mengambil riwayat: $e')));
//     }
//   }

//   Future<void> deleteHistory(AttendanceModel item) async {
//     final token = await StorageServices.getToken();

//     if (token == null) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Token tidak ditemukan. Silakan login kembali.'),
//         ),
//       );

//       return;
//     }

//     setState(() {
//       deletingId = item.id;
//     });

//     try {
//       final response = await ApiServices().deleteAttendance(
//         token: token,
//         id: item.id,
//       );

//       if (!mounted) return;

//       if (response.statusCode == 200 || response.statusCode == 204) {
//         setState(() {
//           history.removeWhere((attendance) => attendance.id == item.id);
//           deletingId = null;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Riwayat absensi berhasil dihapus.')),
//         );
//       } else {
//         setState(() {
//           deletingId = null;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Gagal menghapus riwayat. Status: ${response.statusCode}',
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         deletingId = null;
//       });

//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Gagal menghapus riwayat: $e')));
//     }
//   }

//   String formatDate(String? value) {
//     if (value == null || value.isEmpty) {
//       return '-';
//     }

//     try {
//       final dateTime = DateTime.parse(value);

//       const months = [
//         'JAN',
//         'FEB',
//         'MAR',
//         'APR',
//         'MEI',
//         'JUN',
//         'JUL',
//         'AGU',
//         'SEP',
//         'OKT',
//         'NOV',
//         'DES',
//       ];

//       return '${dateTime.day.toString().padLeft(2, '0')} '
//           '${months[dateTime.month - 1]} '
//           '${dateTime.year}';
//     } catch (_) {
//       return value;
//     }
//   }

//   String formatTime(String? value) {
//     if (value == null || value.isEmpty) {
//       return '-';
//     }

//     try {
//       final dateTime = DateTime.parse(value);

//       return '${dateTime.hour.toString().padLeft(2, '0')}:'
//           '${dateTime.minute.toString().padLeft(2, '0')}:'
//           '${dateTime.second.toString().padLeft(2, '0')}';
//     } catch (_) {
//       return value;
//     }
//   }

//   bool isPermission(String status) {
//     return status.toLowerCase() == 'izin';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: AppBar(
//         backgroundColor: bgColor,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(
//             Icons.arrow_back_ios_new_rounded,
//             color: Colors.white,
//             size: 19,
//           ),
//         ),
//         title: const Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Riwayat Absensi',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//             SizedBox(height: 2),
//             Text(
//               'Aktivitas absensi kamu',
//               style: TextStyle(
//                 color: Colors.white38,
//                 fontSize: 10,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             onPressed: getHistory,
//             icon: const Icon(Icons.refresh_rounded, color: accentLight),
//           ),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: accentColor))
//           : history.isEmpty
//           ? _buildEmptyState()
//           : RefreshIndicator(
//               color: accentColor,
//               backgroundColor: cardColor,
//               onRefresh: getHistory,
//               child: ListView.builder(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
//                 itemCount: history.length,
//                 itemBuilder: (context, index) {
//                   return _buildHistoryCard(history[index]);
//                 },
//               ),
//             ),
//     );
//   }

//   Widget _buildHistoryCard(AttendanceModel item) {
//     final izin = isPermission(item.status);
//     final statusColor = izin ? Colors.orange : accentLight;

//     final isDeleting = deletingId == item.id;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 15),
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: accentColor.withValues(alpha: 0.10),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Icon(
//                   izin ? Icons.sick_rounded : Icons.calendar_month_rounded,
//                   color: accentLight,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       formatDate(item.checkIn ?? item.createdAt),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     Text(
//                       formatTime(item.checkIn ?? item.createdAt),
//                       style: const TextStyle(
//                         color: Colors.white38,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               _statusBadge(item.status, statusColor),
//               const SizedBox(width: 3),
//               IconButton(
//                 onPressed: isDeleting
//                     ? null
//                     : () {
//                         _showDeleteDialog(item);
//                       },
//                 icon: isDeleting
//                     ? const SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.redAccent,
//                         ),
//                       )
//                     : const Icon(
//                         Icons.delete_outline_rounded,
//                         color: Colors.white38,
//                         size: 20,
//                       ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           _buildTimeline(
//             icon: Icons.login_rounded,
//             color: accentLight,
//             title: 'Check In',
//             time: formatTime(item.checkIn),
//             location: item.checkInAddress ?? item.checkInLocation ?? '-',
//             isLast: item.checkOut == null || item.checkOut!.isEmpty,
//           ),
//           if (item.checkOut != null && item.checkOut!.isNotEmpty)
//             _buildTimeline(
//               icon: Icons.logout_rounded,
//               color: Colors.orangeAccent,
//               title: 'Check Out',
//               time: formatTime(item.checkOut),
//               location: item.checkOutAddress ?? item.checkOutLocation ?? '-',
//               isLast: true,
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimeline({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String time,
//     required String location,
//     required bool isLast,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: 38,
//           child: Column(
//             children: [
//               Container(
//                 width: 34,
//                 height: 34,
//                 decoration: BoxDecoration(
//                   color: color.withValues(alpha: 0.10),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(icon, color: color, size: 17),
//               ),
//               if (!isLast)
//                 Container(
//                   width: 2,
//                   height: 55,
//                   margin: const EdgeInsets.symmetric(vertical: 4),
//                   color: Colors.white.withValues(alpha: 0.08),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withValues(alpha: 0.05),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         time,
//                         style: const TextStyle(
//                           color: Colors.white54,
//                           fontSize: 9,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 7),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Icon(
//                       Icons.location_on_outlined,
//                       color: Colors.white30,
//                       size: 14,
//                     ),
//                     const SizedBox(width: 5),
//                     Expanded(
//                       child: Text(
//                         location,
//                         style: const TextStyle(
//                           color: Colors.white38,
//                           fontSize: 10,
//                           height: 1.45,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _statusBadge(String status, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.10),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Text(
//         status.toUpperCase(),
//         style: TextStyle(
//           color: color,
//           fontSize: 9,
//           fontWeight: FontWeight.w900,
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 90,
//               height: 90,
//               decoration: BoxDecoration(
//                 color: accentColor.withValues(alpha: 0.08),
//                 borderRadius: BorderRadius.circular(28),
//               ),
//               child: const Icon(
//                 Icons.history_rounded,
//                 color: accentLight,
//                 size: 42,
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Belum Ada Riwayat',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 19,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Riwayat absensi kamu akan muncul di sini.',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.white38, fontSize: 12),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _showDeleteDialog(AttendanceModel item) async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: cardColor,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(22),
//           ),
//           title: const Text(
//             'Hapus Riwayat?',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
//           ),
//           content: const Text(
//             'Apakah kamu yakin ingin menghapus '
//             'riwayat absensi ini?',
//             style: TextStyle(color: Colors.white54),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context, false);
//               },
//               child: const Text(
//                 'Batal',
//                 style: TextStyle(color: Colors.white54),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context, true);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Hapus'),
//             ),
//           ],
//         );
//       },
//     );

//     if (result == true) {
//       await deleteHistory(item);
//     }
//   }
// }
// import 'package:flutter/material.dart';

// import '../../models/attendance_model.dart';
// import '../../services/api_services.dart';
// import '../../services/storage_services.dart';

// class HistoryScreen extends StatefulWidget {
//   const HistoryScreen({super.key});

//   @override
//   State<HistoryScreen> createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends State<HistoryScreen> {
//   List<AttendanceModel> history = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     getHistory();
//   }

//   Future<void> getHistory() async {
//     try {
//       final token = await StorageServices.getToken();

//       if (token == null) {
//         if (!mounted) return;

//         setState(() {
//           isLoading = false;
//         });

//         return;
//       }

//       final response = await ApiServices().getHistory(
//         token: token,
//         start: '2026-01-01',
//         end: '2026-12-31',
//       );

//       if (response.statusCode == 200) {
//         final List data = response.data['data'];

//         if (!mounted) return;

//         setState(() {
//           history = data.map((item) => AttendanceModel.fromJson(item)).toList();

//           isLoading = false;
//         });
//       } else {
//         if (!mounted) return;

//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         isLoading = false;
//       });

//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Gagal mengambil riwayat: $e')));
//     }
//   }

//   String formatDate(String? value) {
//     if (value == null || value.isEmpty) {
//       return '-';
//     }

//     try {
//       final dateTime = DateTime.parse(value);

//       const months = [
//         'JAN',
//         'FEB',
//         'MAR',
//         'APR',
//         'MEI',
//         'JUN',
//         'JUL',
//         'AGU',
//         'SEP',
//         'OKT',
//         'NOV',
//         'DES',
//       ];

//       return '${dateTime.day.toString().padLeft(2, '0')} '
//           '${months[dateTime.month - 1]} '
//           '${dateTime.year}';
//     } catch (e) {
//       return value;
//     }
//   }

//   String formatTime(String? value) {
//     if (value == null || value.isEmpty) {
//       return '-';
//     }

//     try {
//       final dateTime = DateTime.parse(value);

//       return '${dateTime.hour.toString().padLeft(2, '0')}:'
//           '${dateTime.minute.toString().padLeft(2, '0')}:'
//           '${dateTime.second.toString().padLeft(2, '0')}';
//     } catch (e) {
//       return value;
//     }
//   }

//   bool isPermission(String status) {
//     return status.toLowerCase() == 'izin';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F7FB),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFF6F7FB),
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
//         ),
//         title: const Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Riwayat Absensi',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
//             ),
//             SizedBox(height: 2),
//             Text(
//               'Aktivitas absensi kamu',
//               style: TextStyle(
//                 fontSize: 11,
//                 color: Colors.grey,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: Color(0xFF2563EB)),
//             )
//           : history.isEmpty
//           ? _buildEmptyState()
//           : RefreshIndicator(
//               color: const Color(0xFF2563EB),
//               onRefresh: getHistory,
//               child: ListView.builder(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
//                 itemCount: history.length,
//                 itemBuilder: (context, index) {
//                   return _buildHistoryCard(history[index]);
//                 },
//               ),
//             ),
//     );
//   }

//   Widget _buildHistoryCard(AttendanceModel item) {
//     final bool izin = isPermission(item.status);

//     final Color statusColor = izin
//         ? const Color(0xFFF59E0B)
//         : const Color(0xFF16A34A);

//     final Color statusBackground = izin
//         ? const Color(0xFFFFF7E6)
//         : const Color(0xFFECFDF3);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 18,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(18),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // HEADER
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: 52,
//                   height: 52,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFEFF4FF),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: const Icon(
//                     Icons.calendar_month_rounded,
//                     color: Color(0xFF2563EB),
//                     size: 25,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         formatDate(item.checkIn ?? item.createdAt),
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w900,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         formatTime(item.checkIn ?? item.createdAt),
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey.shade600,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // STATUS
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 11,
//                     vertical: 7,
//                   ),
//                   decoration: BoxDecoration(
//                     color: statusBackground,
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         izin ? Icons.info_rounded : Icons.check_circle_rounded,
//                         size: 14,
//                         color: statusColor,
//                       ),
//                       const SizedBox(width: 5),
//                       Text(
//                         item.status.toUpperCase(),
//                         style: TextStyle(
//                           color: statusColor,
//                           fontSize: 10,
//                           fontWeight: FontWeight.w900,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(width: 4),

//                 // DELETE
//                 IconButton(
//                   onPressed: () {
//                     _showDeleteDialog(item);
//                   },
//                   tooltip: 'Hapus',
//                   icon: Icon(
//                     Icons.delete_outline_rounded,
//                     color: Colors.grey.shade700,
//                     size: 21,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // CHECK IN
//             _buildAttendanceTimeline(
//               icon: Icons.login_rounded,
//               iconColor: const Color(0xFF2563EB),
//               title: 'Check In',
//               time: formatTime(item.checkIn),
//               location: item.checkInAddress ?? item.checkInLocation ?? '-',
//               isLast: item.checkOut == null || item.checkOut!.isEmpty,
//             ),

//             // CHECK OUT
//             if (item.checkOut != null && item.checkOut!.isNotEmpty)
//               _buildAttendanceTimeline(
//                 icon: Icons.logout_rounded,
//                 iconColor: const Color(0xFFEF4444),
//                 title: 'Check Out',
//                 time: formatTime(item.checkOut),
//                 location: item.checkOutAddress ?? item.checkOutLocation ?? '-',
//                 isLast: true,
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAttendanceTimeline({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required String time,
//     required String location,
//     required bool isLast,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: 38,
//           child: Column(
//             children: [
//               Container(
//                 width: 34,
//                 height: 34,
//                 decoration: BoxDecoration(
//                   color: iconColor.withValues(alpha: 0.10),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(icon, color: iconColor, size: 17),
//               ),
//               if (!isLast)
//                 Container(
//                   width: 2,
//                   height: 58,
//                   margin: const EdgeInsets.symmetric(vertical: 4),
//                   color: Colors.grey.withValues(alpha: 0.20),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.only(top: 1, bottom: 12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 3,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.withValues(alpha: 0.08),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         time,
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.grey.shade700,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 7),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Icon(
//                       Icons.location_on_outlined,
//                       size: 15,
//                       color: Colors.grey.shade500,
//                     ),
//                     const SizedBox(width: 5),
//                     Expanded(
//                       child: Text(
//                         location,
//                         style: TextStyle(
//                           fontSize: 11,
//                           height: 1.45,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 90,
//               height: 90,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFEFF4FF),
//                 borderRadius: BorderRadius.circular(28),
//               ),
//               child: const Icon(
//                 Icons.history_rounded,
//                 size: 42,
//                 color: Color(0xFF2563EB),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Belum Ada Riwayat',
//               style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Riwayat absensi kamu akan muncul di sini.',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _showDeleteDialog(AttendanceModel item) async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: const Text(
//             'Hapus Riwayat?',
//             style: TextStyle(fontWeight: FontWeight.w800),
//           ),
//           content: const Text(
//             'Apakah kamu yakin ingin menghapus '
//             'riwayat absensi ini?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext, false);
//               },
//               child: const Text('Batal'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext, true);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Hapus'),
//             ),
//           ],
//         );
//       },
//     );

//     if (result != true) {
//       return;
//     }

//     try {
//       final token = await StorageServices.getToken();

//       if (token == null || token.isEmpty) {
//         if (!mounted) return;

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Token login tidak ditemukan')),
//         );

//         return;
//       }

//       final response = await ApiServices().deleteAttendance(
//         token: token,
//         id: item.id,
//       );

//       if (response.statusCode == 200) {
//         if (!mounted) return;

//         setState(() {
//           history.removeWhere((attendance) => attendance.id == item.id);
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Data absensi berhasil dihapus')),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Gagal menghapus absensi: $e')));
//     }
//   }
// }
// //   Future<void> _showDeleteDialog(AttendanceModel item) async {
// //     final result = await showDialog<bool>(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(20),
// //           ),
// //           title: const Text(
// //             'Hapus Riwayat?',
// //             style: TextStyle(fontWeight: FontWeight.w800),
// //           ),
// //           content: const Text(
// //             'Apakah kamu yakin ingin menghapus '
// //             'riwayat absensi ini?',
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.pop(context, false);
// //               },
// //               child: const Text('Batal'),
// //             ),
// //             ElevatedButton(
// //               onPressed: () {
// //                 Navigator.pop(context, true);
// //               },
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.redAccent,
// //                 foregroundColor: Colors.white,
// //               ),
// //               child: const Text('Hapus'),
// //             ),
// //           ],
// //         );
// //       },
// //     );

// //     if (result == true) {
// //       // Untuk sementara tombol tetap mempertahankan
// //       // UI hapus yang sudah ada.
// //       //
// //       // Endpoint DELETE attendance belum kita ubah
// //       // di sini supaya tidak mengganggu API history
// //       // yang sekarang sudah berhasil.
// //       if (!mounted) return;

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('Fitur hapus siap dihubungkan ke API DELETE.'),
// //         ),
// //       );
// //     }
// //   }
// // }
// // import 'package:flutter/material.dart';

// // import '../../models/attendance_model.dart';
// // import '../../services/api_services.dart';
// // import '../../services/storage_services.dart';

// // class HistoryScreen extends StatefulWidget {
// //   const HistoryScreen({super.key});

// //   @override
// //   State<HistoryScreen> createState() => _HistoryScreenState();
// // }

// // class _HistoryScreenState extends State<HistoryScreen> {
// //   List<AttendanceModel> history = [];
// //   bool isLoading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     getHistory();
// //   }

// //   Future<void> getHistory() async {
// //     try {
// //       final token = await StorageServices.getToken();

// //       if (token == null) {
// //         if (!mounted) return;

// //         setState(() {
// //           isLoading = false;
// //         });

// //         return;
// //       }

// //       final response = await ApiServices().getHistory(
// //         token: token,
// //         start: '2026-01-01',
// //         end: '2026-12-31',
// //       );

// //       if (response.statusCode == 200) {
// //         final List data = response.data['data'];

// //         if (!mounted) return;

// //         setState(() {
// //           history = data.map((item) => AttendanceModel.fromJson(item)).toList();

// //           isLoading = false;
// //         });
// //       }
// //     } catch (e) {
// //       if (!mounted) return;

// //       setState(() {
// //         isLoading = false;
// //       });

// //       ScaffoldMessenger.of(context)
// //           .showSnackBar(SnackBar(content: Text('Gagal mengambil riwayat: $e')));
// //     }
// //   }

// //   Future<void> deleteAttendance(int id, int index) async {
// //     final confirm = await showDialog<bool>(
// //       context: context,
// //       builder: (dialogContext) {
// //         return AlertDialog(
// //           title: const Text('Hapus Absensi'),
// //           content: const Text('Yakin ingin menghapus data absensi ini?'),
// //           actions: [
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.pop(dialogContext, false);
// //               },
// //               child: const Text('Batal'),
// //             ),
// //             ElevatedButton(
// //               onPressed: () {
// //                 Navigator.pop(dialogContext, true);
// //               },
// //               child: const Text('Hapus'),
// //             ),
// //           ],
// //         );
// //       },
// //     );

// //     if (confirm != true) {
// //       return;
// //     }

// //     try {
// //       final token = await StorageServices.getToken();

// //       if (token == null || token.isEmpty) {
// //         if (!mounted) return;

// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Token login tidak ditemukan')),
// //         );

// //         return;
// //       }

// //       final response = await ApiServices().deleteAttendance(
// //         token: token,
// //         id: id,
// //       );

// //       if (response.statusCode == 200) {
// //         if (!mounted) return;

// //         setState(() {
// //           history.removeAt(index);
// //         });

// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Data absensi berhasil dihapus')),
// //         );
// //       }
// //     } catch (e) {
// //       if (!mounted) return;

// //       ScaffoldMessenger.of(context)
// //           .showSnackBar(SnackBar(content: Text('Gagal menghapus absensi: $e')));
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Riwayat Absensi')),
// //       body: isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : history.isEmpty
// //           ? const Center(child: Text('Belum ada riwayat absensi'))
// //           : ListView.builder(
// //               padding: const EdgeInsets.all(16),
// //               itemCount: history.length,
// //               itemBuilder: (context, index) {
// //                 final item = history[index];

// //                 return Card(
// //                   margin: const EdgeInsets.only(bottom: 12),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(16),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Expanded(
// //                               child: Text(
// //                                 item.checkIn ?? '-',
// //                                 style: const TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   fontSize: 16,
// //                                 ),
// //                               ),
// //                             ),
// //                             IconButton(
// //                               onPressed: () {
// //                                 deleteAttendance(item.id, index);
// //                               },
// //                               icon: const Icon(Icons.delete),
// //                               tooltip: 'Hapus',
// //                             ),
// //                           ],
// //                         ),

// //                         const SizedBox(height: 8),

// //                         Text('Status: ${item.status}'),

// //                         const SizedBox(height: 4),

// //                         Text('Check In: ${item.checkInAddress ?? '-'}'),

// //                         const SizedBox(height: 4),

// //                         Text('Check Out: ${item.checkOut ?? '-'}'),

// //                         const SizedBox(height: 4),

// //                         Text(
// //                           'Lokasi Check Out: '
// //                           '${item.checkOutAddress ?? '-'}',
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),
// //     );
// //   }
// // }
