import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/presentation/cubits/auth_cubit.dart';

// Settings Service Class
class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user settings
  Future<Map<String, dynamic>> getSettings() async {
    final user = _auth.currentUser;
    if (user == null) return _getDefaultSettings();
    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('preferences')
          .get();
      if (doc.exists) {
        return doc.data() ?? _getDefaultSettings();
      }
      return _getDefaultSettings();
    } catch (e) {
      print('Error getting settings: $e');
      return _getDefaultSettings();
    }
  }

  // Save settings
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('preferences')
        .set(settings, SetOptions(merge: true));
  }

  // Get default settings
  Map<String, dynamic> _getDefaultSettings() {
    return {
      'notifications': true,
      'dailyReminders': true,
      'soundEffects': true,
      'darkMode': false,
      'language': 'English',
      'dataBackup': true,
      'shareAnalytics': false,
    };
  }

  // Stream settings
  Stream<Map<String, dynamic>> getSettingsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(_getDefaultSettings());
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('preferences')
        .snapshots()
        .map((doc) => doc.exists ? doc.data()! : _getDefaultSettings());
  }
}

// Settings Screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> _settings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.getSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    setState(() {
      _settings[key] = value;
    });
    await _settingsService.saveSettings(_settings);
  }

  void _showAboutDialog() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: primaryColor),
            SizedBox(width: 12),
            Text(
              'About MindHaven',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'MindHaven is your compassionate mental health companion, designed to provide support, guidance, and a safe space for students.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Created by Paul Mubanga',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              '© 2025 MindHaven. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Bemba', 'Nyanja', 'Tonga'];
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Select Language',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _settings['language'],
              activeColor: primaryColor,
              onChanged: (value) {
                Navigator.pop(context);
                _updateSetting('language', value);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[700]),
            SizedBox(width: 12),
            Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'This action cannot be undone. All your data including:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            _buildWarningItem('Chat history'),
            _buildWarningItem('Journal entries'),
            _buildWarningItem('Mood tracking data'),
            _buildWarningItem('Profile information'),
            SizedBox(height: 12),
            Text(
              'will be permanently deleted.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              );
              try {
                // Get current user
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // Delete user data from Firestore
                  await _firestore.collection('users').doc(user.uid).delete();
                  // Delete the auth account (and log out) via AuthCubit
                  await context.read<AuthCubit>().deleteAccount();
                }
                // Close loading
                if (mounted) Navigator.pop(context);
              } catch (e) {
                Navigator.pop(context); // Close loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete account: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.close, size: 16, color: Colors.red[700]),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(String dataType) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    String title, message, collection;
    switch (dataType) {
      case 'chats':
        title = 'Clear Chat History';
        message = 'This will delete all your chat conversations.';
        collection = 'chats';
        break;
      case 'journal':
        title = 'Clear Journal Entries';
        message = 'This will delete all your journal entries.';
        collection = 'journal';
        break;
      case 'moods':
        title = 'Clear Mood Data';
        message = 'This will delete all your mood tracking data.';
        collection = 'moods';
        break;
      default:
        return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        content: Text(
          '$message This action cannot be undone.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final snapshot = await _firestore
                      .collection('users')
                      .doc(user.uid)
                      .collection(collection)
                      .get();
                  for (var doc in snapshot.docs) {
                    await doc.reference.delete();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$title completed successfully')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to clear data: $e')),
                );
              }
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          backgroundColor: primaryColor,
          elevation: 4,
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 4,
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 16),
        children: [
          // Notifications Section
          _buildSectionHeader('Notifications', Icons.notifications_outlined),
          _buildSettingTile(
            icon: Icons.notifications_active,
            title: 'Enable Notifications',
            subtitle: 'Receive app notifications',
            trailing: Switch(
              value: _settings['notifications'] ?? true,
              activeColor: primaryColor,
              onChanged: (value) => _updateSetting('notifications', value),
            ),
          ),
          _buildSettingTile(
            icon: Icons.alarm,
            title: 'Daily Reminders',
            subtitle: 'Get reminded to check in daily',
            trailing: Switch(
              value: _settings['dailyReminders'] ?? true,
              activeColor: primaryColor,
              onChanged: (value) => _updateSetting('dailyReminders', value),
            ),
          ),
          Divider(height: 32, thickness: 8, color: Colors.grey[200]),
          // Appearance Section
          _buildSectionHeader('Appearance', Icons.palette_outlined),
          _buildSettingTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Switch to dark theme',
            trailing: Switch(
              value: _settings['darkMode'] ?? false,
              activeColor: primaryColor,
              onChanged: (value) => _updateSetting('darkMode', value),
            ),
          ),
          _buildSettingTile(
            icon: Icons.volume_up,
            title: 'Sound Effects',
            subtitle: 'Enable app sounds',
            trailing: Switch(
              value: _settings['soundEffects'] ?? true,
              activeColor: primaryColor,
              onChanged: (value) => _updateSetting('soundEffects', value),
            ),
          ),
          _buildSettingTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: _settings['language'] ?? 'English',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: _showLanguageDialog,
          ),
          Divider(height: 32, thickness: 8, color: Colors.grey[200]),
          // Privacy & Security Section
          _buildSectionHeader('Privacy & Security', Icons.security_outlined),
          _buildSettingTile(
            icon: Icons.backup,
            title: 'Data Backup',
            subtitle: 'Automatically backup your data',
            trailing: Switch(
              value: _settings['dataBackup'] ?? true,
              activeColor: primaryColor,
              onChanged: (value) => _updateSetting('dataBackup', value),
            ),
          ),
          _buildSettingTile(
            icon: Icons.analytics,
            title: 'Share Analytics',
            subtitle: 'Help improve the app',
            trailing: Switch(
              value: _settings['shareAnalytics'] ?? false,
              activeColor: primaryColor,
              onChanged: (value) => _updateSetting('shareAnalytics', value),
            ),
          ),
          Divider(height: 32, thickness: 8, color: Colors.grey[200]),
          // Data Management Section
          _buildSectionHeader('Data Management', Icons.storage_outlined),
          _buildSettingTile(
            icon: Icons.chat,
            title: 'Clear Chat History',
            subtitle: 'Delete all chat conversations',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: () => _showClearDataDialog('chats'),
          ),
          _buildSettingTile(
            icon: Icons.book,
            title: 'Clear Journal Entries',
            subtitle: 'Delete all journal entries',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: () => _showClearDataDialog('journal'),
          ),
          _buildSettingTile(
            icon: Icons.mood,
            title: 'Clear Mood Data',
            subtitle: 'Delete all mood tracking data',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: () => _showClearDataDialog('moods'),
          ),
          Divider(height: 32, thickness: 8, color: Colors.grey[200]),
          // Support Section
          _buildSectionHeader('Support', Icons.help_outline),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: _showAboutDialog,
          ),
          _buildSettingTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we protect your data',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Privacy Policy page coming soon')),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'App usage terms',
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Terms of Service page coming soon')),
              );
            },
          ),
          Divider(height: 32, thickness: 8, color: Colors.grey[200]),
          // Danger Zone
          _buildSectionHeader('Danger Zone', Icons.warning_outlined, color: Colors.red),
          _buildSettingTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            titleColor: Colors.red[700],
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red[400]),
            onTap: _showDeleteAccountDialog,
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Color? color}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey[700]),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (titleColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: titleColor ?? Theme.of(context).colorScheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: titleColor ?? Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}
