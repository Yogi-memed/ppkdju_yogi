import 'package:flutter/material.dart';

import '../../reusable/theme_controller.dart';
import '../../services/api_services.dart';
import '../../services/storage_services.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = 'Memuat...';
  String email = 'Memuat...';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> getUserData() async {
    try {
      final token = await StorageServices.getToken();

      if (token == null) {
        if (!mounted) return;

        setState(() {
          name = '-';
          email = '-';
        });

        return;
      }

      final response = await ApiServices().getProfile(token: token);

      if (response.statusCode == 200) {
        final user = response.data['data'];

        if (!mounted) return;

        setState(() {
          name = user['name'] ?? '-';
          email = user['email'] ?? '-';
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengambil profile: $e')));
    }
  }

  Future<void> updateProfile() async {
    final token = await StorageServices.getToken();

    if (token == null) {
      return;
    }

    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan email tidak boleh kosong')),
      );

      return;
    }

    try {
      final response = await ApiServices().updateProfile(
        token: token,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
      );

      if (response.statusCode == 200) {
        await StorageServices.saveUser(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
        );

        await getUserData();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal update profile: $e')));
    }
  }

  void openEditProfile() {
    nameController.text = name;
    emailController.text = email;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(bottomSheetContext);
                    await updateProfile();
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> logout() async {
    await StorageServices.removeToken();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> changeTheme(bool value) async {
    ThemeController.isDarkMode.value = value;
    await StorageServices.saveTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 55)),

            const SizedBox(height: 20),

            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nama',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Email',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: openEditProfile,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
              ),
            ),

            const SizedBox(height: 12),

            ValueListenableBuilder<bool>(
              valueListenable: ThemeController.isDarkMode,
              builder: (context, isDarkMode, child) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: Text(
                      isDarkMode ? 'Mode gelap aktif' : 'Mode terang aktif',
                    ),
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    ),
                    value: isDarkMode,
                    onChanged: changeTheme,
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
