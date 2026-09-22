import 'package:flutter/material.dart';

import '../models/catatan_model.dart';
import '../services/database_helper.dart';
import 'catatan_screen.dart';
import 'edit_catatan_screen.dart';

class DaftarCatatanScreen extends StatefulWidget {
  const DaftarCatatanScreen({super.key});

  @override
  State<DaftarCatatanScreen> createState() => _DaftarCatatanScreenState();
}

class _DaftarCatatanScreenState extends State<DaftarCatatanScreen> {
  late Future<List<CatatanModel>> daftarCatatan;

  @override
  void initState() {
    super.initState();
    ambilCatatan();
  }

  void ambilCatatan() {
    daftarCatatan = DatabaseHelper().semuaCatatan();
  }

  Future<void> hapusCatatan(int id) async {
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Catatan'),
          content: const Text('Apakah kamu yakin ingin menghapus catatan ini?'),
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
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true) return;

    await DatabaseHelper().hapusCatatan(id);

    if (!mounted) return;

    setState(() {
      ambilCatatan();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan berhasil dihapus'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> refreshCatatan() async {
    setState(() {
      ambilCatatan();
    });
  }

  String formatTanggal(String tanggal) {
    final DateTime waktu = DateTime.parse(tanggal);

    return '${waktu.day}-${waktu.month}-${waktu.year} '
        '${waktu.hour}:${waktu.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Catatan'), centerTitle: true),
      body: FutureBuilder<List<CatatanModel>>(
        future: daftarCatatan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi error: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final List<CatatanModel> catatan = snapshot.data ?? [];

          if (catatan.isEmpty) {
            return const Center(
              child: Text('Belum ada catatan', style: TextStyle(fontSize: 18)),
            );
          }

          return RefreshIndicator(
            onRefresh: refreshCatatan,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: catatan.length,
              itemBuilder: (context, index) {
                final CatatanModel item = catatan[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(child: Icon(Icons.note)),
                    title: Text(
                      item.judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final bool? hasil = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditCatatanScreen(catatan: item),
                              ),
                            );

                            if (hasil == true) {
                              setState(() {
                                ambilCatatan();
                              });
                            }
                          },
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            if (item.id != null) {
                              hapusCatatan(item.id!);
                            }
                          },
                        ),
                      ],
                    ),

                    // trailing: IconButton(
                    //   icon: const Icon(Icons.delete, color: Colors.red),
                    //   onPressed: () {
                    //     if (item.id != null) {
                    //       hapusCatatan(item.id!);
                    //     }
                    //   },
                    // ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.isi),
                          const SizedBox(height: 8),
                          Text(
                            formatTanggal(item.tanggal),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bool? hasil = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const CatatanScreen()),
          );

          if (hasil == true) {
            setState(() {
              ambilCatatan();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
