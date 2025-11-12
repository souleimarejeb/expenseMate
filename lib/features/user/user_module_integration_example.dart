import 'package:flutter/material.dart';
import 'package:expensemate/features/user/screens/user_list_screen.dart';

/// Example of how to integrate the User module into your app
/// 
/// This file demonstrates various ways to navigate to the user management screens
/// and use the user functionality throughout the application.

class UserModuleIntegrationExample extends StatelessWidget {
  const UserModuleIntegrationExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Module Integration'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'User Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'The user module provides complete CRUD operations for managing users in the ExpenseMate application.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          
          // Navigate to User List
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserListScreen(),
                ),
              );
            },
            icon: const Icon(Icons.people),
            label: const Text('Open User Management'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          
          const Text(
            'Features:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildFeatureItem(
            icon: Icons.add_circle,
            title: 'Create Users',
            description: 'Add new users with name, email, phone, bio, and profile image',
          ),
          _buildFeatureItem(
            icon: Icons.edit,
            title: 'Update Users',
            description: 'Edit user information and update profile details',
          ),
          _buildFeatureItem(
            icon: Icons.delete,
            title: 'Delete Users',
            description: 'Remove users from the system with confirmation',
          ),
          _buildFeatureItem(
            icon: Icons.search,
            title: 'Search Users',
            description: 'Find users by name or email address',
          ),
          _buildFeatureItem(
            icon: Icons.storage,
            title: 'SQLite Integration',
            description: 'All data persisted locally with SQLite database',
          ),
          _buildFeatureItem(
            icon: Icons.person,
            title: 'User Details',
            description: 'View comprehensive user information and preferences',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Add this to your app's navigation/routing:
/// 
/// Example 1: Direct Navigation
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const UserListScreen(),
///   ),
/// );
/// ```
/// 
/// Example 2: Named Routes (if using routes in your app)
/// In your routes configuration:
/// ```dart
/// '/users': (context) => const UserListScreen(),
/// '/user/create': (context) => const UserFormScreen(),
/// '/user/detail': (context) => UserDetailScreen(user: args),
/// ```
/// 
/// Example 3: Add to Drawer/Menu
/// ```dart
/// ListTile(
///   leading: const Icon(Icons.people),
///   title: const Text('Users'),
///   onTap: () {
///     Navigator.push(
///       context,
///       MaterialPageRoute(
///         builder: (context) => const UserListScreen(),
///       ),
///     );
///   },
/// )
/// ```
