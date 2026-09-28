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
  List<AttendanceModel> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getHistory();
  }

  Future<void> getHistory() async {
    try {
      final token = await StorageServices.getToken();

      if (token == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      final response = await ApiServices().getHistory(
        token: token,
        start: '2026-01-01',
        end: '2026-12-31',
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'];

        if (!mounted) return;

        setState(() {
          history = data.map((item) => AttendanceModel.fromJson(item)).toList();

          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengambil riwayat: $e')));
    }
  }

  Future<void> deleteAttendance(int id, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Absensi'),
          content: const Text('Yakin ingin menghapus data absensi ini?'),
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
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      final token = await StorageServices.getToken();

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token login tidak ditemukan')),
        );

        return;
      }

      final response = await ApiServices().deleteAttendance(
        token: token,
        id: id,
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          history.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data absensi berhasil dihapus')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menghapus absensi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absensi')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
          ? const Center(child: Text('Belum ada riwayat absensi'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.checkIn ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                deleteAttendance(item.id, index);
                              },
                              icon: const Icon(Icons.delete),
                              tooltip: 'Hapus',
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text('Status: ${item.status}'),

                        const SizedBox(height: 4),

                        Text('Check In: ${item.checkInAddress ?? '-'}'),

                        const SizedBox(height: 4),

                        Text('Check Out: ${item.checkOut ?? '-'}'),

                        const SizedBox(height: 4),

                        Text(
                          'Lokasi Check Out: '
                          '${item.checkOutAddress ?? '-'}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
