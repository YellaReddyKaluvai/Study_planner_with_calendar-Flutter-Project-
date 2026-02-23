import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/widgets/glass_container.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart'; // Import theme provider
import '../../auth/presentation/auth_notifier.dart';
import 'profile_notifier.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ref.read(profileNotifierProvider.notifier).uploadImage(File(image.path));
    }
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title:
            Text('Edit Name', style: GoogleFonts.outfit(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: GoogleFonts.outfit(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter new name',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(profileNotifierProvider.notifier)
                    .updateDisplayName(controller.text);
                Navigator.pop(context);
              }
            },
            child:
                const Text('Save', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileStreamProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by main layout
      body: userAsync.when(
        data: (user) {
          final joinDate = user.createdAt != null
              ? DateFormat.yMMMd().format(user.createdAt!)
              : 'Unknown';
          final lastLogin = user.lastLoginAt != null
              ? DateFormat.jm().add_yMMMd().format(user.lastLoginAt!)
              : 'Never';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppTheme.primary, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                      color: AppTheme.primary.withOpacity(0.4),
                                      blurRadius: 20,
                                      spreadRadius: 5),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: user.photoUrl != null &&
                                        user.photoUrl!.isNotEmpty
                                    ? NetworkImage(user.photoUrl!)
                                    : null,
                                backgroundColor: Colors.white10,
                                child: user.photoUrl == null ||
                                        user.photoUrl!.isEmpty
                                    ? Text(
                                        user.displayName?[0].toUpperCase() ??
                                            'U',
                                        style: GoogleFonts.outfit(
                                            fontSize: 40, color: Colors.white),
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        )
                            .animate()
                            .scale(duration: 600.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.displayName ?? 'User',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.white54, size: 18),
                              onPressed: () => _showEditNameDialog(
                                  context, user.displayName ?? ''),
                            ),
                          ],
                        ),
                        Text(
                          user.email,
                          style: GoogleFonts.outfit(
                              fontSize: 14, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Account Stats'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                              child: _buildStatCard(
                                  'Joined', joinDate, Icons.calendar_today)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _buildStatCard(
                                  'Last Login', lastLogin, Icons.access_time)),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildSectionHeader('Settings'),
                      const SizedBox(height: 10),
                      GlassContainer(
                        // Using GlassKit-like container or custom
                        // height: 240, // Removed fixed height to prevent overflow
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderGradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.05)
                          ],
                        ),
                        blur: 15, // Glass effect
                        child: Column(
                          children: [
                            _buildSettingsTile(
                              icon: isDark ? Icons.dark_mode : Icons.light_mode,
                              title: 'Dark Mode',
                              subtitle: isDark ? 'On' : 'Off',
                              trailing: Switch(
                                value: isDark,
                                activeThumbColor: AppTheme.primary,
                                onChanged: (value) {
                                  ref
                                      .read(themeProvider.notifier)
                                      .toggleTheme();
                                },
                              ),
                            ),
                            const Divider(height: 1, color: Colors.white10),
                            _buildSettingsTile(
                              icon: Icons.notifications,
                              title: 'Notifications',
                              subtitle: 'Manage alerts',
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.white54),
                              onTap: () {},
                            ),
                            const Divider(height: 1, color: Colors.white10),
                            _buildSettingsTile(
                              icon: Icons.lock,
                              title: 'Privacy',
                              subtitle: 'Password & Security',
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.white54),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref.read(authNotifierProvider.notifier).signOut();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.2),
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            side: const BorderSide(color: Colors.redAccent),
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out'),
                        ),
                      ),
                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (error, stack) => Center(
            child: Text('Error loading profile: $error',
                style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title,
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12))
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
