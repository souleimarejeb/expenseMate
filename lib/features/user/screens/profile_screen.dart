import 'package:flutter/material.dart';
import 'package:expensemate/features/user/screens/edit_profile_screen.dart';
import 'package:expensemate/features/user/screens/sign_in_screen.dart';
import 'package:expensemate/features/user/screens/sign_up_screen.dart';
import 'package:expensemate/core/services/auth_service.dart';
import 'package:expensemate/features/user/screens/change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.black,
                child: const Icon(Icons.person, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: auth.isSignedIn,
                builder: (context, isSignedIn, _) {
                  if (!isSignedIn) {
                    return const Text(
                      'Guest',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    );
                  }
                  return FutureBuilder(
                    future: auth.getCurrentUser(),
                    builder: (context, snapshot) {
                      final name = snapshot.data?.name ?? 'User';
                      return Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 4),
              ValueListenableBuilder<bool>(
                valueListenable: auth.isSignedIn,
                builder: (context, isSignedIn, _) {
                  if (!isSignedIn) {
                    return const Text('Not signed in', style: TextStyle(color: Colors.black54));
                  }
                  return FutureBuilder(
                    future: auth.getCurrentUser(),
                    builder: (context, snapshot) {
                      final email = snapshot.data?.email ?? '';
                      return Text(email, style: const TextStyle(color: Colors.black54));
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              ValueListenableBuilder<bool>(
                valueListenable: auth.isSignedIn,
                builder: (context, isSignedIn, _) {
                  if (isSignedIn) {
                    return Column(
                      children: [
                        _ProfileTile(
                          icon: Icons.edit_outlined,
                          title: 'Edit Profile',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _ProfileTile(
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _ProfileTile(
                          icon: Icons.logout,
                          title: 'Logout',
                          onTap: () async {
                            await auth.signOut();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Signed out')),
                            );
                          },
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _ProfileTile(
                          icon: Icons.login,
                          title: 'Sign In',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SignInScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _ProfileTile(
                          icon: Icons.person_add_alt,
                          title: 'Create Account',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SignUpScreen()),
                            );
                          },
                        ),
                      ],
                    );
                  }
                },
              ),

              const SizedBox(height: 24),

              _ProfileTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy & Policy',
                onTap: () {},
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () {},
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
