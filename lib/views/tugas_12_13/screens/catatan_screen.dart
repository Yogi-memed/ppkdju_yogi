import 'package:flutter/material.dart';

import '../models/catatan_model.dart';
import '../services/database_helper.dart';

class CatatanScreen extends StatefulWidget {
  const CatatanScreen({super.key});

  @override
  State<CatatanScreen> createState() => _CatatanScreenState();
}

class _CatatanScreenState extends State<CatatanScreen> {
  final TextEditingController judulController = TextEditingController();
  final TextEditingController isiController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    judulController.dispose();
    isiController.dispose();
    super.dispose();
  }

  Future<void> simpanCatatan() async {
    final String judul = judulController.text.trim();
    final String isi = isiController.text.trim();

    // Validasi input
    if (judul.isEmpty || isi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan isi catatan wajib diisi')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Membuat data catatan
    final CatatanModel catatan = CatatanModel(
      judul: judul,
      isi: isi,
      tanggal: DateTime.now().toIso8601String(),
    );

    // Menyimpan data ke SQLite
    final int hasil = await DatabaseHelper().tambahCatatan(catatan);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (hasil != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke halaman sebelumnya
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan gagal disimpan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Catatan'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: judulController,
              decoration: const InputDecoration(
                labelText: 'Judul Catatan',
                hintText: 'Masukkan judul catatan',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: isiController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Isi Catatan',
                hintText: 'Masukkan isi catatan',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : simpanCatatan,
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
                label: Text(isLoading ? 'Menyimpan...' : 'Simpan Catatan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';

// class CatatanScreen extends StatefulWidget {
//   const CatatanScreen({super.key});

//   @override
//   State<CatatanScreen> createState() => _CatatanScreenState();
// }

// class _CatatanScreenState extends State<CatatanScreen> {
//   final judulController = TextEditingController();
//   final isiController = TextEditingController();

//   @override
//   void dispose() {
//     judulController.dispose();
//     isiController.dispose();

//     super.dispose();
//   }

//   void simpanCatatan() {
//     final judul = judulController.text.trim();
//     final isi = isiController.text.trim();

//     if (judul.isEmpty || isi.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Judul dan isi wajib diisi')),
//       );

//       return;
//     }

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Data catatan siap disimpan')));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Tambah Catatan')),

//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextFormField(
//               controller: judulController,
//               decoration: const InputDecoration(
//                 labelText: 'Judul',
//                 border: OutlineInputBorder(),
//               ),
//             ),

//             const SizedBox(height: 16),

//             TextFormField(
//               controller: isiController,
//               maxLines: 5,
//               decoration: const InputDecoration(
//                 labelText: 'Isi Catatan',
//                 border: OutlineInputBorder(),
//               ),
//             ),

//             const SizedBox(height: 20),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: simpanCatatan,
//                 child: const Text('SIMPAN'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// // import 'package:flutter/material.dart';
// // import 'package:ogi_ppkd_app_dev/db/services/db_helper.dart';
// // import 'package:ogi_ppkd_app_dev/db/models/user_models_sql.dart';
// // import 'package:ogi_ppkd_app_dev/navigator/navigator.dart';
// // import 'package:ogi_ppkd_app_dev/db/services/preferencens_handler.dart';
// // import 'package:ogi_ppkd_app_dev/views/tugas_12_13/screens/home_screen.dart';

// // class LoginScreenDay15 extends StatefulWidget {
// //   const LoginScreenDay15({super.key});

// //   @override
// //   State<LoginScreenDay15> createState() => _LoginScreenDay15State();
// // }

// // class _LoginScreenDay15State extends State<LoginScreenDay15> {
// //   //final _formKey = GlobalKey<FormState>();
// //   //final emailController = TextEditingController();
// //   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
// //   final userController = TextEditingController();
// //   final passController = TextEditingController();

// //   void login() async {
// //     final user = userController.text.trim();
// //     final pass = passController.text;

// //     if (user.isEmpty || pass.isEmpty) {
// //       ScaffoldMessenger.of(context)
// //           .showSnackBar(const SnackBar(content: Text('Isi semua field!')));
// //       return;
// //     }

// //     final pengguna = await DBHelper().loginUser(user, pass);

// //     if (!mounted) return; // Menghindari linter warning penggunaan BuildContext

// //     if (pengguna != null) {
// //       Navigator.of(context).pushAndRemoveUntil(
// //         MaterialPageRoute(builder: (_) => const HomeScreen()),
// //         (route) => false,
// //       );
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('Login gagal! email atau Password salah.'),
// //         ),
// //       );
// //     }
// //   }

// //   void register() async {
// //     final user = userController.text.trim();
// //     final pass = passController.text;

// //     if (user.isEmpty || pass.isEmpty) {
// //       ScaffoldMessenger.of(context)
// //           .showSnackBar(const SnackBar(content: Text('Isi semua field!')));
// //       return;
// //     }

// //     final pengguna = UserModelSQL(email: user, password: pass);

// //     bool success = await DBHelper().registerUser(pengguna);

// //     if (!mounted) return; // Menghindari linter warning: 'Don't use BuildContext across async gaps'

// //     if (success) {
// //       ScaffoldMessenger.of(context)
// //           .showSnackBar(const SnackBar(content: Text('Akun berhasil dibuat')));
// //     } else {
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(const SnackBar(content: Text('Email sudah terdaftar!')));
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: SafeArea(
// //         child: Form(
// //           key: _formKey,
// //           child: Padding(
// //             padding: const EdgeInsets.all(24),
// //             child: Center(
// //               child: SingleChildScrollView(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     // =========================
// //                     // ICON
// //                     // =========================
// //                     const Icon(Icons.lock, size: 80, color: Colors.blue),

// //                     const SizedBox(height: 24),

// //                     // =========================
// //                     // TITLE
// //                     // =========================
// //                     const Text(
// //                       'Login',
// //                       style: TextStyle(
// //                         fontSize: 32,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),

// //                     const SizedBox(height: 8),

// //                     // =========================
// //                     // SUBTITLE
// //                     // =========================
// //                     const Text(
// //                       'Silakan masuk ke akun Anda',
// //                       style: TextStyle(fontSize: 16, color: Colors.grey),
// //                     ),

// //                     const SizedBox(height: 32),

// //                     // =========================
// //                     // EMAIL
// //                     // =========================
// //                     TextFormField(
// //                       controller: userController,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'Email wajib diisi';
// //                         } else if (!value.contains('@')) {
// //                           return 'Format email tidak valid';
// //                         }
// //                         return null;
// //                       },
// //                       decoration: InputDecoration(
// //                         labelText: 'Email',
// //                         hintText: 'Masukkan email',
// //                         prefixIcon: const Icon(Icons.email),
// //                         border: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                       ),
// //                     ),

// //                     const SizedBox(height: 16),

// //                     // =========================
// //                     // PASSWORD
// //                     // =========================
// //                     TextFormField(
// //                       controller: passController,
// //                       obscureText: true,
// //                       decoration: InputDecoration(
// //                         labelText: 'Password',
// //                         hintText: 'Masukkan password',
// //                         prefixIcon: const Icon(Icons.lock),
// //                         border: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                       ),
// //                     ),

// //                     const SizedBox(height: 24),

// //                     ElevatedButton(
// //                       onPressed: () {
// //                         if (_formKey.currentState!.validate()) {
// //                           login();
// //                         }
// //                       },
// //                       child: Text('LOGIN'),
// //                     ),

// //                     ElevatedButton(
// //                       onPressed: () {
// //                         if (_formKey.currentState!.validate()) {
// //                           register();
// //                         }
// //                       },
// //                       child: Text('REGISTER'),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class HalamanTerimaKasih extends StatelessWidget {
// //   final String email;
// //   const HalamanTerimaKasih({super.key, required this.email});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Konfirmasi')),
// //       body: Column(
// //         children: [
// //           Center(
// //             child: Text(
// //               'Terima kasih, $email',
// //               style: TextStyle(fontSize: 18),
// //               textAlign: TextAlign.center,
// //             ), // Text
// //           ),
// //           SizedBox(
// //             width: double.infinity,
// //             child: ElevatedButton(
// //               onPressed: () {
// //                 PreferenceHandler.logOut();
// //                 context.pushAndRemoveAll(LoginScreenDay15());
// //               },
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.red,
// //                 // textStyle: TextStyle(color: Colors.white),
// //               ),
// //               child: Text("Logout"),
// //             ),
// //           ),
// //         ],
// //       ), // Center
// //     ); // Scaffold
// //   }
// // }
