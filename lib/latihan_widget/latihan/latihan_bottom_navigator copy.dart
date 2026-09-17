import 'package:flutter/material.dart';
import 'package:ogi_ppkd_app_dev/latihan_widget/latihan_avatar.dart';

class LatihanBottomNavigator extends StatefulWidget {
  const LatihanBottomNavigator({Key? key}) : super(key: key);

  @override
  _LatihanBottomNavigatorState createState() => _LatihanBottomNavigatorState();
}

class _LatihanBottomNavigatorState extends State<LatihanBottomNavigator> {
  // 1.Variabel untuk menyimpan indeks halaman yang aktif saat ini
  int _currentIndex = 0;

  // 2, DAftar Halaman Widget
  final List<Widget> _page = [
    const Center(
      child: Text('Halaman Beranda 1', style: TextStyle(fontSize: 24)),
    ),
    const Center(child: Text('Halaman Cari 2', style: TextStyle(fontSize: 24))),
    const Center(
      child: Text('Halaman Profil 3', style: TextStyle(fontSize: 24)),
    ),
  ];

  // 3. Funfsi untuk mengubah indeks ketika item navbar ditekan
  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Latihan Bottom Navigator'),
        backgroundColor: Colors.amber,
      ),
      body: _page[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, 
        onTap: _onTap, 
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ]
      ),
    );
  }
}
