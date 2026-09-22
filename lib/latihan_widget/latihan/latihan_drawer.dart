import 'package:flutter/material.dart';
import 'package:ogi_ppkd_app_dev/latihan_widget/latihan_avatar.dart';
import 'package:ogi_ppkd_app_dev/latihan_widget/latihan_bottom_navigator.dart';
import 'package:ogi_ppkd_app_dev/tugas/tugas_5/tugas_5.dart';

class LatihanDrawer extends StatefulWidget {
  const LatihanDrawer({Key? key}) : super(key: key);

  @override
  _LatihanDrawerState createState() => _LatihanDrawerState();
}

class _LatihanDrawerState extends State<LatihanDrawer> {
  // Indeks halaman aktif saat ini
  int _selectedIndex = 0;

  // Daftar nama judul untuk AppBar
  final List<String> _titles = [
    'Halaman Circle Avatar',
    'Halaman Grid view',
    'Halaman Navigator',
  ];

  // Daftar widget halaman tujuan
  final List<Widget> _pages = [
    const LatihanAvatar(),
    const Tugas3Flutter(),
    const LatihanBottomNavigator(),
  ];

  // Fungsi untuk mengubah halaman aktif
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Budi Setiawan'),
              accountEmail: Text('budi.setiawan@email.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'B',
                  style: TextStyle(fontSize: 40.0, color: Colors.blue),
                ),
              ),
              decoration: BoxDecoration(color: Colors.blue),
            ),

            // Menu 1: Beranda
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Latihan Icon Avatar'),
              selected: _selectedIndex == 0, //Highlight jika menu ini aktif
              onTap: () {
                _onItemTapped(0); // pindah ke indeks 0
                Navigator.pop(context); // Menutup Drawer setelah diklik
              },
            ),
            // Menu 2: Pengaturan
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Latihan Grid View'),
              selected: _selectedIndex == 1, //Highlight jika menu ini aktif
              onTap: () {
                _onItemTapped(1); //Pindah ke indeks 1
                Navigator.pop(context); // Menutup Drawer setelah diklik
              },
            ),
            // Menu 3: Navigator
            ListTile(
              leading: const Icon(Icons.navigation),
              title: const Text('Latihan Bottom Navigator'),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
