import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shared/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/color_palette.dart';
import '../../../../core/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _zenMode = false;
  bool _notifications = true;
  bool _cloudSync = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          24, 60, 24, 100), // Top padding for status bar, bottom for nav bar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Profile Header
          _buildProfileHeader(),

          const SizedBox(height: 32),

          // 2. Stats Grid
          _buildStatsGrid(),

          const SizedBox(height: 32),

          // 3. Badges / Achievements
          _buildBadgesSection(),

          const SizedBox(height: 32),

          // 4. Settings
          _buildSettingsSection(),

          const SizedBox(height: 20),
          
          // Sign Out Button
          _buildSignOutButton(),

          const SizedBox(height: 20),

          Center(
              child: Text("v1.0.0 Ultra",
                  style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 12)))
        ],
      )
          .animate()
          .fade(duration: 600.ms)
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
    );
  }

  Widget _buildProfileHeader() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primary.withOpacity(0.2),
                child: user?.photoURL != null && user!.photoURL!.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.photoURL!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircularProgressIndicator(
                            color: AppTheme.primary,
                            strokeWidth: 2,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white70,
                          ),
                        ),
                      )
                    : Icon(Icons.person, size: 50, color: Colors.white70),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? user?.email?.split('@')[0] ?? "User",
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppPalette.textPrimaryLight,
              ),
            ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
            if (user?.email != null)
              Text(
                user!.email!,
                style: TextStyle(
                  color: isDark ? Colors.white.withOpacity(0.7) : AppPalette.textSecondaryLight,
                  fontSize: 14,
                ),
              ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Expanded(
            child: _buildStatCard("Tasks Completed", "142",
                Icons.check_circle_outline, Colors.greenAccent)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard("Focus Hours", "48.5", Icons.timer_outlined,
                Colors.orangeAccent)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard("Current Streak", "12 Days",
                Icons.local_fire_department, Colors.redAccent)),
      ],
    ).animate().fade(delay: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppPalette.textPrimaryLight;
    final subtitleColor = isDark ? Colors.white54 : AppPalette.textSecondaryLight;
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppPalette.textPrimaryLight;
    final subtitleColor = isDark ? Colors.white70 : AppPalette.textSecondaryLight;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Achievements",
          style: TextStyle(
              color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildBadge("Early Bird", Icons.wb_sunny, Colors.amber),
              _buildBadge("Night Owl", Icons.nights_stay, Colors.indigoAccent),
              _buildBadge("Task Master", Icons.list_alt, Colors.purpleAccent),
              _buildBadge("Brainiac", Icons.psychology, Colors.tealAccent),
            ],
          ),
        ),
      ],
    ).animate().fade(delay: 500.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildBadge(String label, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : AppPalette.textSecondaryLight;
    
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          GlassContainer(
            height: 60,
            width: 60,
            borderRadius: BorderRadius.circular(30),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);
    
    return GlassContainer(
      padding: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          _buildSwitchTile("Zen Mode", "Block distractions while studying",
              _zenMode, Icons.spa, (val) => setState(() => _zenMode = val)),
          const Divider(color: Colors.white10),
          _buildSwitchTile(
              "Notifications",
              "Get reminders for tasks",
              _notifications,
              Icons.notifications_active,
              (val) => setState(() => _notifications = val)),
          const Divider(color: Colors.white10),
          _buildSwitchTile("Cloud Sync", "Backup data to cloud", _cloudSync,
              Icons.cloud_upload, (val) => setState(() => _cloudSync = val)),
          const Divider(color: Colors.white10),
          _buildSwitchTile(
              "Dark Mode",
              "Toggle dark/light theme",
              themeMode == ThemeMode.dark,
              Icons.dark_mode,
              (val) {
                ref.read(themeProvider.notifier).toggleTheme();
              }),
        ],
      ),
    ).animate().fade(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value,
      IconData icon, Function(bool) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppPalette.textPrimaryLight;
    final subtitleColor = isDark ? Colors.white38 : AppPalette.textSecondaryLight;
    
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.primary,
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: textColor, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(color: subtitleColor, fontSize: 12)),
    );
  }
  
  Widget _buildSignOutButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.logout, color: AppTheme.error, size: 20),
        ),
        title: Text(
          'Sign Out',
          style: TextStyle(
            color: AppTheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Log out of your account',
          style: TextStyle(
            color: isDark ? Colors.white38 : AppPalette.textSecondaryLight,
            fontSize: 12,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.error, size: 16),
        onTap: () async {
          final authService = AuthService();
          await authService.signOut();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        },
      ),
    ).animate().fade(delay: 700.ms).slideY(begin: 0.2, end: 0);
  }
}
