import 'package:chat_app/providers/user_provider.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Get.find<UserProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          _buildSection(
            title: 'Account',
            items: [
              _buildSettingTile(
                context,
                icon: Icons.person,
                title: 'Profile',
                subtitle: 'Edit your profile',
                onTap: () => Get.toNamed(AppRoutes.profile),
              ),
              _buildSettingTile(
                context,
                icon: Icons.security,
                title: 'Privacy',
                subtitle: 'Privacy settings',
                onTap: () => Get.toNamed(AppRoutes.privacy),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Notifications Section
          _buildSection(
            title: 'Notifications',
            items: [
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive push notifications'),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: const Text('Message Notifications'),
                subtitle: const Text('Get notified for new messages'),
                value: true,
                onChanged: (value) {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.notifications,
                title: 'Notification Settings',
                subtitle: 'Customize notifications',
                onTap: () => Get.toNamed(AppRoutes.notificationsSettings),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Display Section
          _buildSection(
            title: 'Display',
            items: [
              _buildSettingTile(
                context,
                icon: Icons.palette,
                title: 'Theme',
                subtitle: 'Light mode',
                onTap: () => Get.toNamed(AppRoutes.appearance),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Account Settings
          _buildSection(
            title: 'Account',
            items: [
              _buildSettingTile(
                context,
                icon: Icons.account_circle,
                title: 'Account Settings',
                subtitle: 'Manage your account',
                onTap: () => Get.toNamed(AppRoutes.account),
              ),
              _buildSettingTile(
                context,
                icon: Icons.chat,
                title: 'Chat Settings',
                subtitle: 'Customize chat experience',
                onTap: () => Get.toNamed(AppRoutes.chatSettings),
              ),
              _buildSettingTile(
                context,
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get help and support',
                onTap: () => Get.toNamed(AppRoutes.help),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Logout
          ElevatedButton.icon(
            onPressed: () {
              _showLogoutDialog(context, userProvider);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              userProvider.signOut();
              Get.back();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
