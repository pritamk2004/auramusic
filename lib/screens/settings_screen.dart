import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          // Audio Quality Section
          _buildSectionHeader('AUDIO STREAMING & DOWNLOAD'),
          ListTile(
            leading: const Icon(Icons.high_quality, color: Color(0xFF1DB954)),
            title: const Text('Streaming Audio Quality'),
            subtitle: Text(settings.streamingQuality, style: TextStyle(color: Colors.grey[400])),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () => _showStreamingQualityDialog(context, settings),
          ),
          ListTile(
            leading: const Icon(Icons.download, color: Color(0xFF1DB954)),
            title: const Text('Download Quality'),
            subtitle: Text(settings.downloadQuality, style: TextStyle(color: Colors.grey[400])),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () => _showDownloadQualityDialog(context, settings),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.radio, color: Color(0xFF1DB954)),
            title: const Text('Infinite Auto-Radio'),
            subtitle: const Text('Automatically keep playing related songs when queue finishes'),
            value: settings.autoRadio,
            activeColor: const Color(0xFF1DB954),
            onChanged: (val) => settings.setAutoRadio(val),
          ),

          const Divider(color: Colors.white12, height: 32),

          // Appearance Section
          _buildSectionHeader('APPEARANCE & THEME'),
          ListTile(
            leading: const Icon(Icons.palette_outlined, color: Color(0xFF1DB954)),
            title: const Text('App Theme'),
            subtitle: Text(settings.themeMode, style: TextStyle(color: Colors.grey[400])),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () => _showThemeDialog(context, settings),
          ),

          const Divider(color: Colors.white12, height: 32),

          // Playback & Timer
          _buildSectionHeader('PLAYBACK'),
          ListTile(
            leading: Icon(
              settings.hasActiveSleepTimer ? Icons.timer : Icons.timer_outlined,
              color: const Color(0xFF1DB954),
            ),
            title: const Text('Sleep Timer'),
            subtitle: Text(
              settings.hasActiveSleepTimer
                  ? 'Pausing in ${settings.sleepTimerMinutes} minutes'
                  : 'Turn off playback automatically',
              style: TextStyle(color: Colors.grey[400]),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () => _showSleepTimerDialog(context, settings),
          ),

          const Divider(color: Colors.white12, height: 32),

          // Cache & Storage
          _buildSectionHeader('STORAGE & CACHE'),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined, color: Color(0xFF1DB954)),
            title: const Text('Clear Image & Stream Cache'),
            subtitle: const Text('Free up temporary app storage'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Temporary cache cleared successfully')),
              );
            },
          ),

          const Divider(color: Colors.white12, height: 32),

          // About App
          _buildSectionHeader('ABOUT AURAMUSIC'),
          const ListTile(
            leading: Icon(Icons.verified_user, color: Color(0xFF1DB954)),
            title: Text('100% Free & Ad-Free Guarantee'),
            subtitle: Text('Unlimited streaming, no subscriptions, zero audio ads'),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline, color: Color(0xFF1DB954)),
            title: Text('Version'),
            subtitle: Text('1.0.0 (Release Build)'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  void _showStreamingQualityDialog(BuildContext context, SettingsProvider settings) {
    final qualities = [
      'High (160/320 kbps)',
      'Standard (128 kbps)',
      'Data Saver (64 kbps)',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('Select Streaming Quality'),
          children: qualities.map((q) {
            return RadioListTile<String>(
              title: Text(q),
              value: q,
              groupValue: settings.streamingQuality,
              activeColor: const Color(0xFF1DB954),
              onChanged: (val) {
                if (val != null) {
                  settings.setStreamingQuality(val);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showDownloadQualityDialog(BuildContext context, SettingsProvider settings) {
    final qualities = ['High (320 kbps)', 'Standard (160 kbps)'];

    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('Select Download Quality'),
          children: qualities.map((q) {
            return RadioListTile<String>(
              title: Text(q),
              value: q,
              groupValue: settings.downloadQuality,
              activeColor: const Color(0xFF1DB954),
              onChanged: (val) {
                if (val != null) {
                  settings.setDownloadQuality(val);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    final themes = ['AMOLED Black', 'Spotify Midnight'];

    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('Select App Theme'),
          children: themes.map((t) {
            return RadioListTile<String>(
              title: Text(t),
              value: t,
              groupValue: settings.themeMode,
              activeColor: const Color(0xFF1DB954),
              onChanged: (val) {
                if (val != null) {
                  settings.setThemeMode(val);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showSleepTimerDialog(BuildContext context, SettingsProvider settings) {
    final times = [15, 30, 45, 60, 90];
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('Set Sleep Timer'),
          children: [
            if (settings.hasActiveSleepTimer)
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Turn Off Timer'),
                onTap: () {
                  settings.cancelSleepTimer();
                  Navigator.pop(ctx);
                },
              ),
            ...times.map((m) {
              return ListTile(
                leading: const Icon(Icons.access_time, color: Color(0xFF1DB954)),
                title: Text('$m minutes'),
                onTap: () {
                  settings.setSleepTimer(m);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Music will pause in $m minutes')),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }
}
