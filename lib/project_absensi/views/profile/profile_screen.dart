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

      if (token == null || token.isEmpty) {
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

    if (token == null || token.isEmpty) {
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Perbarui informasi profile kamu.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(bottomSheetContext);

                      await updateProfile();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Simpan Perubahan',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text('Apakah kamu yakin ingin keluar dari akun?'),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: getUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            children: [
              _buildProfileHeader(),

              const SizedBox(height: 22),

              _buildInfoCard(),

              const SizedBox(height: 16),

              _buildSettingsCard(),

              const SizedBox(height: 16),

              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/image/a.jpg',
                width: 104,
                height: 104,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            email,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, size: 15, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Profile Pengguna',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Profile',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 16),

          _buildInfoItem(
            icon: Icons.person_rounded,
            title: 'Nama',
            value: name,
          ),

          const SizedBox(height: 12),

          _buildInfoItem(
            icon: Icons.email_rounded,
            title: 'Email',
            value: email,
          ),

          const SizedBox(height: 17),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: openEditProfile,
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text(
                'Edit Profile',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: ThemeController.isDarkMode,
        builder: (context, isDarkMode, child) {
          return SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            secondary: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: Colors.indigo,
              ),
            ),
            title: const Text(
              'Dark Mode',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              isDarkMode ? 'Mode gelap aktif' : 'Mode terang aktif',
            ),
            value: isDarkMode,
            onChanged: changeTheme,
          );
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: logout,
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        label: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.30)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
