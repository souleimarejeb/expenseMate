// app_drawer.dart
import 'package:expensemate/routes/app_routes.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF8F9FA), // Light background
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            child: DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2E7D32), // Dark green
                    const Color(0xFF388E3C), // Medium green
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'ExpenseMate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage your finances',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.25,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Home',
            onTap: () {
              Navigator.pop(context);
            },
            color: const Color(0xFF1976D2),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.wallet,
            title: 'Budgets',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.budgetList);
            },
            color: const Color(0xFF7B1FA2),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.receipt_long,
            title: 'Expenses',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.expenses);
            },
            color: const Color(0xFFE65100), // Vibrant orange for expenses
            isHighlighted: true,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.category,
            title: 'Categories',
            onTap: () {
              Navigator.pop(context);
            },
            color: const Color(0xFF00796B),
          ),
          Divider(color: Colors.grey[300], thickness: 1),
          _buildDrawerItem(
            context,
            icon: Icons.account_circle,
            title: 'Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            color: const Color(0xFF455A64),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {},
            color: const Color(0xFF455A64),
          ),
          Divider(color: Colors.grey[300], thickness: 1),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isHighlighted ? color.withOpacity(0.1) : Colors.transparent,
        border: isHighlighted 
          ? Border.all(color: color.withOpacity(0.3), width: 1)
          : null,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: const Color(0xFF212121),
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
