import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/neon_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ListView(
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            NeonCard(
              child: SwitchListTile(
                title: const Text('Dark mode'),
                subtitle: const Text('Use immersive dark + neon theme'),
                value: settings.prefs.darkMode,
                onChanged: (_) => settings.toggleDarkMode(),
              ),
            ),
            NeonCard(
              child: SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Get reminders for upcoming tasks'),
                value: settings.prefs.notificationsEnabled,
                onChanged: (_) => settings.toggleNotifications(),
              ),
            ),
            NeonCard(
              child: ListTile(
                title: const Text('Language'),
                subtitle: Text('Current: ${settings.prefs.languageCode}'),
                trailing: const Icon(Icons.language_rounded),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Choose language'),
                      backgroundColor: const Color(0xFF050816),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('English'),
                            onTap: () {
                              settings.setLanguage('en');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text('Telugu'),
                            onTap: () {
                              settings.setLanguage('te');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text('Hindi'),
                            onTap: () {
                              settings.setLanguage('hi');
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Extra Features',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 8),
            NeonCard(
              child: ListTile(
                leading: const Icon(Icons.mic_rounded),
                title: const Text('Voice Assistant'),
                subtitle:
                    const Text('Use voice commands to add or check tasks'),
                onTap: () {
                  // here you would open a VoiceAssistantScreen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Voice assistant screen not implemented demo'),
                    ),
                  );
                },
              ),
            ),
            NeonCard(
              child: ListTile(
                leading: const Icon(Icons.qr_code_scanner_rounded),
                title: const Text('Scan timetable QR'),
                subtitle:
                    const Text('Import tasks from QR / barcode timetable'),
                onTap: () {
                  // open QR scanner screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('QR scanner screen not implemented demo'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
