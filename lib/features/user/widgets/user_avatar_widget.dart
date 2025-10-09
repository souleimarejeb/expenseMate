// user_avatar_widget.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/image_service.dart';

class UserAvatarWidget extends StatefulWidget {
  final String? avatarPath;
  final String initials;
  final double size;
  final bool isEditable;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const UserAvatarWidget({
    Key? key,
    this.avatarPath,
    required this.initials,
    this.size = 60.0,
    this.isEditable = false,
    this.onTap,
    this.onEdit,
  }) : super(key: key);

  @override
  State<UserAvatarWidget> createState() => _UserAvatarWidgetState();
}

class _UserAvatarWidgetState extends State<UserAvatarWidget>
    with SingleTickerProviderStateMixin {
  Uint8List? _avatarData;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _loadAvatar();
  }

  @override
  void didUpdateWidget(UserAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarPath != widget.avatarPath) {
      _loadAvatar();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAvatar() async {
    if (widget.avatarPath == null || widget.avatarPath!.isEmpty) {
      setState(() {
        _avatarData = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await ImageService.loadAvatar(widget.avatarPath!);
      if (mounted) {
        setState(() {
          _avatarData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _avatarData = null;
          _isLoading = false;
        });
      }
    }
  }

  void _handleTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    if (widget.onTap != null) {
      widget.onTap!();
    } else if (widget.isEditable && widget.onEdit != null) {
      widget.onEdit!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: widget.size / 2,
                    backgroundColor: _avatarData == null
                        ? ImageService.getAvatarColor(widget.initials)
                        : Colors.grey[200],
                    backgroundImage: _avatarData != null
                        ? MemoryImage(_avatarData!)
                        : null,
                    child: _isLoading
                        ? SizedBox(
                            width: widget.size * 0.4,
                            height: widget.size * 0.4,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : _avatarData == null
                            ? Text(
                                widget.initials,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: widget.size * 0.3,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                  ),
                  if (widget.isEditable)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: widget.size * 0.3,
                        height: widget.size * 0.3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.edit,
                          size: widget.size * 0.15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Hero Avatar Widget for profile screens
class HeroUserAvatar extends StatelessWidget {
  final String? avatarPath;
  final String initials;
  final double size;
  final VoidCallback? onTap;
  final String heroTag;

  const HeroUserAvatar({
    Key? key,
    this.avatarPath,
    required this.initials,
    this.size = 120.0,
    this.onTap,
    this.heroTag = 'user_avatar',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: UserAvatarWidget(
          avatarPath: avatarPath,
          initials: initials,
          size: size,
          isEditable: onTap != null,
          onTap: onTap,
        ),
      ),
    );
  }
}

// Animated Avatar Ring Widget
class AnimatedAvatarRing extends StatefulWidget {
  final Widget child;
  final Color ringColor;
  final double ringWidth;
  final Duration duration;

  const AnimatedAvatarRing({
    Key? key,
    required this.child,
    this.ringColor = Colors.blue,
    this.ringWidth = 3.0,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<AnimatedAvatarRing> createState() => _AnimatedAvatarRingState();
}

class _AnimatedAvatarRingState extends State<AnimatedAvatarRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _AvatarRingPainter(
            progress: _animation.value,
            color: widget.ringColor,
            strokeWidth: widget.ringWidth,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _AvatarRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _AvatarRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -90 * (3.14159 / 180); // Start from top
    final sweepAngle = 360 * (3.14159 / 180) * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}