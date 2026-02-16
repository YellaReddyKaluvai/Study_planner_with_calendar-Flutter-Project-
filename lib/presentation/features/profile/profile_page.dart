import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/glass_container.dart';
import '../../../../core/theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _zenMode = false;
  bool _notifications = true;
  bool _cloudSync = false;

  @override
  Widget build(BuildContext context) {
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

          Center(
              child: Text("v1.0.0 Ultra",
                  style: TextStyle(color: Colors.white24, fontSize: 12)))
        ],
      )
          .animate()
          .fade(duration: 600.ms)
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
    );
  }

  Widget _buildProfileHeader() {
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
          child: const CircleAvatar(
            radius: 50,
            backgroundImage:
                NetworkImage("https://i.pravatar.cc/300?img=12"), // Placeholder
            backgroundColor: Colors.transparent,
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        Text(
          "Alex Carter",
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
        Text(
          "Computer Science • Year 2",
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildStatsGrid() {
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
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Achievements",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
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
        ],
      ),
    ).animate().fade(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value,
      IconData icon, Function(bool) onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primary,
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: Colors.white38, fontSize: 12)),
    );
  }
}
