import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sadhana_model.dart';
import '../services/auth_service.dart';
import '../widgets/profile_picture.dart';
import '../services/image_picker_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditProfileDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<SadhanaModel>(
        builder: (context, model, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(context, model),
                const SizedBox(height: 32),

                // Stats Summary
                _buildStatsSection(context, model),
                const SizedBox(height: 24),

                // Settings & Options
                _buildSettingsSection(context),
                const SizedBox(height: 24),

                // About Section
                _buildAboutSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, SadhanaModel model) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
                     Consumer<AuthService>(
             builder: (context, authService, child) {
               final user = authService.currentUser;
               return ProfilePicture(
                 name: user?.name ?? model.userProfile.name,
                 profilePictureBase64: user?.profilePictureBase64,
                 radius: 50,
                 showEditIcon: true,
                 onTap: () => _showProfilePictureOptions(context, authService),
               );
             },
           ),
          const SizedBox(height: 16),
                     Consumer<AuthService>(
             builder: (context, authService, child) {
               final user = authService.currentUser;
               return Column(
                 children: [
                   Text(
                     user?.name ?? model.userProfile.name,
                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   const SizedBox(height: 4),
                   if (user?.email != null) ...[
                     Text(
                       user!.email,
                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                         color: Colors.grey[600],
                       ),
                     ),
                     const SizedBox(height: 4),
                   ],
                   Text(
                     '${model.userProfile.location} ${model.userProfile.temple}',
                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                       color: Colors.grey[600],
                     ),
                   ),
                 ],
               );
             },
           ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                         decoration: BoxDecoration(
               color: const Color(0xFFFF6B35).withOpacity(0.1),
               borderRadius: BorderRadius.circular(20),
             ),
             child: Text(
               '${model.currentStreak} Day Streak',
               style: Theme.of(context).textTheme.titleMedium?.copyWith(
                 color: const Color(0xFFFF6B35),
                 fontWeight: FontWeight.w600,
               ),
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, SadhanaModel model) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sadhana Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Days',
                  '${model.sadhanaHistory.length + 1}',
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Best Streak',
                  '${model.currentStreak}',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Rounds',
                  '${_calculateTotalRounds(model)}',
                  Icons.circle_outlined,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Reading Hours',
                  '${(_calculateTotalReading(model) / 60).toStringAsFixed(1)}h',
                  Icons.menu_book,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Remind me to do sadhana',
            onTap: () {},
          ),
          _buildSettingsItem(
            context,
            icon: Icons.backup,
            title: 'Backup Data',
            subtitle: 'Save your progress',
            onTap: () {},
          ),
          _buildSettingsItem(
            context,
            icon: Icons.share,
            title: 'Share App',
            subtitle: 'Invite friends to join',
            onTap: () {},
          ),
                     _buildSettingsItem(
             context,
             icon: Icons.help,
             title: 'Help & Support',
             subtitle: 'Get assistance',
             onTap: () {},
           ),
           Consumer<SadhanaModel>(
             builder: (context, sadhanaModel, child) {
               return _buildSettingsItem(
                 context,
                 icon: Icons.admin_panel_settings,
                 title: sadhanaModel.userProfile.isAdmin ? 'Disable Admin' : 'Enable Admin',
                 subtitle: sadhanaModel.userProfile.isAdmin ? 'Remove admin privileges' : 'Get admin access for events',
                 onTap: () {
                   sadhanaModel.toggleAdminStatus();
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                       content: Text(
                         sadhanaModel.userProfile.isAdmin 
                             ? 'Admin access enabled' 
                             : 'Admin access disabled'
                       ),
                       backgroundColor: const Color(0xFFFF6B35),
                     ),
                   );
                 },
               );
             },
           ),
           _buildSettingsItem(
             context,
             icon: Icons.logout,
             title: 'Sign Out',
             subtitle: 'Logout from your account',
             onTap: () => _handleSignOut(context),
             showDivider: false,
           ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey[600]),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              color: Colors.grey[200],
              indent: 56,
            ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
                 boxShadow: [
           BoxShadow(
             color: Colors.grey.withOpacity(0.1),
             blurRadius: 5,
             offset: const Offset(0, 2),
           ),
         ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Sadhana',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This app helps ISKCON devotees track their daily spiritual practices including japa meditation, scriptural reading, lecture hearing, and devotee association.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Made with ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Icon(
                Icons.favorite,
                size: 16,
                color: Colors.red[300],
              ),
              Text(
                ' for the devotee community',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final model = Provider.of<SadhanaModel>(context, listen: false);
    final nameController = TextEditingController(text: model.userProfile.name);
    final templeController = TextEditingController(text: model.userProfile.temple);
    final locationController = TextEditingController(text: model.userProfile.location);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: templeController,
              decoration: const InputDecoration(
                labelText: 'Temple',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              model.updateUserProfile(UserProfile(
                name: nameController.text,
                temple: templeController.text,
                location: locationController.text,
              ));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  int _calculateTotalRounds(SadhanaModel model) {
    final allEntries = [model.todaySadhana, ...model.sadhanaHistory];
    return allEntries.fold<int>(0, (sum, entry) => sum + entry.japaMalaCount);
  }

     int _calculateTotalReading(SadhanaModel model) {
     final allEntries = [model.todaySadhana, ...model.sadhanaHistory];
     return allEntries.fold<int>(0, (sum, entry) => sum + entry.readingMinutes);
   }

   Future<void> _handleSignOut(BuildContext context) async {
     final confirmed = await showDialog<bool>(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('Sign Out'),
         content: const Text('Are you sure you want to sign out?'),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context, false),
             child: const Text('Cancel'),
           ),
           ElevatedButton(
             onPressed: () => Navigator.pop(context, true),
             style: ElevatedButton.styleFrom(
               backgroundColor: const Color(0xFFFF6B35),
               foregroundColor: Colors.white,
             ),
             child: const Text('Sign Out'),
           ),
         ],
       ),
     );

     if (confirmed == true) {
       final authService = Provider.of<AuthService>(context, listen: false);
       await authService.signOut();
     }
   }

   void _showProfilePictureOptions(BuildContext context, AuthService authService) {
     ImagePickerService.showImageSourceDialog(
       context,
       (base64Image) async {
         final success = await authService.updateUserProfilePicture(base64Image);
         if (success && context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
               content: Text('Profile picture updated successfully!'),
               backgroundColor: Colors.green,
               behavior: SnackBarBehavior.floating,
             ),
           );
         } else if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
               content: Text('Failed to update profile picture'),
               backgroundColor: Colors.red,
               behavior: SnackBarBehavior.floating,
             ),
           );
         }
       },
     );
   }
} 