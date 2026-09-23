import 'package:flutter/material.dart';
import 'package:ogi_ppkd_app_dev/day_19/models/post_models.dart';
import 'package:ogi_ppkd_app_dev/day_19/services/api_services.dart';
import 'package:ogi_ppkd_app_dev/day_19/services/dio_client.dart';

class postListScreenDay19 extends StatefulWidget {
  const postListScreenDay19({super.key});

  @override
  State<postListScreenDay19> createState() => _PostListScreenDay19State();
}

class _PostListScreenDay19State extends State<postListScreenDay19> {
  late final ApiService _apiService;
  late Future<List<PostModels>> _postsFuture;

  @override
  void initState() {
    super.initState();
    // Inisialisasi Dio client & ApiService Retrofit saat widget dipasang
    final dio = createDioClient();
    _apiService = ApiService(dio);
    // Memanggil API GET /posts
    _postsFuture = _apiService.getAllPosts();
  }

  // Method untuk memicu request ulang (refetch data)
  void _refreshPosts() {
    setState(() {
      _postsFuture = _apiService.getAllPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API', style: TextStyle(color: Colors.white)),
        // backgroundColor: AppColor.primaryColor,
        // iconTheme: const IconThemeData(color: Colors.white),
      ),
      // FutureBuilder menangani state asynchronous (Loading, Error, Data Result)
      body: FutureBuilder(
        future: _postsFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // State 1: Menunggu respon (Loading)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // State 2: Terjadi error saat request data
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat data:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ), // Text
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshPosts,
                      child: const Text('Coba Lagi'),
                    ), // ElevatedButton
                  ],
                ), // Column
              ), // Padding
            ); // Center
          }

          // State 3: Respon sukses tetapi data kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data post.'));
          }

          // State 4: Data berhasil dimuat
          final List<PostModels> posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ), // EdgeInsets.symmetric
                child: ListTile(
                  leading: CircleAvatar(
                    // backgroundColor: AppColor.primaryColor,
                    child: Text(
                      '${post.id}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  title: Text(
                    post.title ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(post.body ?? "", maxLines: 2),
                ),
              ); // Card
            },
          ); // ListView.builder
        },
      ),
    );
  }
}
