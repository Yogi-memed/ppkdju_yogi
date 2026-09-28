import 'package:flutter/material.dart';

import 'catatan_screen.dart';
import 'daftar_catatan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.note_alt, size: 80, color: Colors.blue),

              const SizedBox(height: 20),

              const Text(
                'Selamat Datang',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                'Aplikasi Catatan Tugas 12 dan 13',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CatatanScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Catatan'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DaftarCatatanScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('Lihat Semua Catatan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';

// import 'catatan_screen.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Home Screen'), centerTitle: true),

//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Selamat Datang',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 10),

//             const Text(
//               'Aplikasi Catatan Tugas 12 dan 13',
//               textAlign: TextAlign.center,
//             ),

//             const SizedBox(height: 30),

//             ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const CatatanScreen(),
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.add),
//               label: const Text('Tambah Catatan'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Home Screen'), centerTitle: true),

//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Selamat Datang',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 10),

//             const Text(
//               'Aplikasi Catatan Tugas 12 dan 13',
//               textAlign: TextAlign.center,
//             ),

//             const SizedBox(height: 30),

//             ElevatedButton(
//               onPressed: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Tombol tambah ditekan')),
//                 );
//               },
//               child: const Text('Tambah Catatan'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
