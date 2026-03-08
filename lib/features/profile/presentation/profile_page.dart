import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/language_provider.dart';
import '../../../core/theme/app_strings.dart';
import '../../../core/widgets/platform_image.dart';
import '../../auth/presentation/auth_notifier.dart';

import 'profile_notifier.dart';
import '../../../services/notification_service.dart';
import '../../../core/services/cloud_backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final ImagePicker _picker = ImagePicker();

  // Notification settings state
  bool _taskReminders = true;
  bool _studyStreak = true;
  bool _xpRewards = true;
  bool _dailyDigest = false;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  DateTime? _lastBackupTime;

  @override
  void initState() {
    super.initState();
    _loadNotifPrefs();
    _loadBackupTime();
  }

  Future<void> _loadNotifPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _taskReminders = prefs.getBool('notif_task_reminders') ?? true;
        _studyStreak = prefs.getBool('notif_study_streak') ?? true;
        _xpRewards = prefs.getBool('notif_xp_rewards') ?? true;
        _dailyDigest = prefs.getBool('notif_daily_digest') ?? false;
      });
    }
  }

  Future<void> _saveNotifPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _loadBackupTime() async {
    final time = await CloudBackupService().getLastBackupTime();
    if (mounted) setState(() => _lastBackupTime = time);
  }

  Future<void> _handleBackup() async {
    setState(() => _isBackingUp = true);
    final ok = await CloudBackupService().backupToCloud();
    if (ok) await _loadBackupTime();
    if (mounted) {
      setState(() => _isBackingUp = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '☁️ Backup successful!' : '❌ Backup failed'),
          backgroundColor: ok ? AppTheme.success : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _handleRestore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Restore from Cloud',
            style: GoogleFonts.outfit(color: Colors.white)),
        content: const Text(
          'This will replace your local data with the cloud backup. Continue?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Restore', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isRestoring = true);
    final ok = await CloudBackupService().restoreFromCloud();
    if (mounted) {
      setState(() => _isRestoring = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? '☁️ Restore successful! Restart the app.'
              : '❌ Restore failed'),
          backgroundColor: ok ? AppTheme.success : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ref.read(profileNotifierProvider.notifier).uploadImage(File(image.path));
    }
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final s = AppStrings.of(context);
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(s.editName, style: GoogleFonts.outfit(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: GoogleFonts.outfit(color: Colors.white),
          decoration: InputDecoration(
            hintText: s.enterNewName,
            hintStyle: const TextStyle(color: Colors.white54),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancel,
                  style: const TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(profileNotifierProvider.notifier)
                    .updateDisplayName(controller.text);
                Navigator.pop(ctx);
              }
            },
            child:
                Text(s.save, style: const TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  // ─── Notification Settings Bottom Sheet ──────────────────────────────────
  void _showNotificationSettings(BuildContext context) {
    final s = AppStrings.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F2B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Text(s.notificationSettings,
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _notifTile(
                  ctx,
                  setSheetState,
                  icon: Icons.task_alt,
                  title: s.taskReminders,
                  subtitle: 'Get reminded before tasks start',
                  value: _taskReminders,
                  key: 'notif_task_reminders',
                  onChanged: (v) => setState(() => _taskReminders = v),
                ),
                _notifTile(
                  ctx,
                  setSheetState,
                  icon: Icons.local_fire_department,
                  title: s.studyStreak,
                  subtitle: 'Daily streak maintenance alerts',
                  value: _studyStreak,
                  key: 'notif_study_streak',
                  onChanged: (v) => setState(() => _studyStreak = v),
                ),
                _notifTile(
                  ctx,
                  setSheetState,
                  icon: Icons.star,
                  title: s.xpRewards,
                  subtitle: 'XP gained and level up alerts',
                  value: _xpRewards,
                  key: 'notif_xp_rewards',
                  onChanged: (v) => setState(() => _xpRewards = v),
                ),
                _notifTile(
                  ctx,
                  setSheetState,
                  icon: Icons.summarize,
                  title: s.dailyDigest,
                  subtitle: 'Morning summary of your schedule',
                  value: _dailyDigest,
                  key: 'notif_daily_digest',
                  onChanged: (v) => setState(() => _dailyDigest = v),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await NotificationService().showSimpleNotification(
                        '🔔 Test Notification',
                        'Notifications are working! Study Planner Ultra',
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.notifications_active),
                    label: Text(s.testNotification),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _notifTile(
    BuildContext ctx,
    StateSetter setSheetState, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required String key,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(title,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12)),
      trailing: Switch(
        value: value,
        activeColor: AppTheme.primary,
        onChanged: (v) {
          setSheetState(() {});
          onChanged(v);
          _saveNotifPref(key, v);
          // Actually fire or cancel the notification
          if (v) {
            NotificationService().showSimpleNotification(
              '✅ $title Enabled',
              '$title are now active.',
            );
          }
        },
      ),
    );
  }

  // ─── Language Picker Bottom Sheet ─────────────────────────────────────────
  void _showLanguagePicker(BuildContext context) {
    final s = AppStrings.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F2B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(s.selectLanguage,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...LanguageNotifier.availableLanguages.entries.map((entry) {
                final currentLocale = ref.read(languageProvider);
                final isSelected =
                    currentLocale.languageCode == entry.value.languageCode;
                return ListTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withOpacity(0.2)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isSelected ? Icons.check_circle : Icons.language,
                      color: isSelected ? AppTheme.primary : Colors.white54,
                      size: 20,
                    ),
                  ),
                  title: Text(entry.key,
                      style: TextStyle(
                          color: isSelected ? AppTheme.primary : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal)),
                  subtitle: Text(entry.value.languageCode.toUpperCase(),
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                  onTap: () {
                    ref.read(languageProvider.notifier).setLocale(entry.value);
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Privacy / Password Bottom Sheet ─────────────────────────────────────
  void _showPrivacySettings(BuildContext context) {
    final s = AppStrings.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F2B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(s.privacy,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            // Change Password section
            Text(s.changePassword,
                style: GoogleFonts.outfit(
                    color: AppTheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _privacyOptionTile(
              icon: Icons.lock_reset,
              title: s.changePassword,
              subtitle: 'Reset via email',
              onTap: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user?.email != null) {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: user!.email!);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Password reset email sent to ${user.email}'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 8),
            _privacyOptionTile(
              icon: Icons.security,
              title: s.twoFactorAuth,
              subtitle: 'Not available for Google accounts',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('2FA managed via Firebase Console'),
                    backgroundColor: Color(0xFF1E293B),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _privacyOptionTile(
              icon: Icons.delete_forever,
              title: s.deleteAccount,
              subtitle: 'Permanently removes all your data',
              destructive: true,
              onTap: () => _confirmDeleteAccount(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _privacyOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final color = destructive ? Colors.redAccent : AppTheme.primary;
    return Material(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.outfit(
                            color:
                                destructive ? Colors.redAccent : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.white54.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext parentCtx) {
    final s = AppStrings.of(parentCtx);
    showDialog(
      context: parentCtx,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(s.deleteAccount,
            style: GoogleFonts.outfit(color: Colors.redAccent)),
        content: Text(
            'This action cannot be undone. All your study data will be permanently deleted.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancel,
                  style: const TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (parentCtx.mounted) Navigator.pop(parentCtx);
              await FirebaseAuth.instance.currentUser?.delete();
            },
            child: Text(s.deleteAccount,
                style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final userAsync = ref.watch(userProfileStreamProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white54 : const Color(0xFF64748B);
    final cardColor = isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.black.withOpacity(0.04);
    final dividerColor =
        isDark ? Colors.white10 : Colors.black.withOpacity(0.08);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: userAsync.when(
        data: (user) {
          final joinDate = user.createdAt != null
              ? DateFormat.yMMMd().format(user.createdAt!)
              : 'Unknown';
          final lastLoginStr = user.lastLoginAt != null
              ? DateFormat.jm().add_yMMMd().format(user.lastLoginAt!)
              : 'Never';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 210,
                flexibleSpace: FlexibleSpaceBar(
                  background: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        // Avatar
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppTheme.primary, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                      color: AppTheme.primary.withOpacity(0.35),
                                      blurRadius: 20,
                                      spreadRadius: 4),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 44,
                                backgroundColor:
                                    AppTheme.primary.withOpacity(0.1),
                                child: user.photoUrl != null &&
                                        user.photoUrl!.isNotEmpty
                                    ? ClipOval(
                                        child: platformNetworkImage(
                                          user.photoUrl!,
                                          width: 88,
                                          height: 88,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Text(
                                        user.displayName?[0].toUpperCase() ??
                                            'U',
                                        style: GoogleFonts.outfit(
                                            fontSize: 38, color: Colors.white),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: const BoxDecoration(
                                      color: AppTheme.primary,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        )
                            .animate()
                            .scale(duration: 500.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                user.displayName ?? 'User',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textColor),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit,
                                  color: subTextColor, size: 18),
                              onPressed: () => _showEditNameDialog(
                                  context, user.displayName ?? ''),
                            ),
                          ],
                        ),
                        Text(user.email,
                            style: GoogleFonts.outfit(
                                fontSize: 13, color: subTextColor)),
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
                      // ─── Account Stats ─────────────────────────────
                      Text(s.accountStats,
                          style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                              child: _buildStatCard(
                                  s.joined,
                                  joinDate,
                                  Icons.calendar_today,
                                  cardColor,
                                  textColor,
                                  subTextColor)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _buildStatCard(
                                  s.lastLogin,
                                  lastLoginStr,
                                  Icons.access_time,
                                  cardColor,
                                  textColor,
                                  subTextColor)),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ─── Settings ──────────────────────────────────
                      Text(s.settings,
                          style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: dividerColor),
                        ),
                        child: Column(
                          children: [
                            // Dark Mode Toggle
                            _buildSettingsTile(
                              icon: isDark ? Icons.dark_mode : Icons.light_mode,
                              title: s.darkMode,
                              subtitle: isDark ? s.darkModeOn : s.darkModeOff,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              trailing: Switch(
                                value: isDark,
                                activeColor: AppTheme.primary,
                                onChanged: (_) => ref
                                    .read(themeProvider.notifier)
                                    .toggleTheme(),
                              ),
                            ),
                            Divider(height: 1, color: dividerColor),
                            // Notifications
                            _buildSettingsTile(
                              icon: Icons.notifications_outlined,
                              title: s.notifications,
                              subtitle: s.manageAlerts,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              trailing: Icon(Icons.arrow_forward_ios,
                                  size: 14, color: subTextColor),
                              onTap: () => _showNotificationSettings(context),
                            ),
                            Divider(height: 1, color: dividerColor),
                            // Language
                            _buildSettingsTile(
                              icon: Icons.language,
                              title: s.language,
                              subtitle: ref
                                  .watch(languageProvider.notifier)
                                  .currentLanguageName,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              trailing: Icon(Icons.arrow_forward_ios,
                                  size: 14, color: subTextColor),
                              onTap: () => _showLanguagePicker(context),
                            ),
                            Divider(height: 1, color: dividerColor),
                            // Privacy
                            _buildSettingsTile(
                              icon: Icons.lock_outline,
                              title: s.privacy,
                              subtitle: s.passwordAndSecurity,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              trailing: Icon(Icons.arrow_forward_ios,
                                  size: 14, color: subTextColor),
                              onTap: () => _showPrivacySettings(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ─── Cloud Backup ────────────────────────────
                      Text('☁️ Cloud Backup',
                          style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: dividerColor),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.cloud_done_outlined,
                                      color: AppTheme.primary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Last backup',
                                          style: GoogleFonts.outfit(
                                              fontSize: 13,
                                              color: subTextColor)),
                                      Text(
                                        _lastBackupTime != null
                                            ? DateFormat.yMMMd()
                                                .add_jm()
                                                .format(_lastBackupTime!)
                                            : 'Never',
                                        style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: textColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        _isBackingUp ? null : _handleBackup,
                                    icon: _isBackingUp
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white))
                                        : const Icon(
                                            Icons.cloud_upload_outlined,
                                            size: 18),
                                    label: Text(
                                        _isBackingUp
                                            ? 'Backing up...'
                                            : 'Backup',
                                        style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w600)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        _isRestoring ? null : _handleRestore,
                                    icon: _isRestoring
                                        ? SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppTheme.primary))
                                        : Icon(Icons.cloud_download_outlined,
                                            size: 18, color: AppTheme.primary),
                                    label: Text(
                                        _isRestoring
                                            ? 'Restoring...'
                                            : 'Restore',
                                        style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primary)),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: AppTheme.primary
                                              .withOpacity(0.5)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ─── Sign Out ──────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              ref.read(authNotifierProvider.notifier).signOut(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.15),
                            foregroundColor: Colors.redAccent,
                            elevation: 0,
                            side: const BorderSide(
                                color: Colors.redAccent, width: 1),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          label: Text(s.signOut,
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.primary),
              const SizedBox(height: 16),
              Text(s.loading, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: Colors.redAccent)),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subTextColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(title,
          style: GoogleFonts.outfit(
              color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle:
          Text(subtitle, style: TextStyle(color: subTextColor, fontSize: 12)),
      trailing: trailing,
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color cardColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.outfit(
                  color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
              maxLines: 2),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(color: subTextColor, fontSize: 11)),
        ],
      ),
    );
  }
}
