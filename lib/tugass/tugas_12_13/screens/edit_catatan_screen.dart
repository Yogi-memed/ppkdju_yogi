import 'package:flutter/material.dart';

import '../models/catatan_model.dart';
import '../services/database_helper.dart';

class EditCatatanScreen extends StatefulWidget {
  final CatatanModel catatan;

  const EditCatatanScreen({super.key, required this.catatan});

  @override
  State<EditCatatanScreen> createState() => _EditCatatanScreenState();
}

class _EditCatatanScreenState extends State<EditCatatanScreen> {
  late TextEditingController judulController;
  late TextEditingController isiController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    judulController = TextEditingController(text: widget.catatan.judul);

    isiController = TextEditingController(text: widget.catatan.isi);
  }

  @override
  void dispose() {
    judulController.dispose();
    isiController.dispose();
    super.dispose();
  }

  Future<void> updateCatatan() async {
    final String judul = judulController.text.trim();
    final String isi = isiController.text.trim();

    if (judul.isEmpty || isi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan isi wajib diisi')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final CatatanModel catatanBaru = CatatanModel(
      id: widget.catatan.id,
      judul: judul,
      isi: isi,
      tanggal: widget.catatan.tanggal,
    );

    final int hasil = await DatabaseHelper().updateCatatan(catatanBaru);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (hasil > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan gagal diperbarui'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Catatan'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: judulController,
              decoration: const InputDecoration(
                labelText: 'Judul Catatan',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: isiController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Isi Catatan',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : updateCatatan,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(isLoading ? 'Menyimpan...' : 'Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
