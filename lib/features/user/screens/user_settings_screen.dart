// user_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../widgets/settings_tile_widget.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({Key? key}) : super(key: key);

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final preferencesProvider = Provider.of<UserPreferencesProvider>(context, listen: false);
    
    if (userProvider.currentUser != null) {
      preferencesProvider.loadPreferences(userProvider.currentUser!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer2<UserProvider, UserPreferencesProvider>(
        builder: (context, userProvider, preferencesProvider, child) {
          if (userProvider.currentUser == null) {
            return const Center(
              child: Text('No user logged in'),
            );
          }

          final user = userProvider.currentUser!;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildUserHeader(user),
                const SizedBox(height: 8),
                _buildAppearanceSection(user.id!, preferencesProvider),
                const SizedBox(height: 8),
                _buildNotificationSection(user.id!, preferencesProvider),
                const SizedBox(height: 8),
                _buildSecuritySection(user.id!, preferencesProvider),
                const SizedBox(height: 8),
                _buildDataSection(user.id!, preferencesProvider),
                const SizedBox(height: 8),
                _buildGeneralSection(user.id!, preferencesProvider),
                const SizedBox(height: 8),
                _buildDangerZoneSection(context, userProvider),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserHeader(dynamic user) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              user.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user.email,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(int userId, UserPreferencesProvider preferencesProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SettingsSectionHeader(
            title: 'Appearance',
            icon: Icons.palette,
          ),
          SelectionSettingsTile(
            icon: Icons.brightness_6,
            title: 'Theme',
            currentValue: _getThemeDisplayName(preferencesProvider.preferences.theme),
            options: const ['Light', 'Dark', 'System'],
            onChanged: (value) => _updateTheme(userId, preferencesProvider, value),
          ),
          SelectionSettingsTile(
            icon: Icons.language,
            title: 'Language',
            currentValue: _getLanguageDisplayName(preferencesProvider.preferences.language),
            options: const ['English', 'Spanish', 'French'],
            onChanged: (value) => _updateLanguage(userId, preferencesProvider, value),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(int userId, UserPreferencesProvider preferencesProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SettingsSectionHeader(
            title: 'Notifications',
            icon: Icons.notifications,
          ),
          ToggleSettingsTile(
            icon: Icons.notifications_active,
            title: 'Push Notifications',
            subtitle: 'Receive notifications about your expenses',
            value: preferencesProvider.preferences.enableNotifications,
            onChanged: (value) => preferencesProvider.setNotifications(userId, value),
          ),
          SliderSettingsTile(
            icon: Icons.warning,
            title: 'Budget Alert Threshold',
            subtitle: 'Get notified when reaching this percentage of budget',
            value: preferencesProvider.preferences.budgetAlertThreshold,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            onChanged: (value) => preferencesProvider.setBudgetAlertThreshold(userId, value),
            valueFormatter: (value) => '${(value * 100).toInt()}%',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(int userId, UserPreferencesProvider preferencesProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SettingsSectionHeader(
            title: 'Security',
            icon: Icons.security,
          ),
          ToggleSettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Authentication',
            subtitle: 'Use fingerprint or face ID to unlock',
            value: preferencesProvider.preferences.enableBiometric,
            onChanged: (value) => preferencesProvider.setBiometric(userId, value),
          ),
          ActionSettingsTile(
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () => _showChangePasswordDialog(context),
          ),
          ActionSettingsTile(
            icon: Icons.history,
            title: 'Login History',
            subtitle: 'View recent login activity',
            onTap: () => _showLoginHistory(context),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(int userId, UserPreferencesProvider preferencesProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SettingsSectionHeader(
            title: 'Data & Privacy',
            icon: Icons.cloud,
          ),
          ToggleSettingsTile(
            icon: Icons.backup,
            title: 'Auto Backup',
            subtitle: 'Automatically backup your data',
            value: preferencesProvider.preferences.enableBackup,
            onChanged: (value) => preferencesProvider.setBackup(userId, value),
          ),
          ToggleSettingsTile(
            icon: Icons.analytics,
            title: 'Usage Analytics',
            subtitle: 'Help improve the app by sharing usage data',
            value: preferencesProvider.preferences.enableAnalytics,
            onChanged: (value) => preferencesProvider.setAnalytics(userId, value),
          ),
          ActionSettingsTile(
            icon: Icons.download,
            title: 'Export Data',
            subtitle: 'Download your data in various formats',
            onTap: () => _exportData(context),
          ),
          ActionSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () => _showPrivacyPolicy(context),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSection(int userId, UserPreferencesProvider preferencesProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SettingsSectionHeader(
            title: 'General',
            icon: Icons.settings,
          ),
          SelectionSettingsTile(
            icon: Icons.attach_money,
            title: 'Default Currency',
            currentValue: preferencesProvider.preferences.currency,
            options: const ['USD', 'EUR', 'GBP', 'JPY', 'CAD'],
            onChanged: (value) => preferencesProvider.setCurrency(userId, value),
          ),
          SelectionSettingsTile(
            icon: Icons.date_range,
            title: 'Date Format',
            currentValue: preferencesProvider.preferences.dateFormat,
            options: const ['MM/dd/yyyy', 'dd/MM/yyyy', 'yyyy-MM-dd'],
            onChanged: (value) => preferencesProvider.setDateFormat(userId, value),
          ),
          SelectionSettingsTile(
            icon: Icons.schedule,
            title: 'Time Format',
            currentValue: preferencesProvider.preferences.timeFormat,
            options: const ['12h', '24h'],
            onChanged: (value) => preferencesProvider.setTimeFormat(userId, value),
          ),
          ActionSettingsTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help with using the app',
            onTap: () => _showHelp(context),
          ),
          ActionSettingsTile(
            icon: Icons.info,
            title: 'About',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAbout(context),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneSection(BuildContext context, UserProvider userProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.red[50],
      child: Column(
        children: [
          const SettingsSectionHeader(
            title: 'Danger Zone',
            icon: Icons.warning,
          ),
          ActionSettingsTile(
            icon: Icons.refresh,
            title: 'Reset Preferences',
            subtitle: 'Reset all settings to default',
            onTap: () => _showResetPreferencesDialog(context),
            isDangerous: true,
          ),
          ActionSettingsTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account and all data',
            onTap: () => _showDeleteAccountDialog(context, userProvider),
            isDangerous: true,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
        return 'System';
      default:
        return 'System';
    }
  }

  String _getLanguageDisplayName(String language) {
    switch (language) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      default:
        return 'English';
    }
  }

  void _updateTheme(int userId, UserPreferencesProvider preferencesProvider, String displayName) {
    String themeValue;
    switch (displayName) {
      case 'Light':
        themeValue = 'light';
        break;
      case 'Dark':
        themeValue = 'dark';
        break;
      case 'System':
        themeValue = 'system';
        break;
      default:
        themeValue = 'system';
        break;
    }
    preferencesProvider.setTheme(userId, themeValue);
  }

  void _updateLanguage(int userId, UserPreferencesProvider preferencesProvider, String displayName) {
    String languageValue;
    switch (displayName) {
      case 'English':
        languageValue = 'en';
        break;
      case 'Spanish':
        languageValue = 'es';
        break;
      case 'French':
        languageValue = 'fr';
        break;
      default:
        languageValue = 'en';
        break;
    }
    preferencesProvider.setLanguage(userId, languageValue);
  }

  void _showChangePasswordDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Change password feature coming soon!'),
      ),
    );
  }

  void _showLoginHistory(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login history feature coming soon!'),
      ),
    );
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export feature coming soon!'),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy policy feature coming soon!'),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help & support feature coming soon!'),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ExpenseMate',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.account_balance_wallet, size: 64),
      children: const [
        Text('A comprehensive expense management application built with Flutter.'),
      ],
    );
  }

  void _showResetPreferencesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Preferences'),
          content: const Text(
            'Are you sure you want to reset all preferences to default? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement reset preferences
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preferences reset to default'),
                  ),
                );
              },
              child: const Text(
                'Reset',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This will permanently delete all your data and cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // TODO: Implement account deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deletion feature coming soon!'),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}