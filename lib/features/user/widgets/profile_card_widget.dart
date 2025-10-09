// profile_card_widget.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'user_avatar_widget.dart';

class ProfileCardWidget extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final bool showActions;
  final bool isCompact;

  const ProfileCardWidget({
    Key? key,
    required this.user,
    this.onTap,
    this.onEdit,
    this.showActions = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Theme.of(context).primaryColor.withOpacity(0.05),
              ],
            ),
          ),
          child: isCompact ? _buildCompactLayout(context) : _buildFullLayout(context),
        ),
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Row(
      children: [
        UserAvatarWidget(
          avatarPath: user.avatarPath,
          initials: user.initials,
          size: 50,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (showActions)
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            iconSize: 20,
          ),
      ],
    );
  }

  Widget _buildFullLayout(BuildContext context) {
    return Column(
      children: [
        // Header with avatar and basic info
        Row(
          children: [
            HeroUserAvatar(
              avatarPath: user.avatarPath,
              initials: user.initials,
              size: 80,
              heroTag: 'profile_${user.id}',
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (user.occupation != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.occupation!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (showActions)
              Column(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
          ],
        ),
        
        // Divider
        const SizedBox(height: 16),
        Divider(color: Colors.grey[300]),
        const SizedBox(height: 16),
        
        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              icon: Icons.account_balance_wallet,
              label: 'Monthly Income',
              value: user.monthlyIncome != null
                  ? '\$${user.monthlyIncome!.toStringAsFixed(0)}'
                  : 'Not set',
            ),
            _buildStatItem(
              context,
              icon: Icons.calendar_today,
              label: 'Age',
              value: user.age != null ? '${user.age} years' : 'Not set',
            ),
            _buildStatItem(
              context,
              icon: Icons.schedule,
              label: 'Member since',
              value: _formatMemberSince(user.createdAt),
            ),
          ],
        ),
        
        // Bio section
        if (user.bio != null && user.bio!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.bio!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatMemberSince(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}m ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else {
      return 'Today';
    }
  }
}

// Animated Profile Card with shimmer effect
class AnimatedProfileCard extends StatefulWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const AnimatedProfileCard({
    Key? key,
    required this.user,
    this.onTap,
    this.onEdit,
  }) : super(key: key);

  @override
  State<AnimatedProfileCard> createState() => _AnimatedProfileCardState();
}

class _AnimatedProfileCardState extends State<AnimatedProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ProfileCardWidget(
              user: widget.user,
              onTap: widget.onTap,
              onEdit: widget.onEdit,
            ),
          ),
        );
      },
    );
  }
}

// Profile Summary Card (compact version for lists)
class ProfileSummaryCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final bool showStatus;

  const ProfileSummaryCard({
    Key? key,
    required this.user,
    this.onTap,
    this.showStatus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: UserAvatarWidget(
          avatarPath: user.avatarPath,
          initials: user.initials,
          size: 40,
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            if (user.occupation != null)
              Text(
                user.occupation!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: showStatus
            ? Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: user.isActive ? Colors.green : Colors.grey,
                ),
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}