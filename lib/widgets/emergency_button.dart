import 'package:flutter/material.dart';
import 'package:sentry/theme/sentry_theme.dart';
import 'dart:async';

class EmergencyButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  
  const EmergencyButton({
    super.key,
    required this.onPressed,
    this.label = 'EMERGENCY',
    this.icon = Icons.warning_rounded,
  });

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  void _handlePress() {
    setState(() {
      _isPressed = true;
    });
    
    widget.onPressed();
    
    // Visual feedback after button press
    _feedbackTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isPressed = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? 0.95 : _pulseAnimation.value,
          child: GestureDetector(
            onTap: _handlePress,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isPressed 
                      ? [SentryTheme.alertRed, SentryTheme.alertRed.withOpacity(0.8)]
                      : [SentryTheme.alertRed, const Color(0xFFFF4D4D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: SentryTheme.alertRed.withOpacity(_isPressed ? 0.6 : 0.4),
                    blurRadius: _isPressed ? 20 : 12,
                    spreadRadius: _isPressed ? 4 : 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.transparent,
                  onTap: _handlePress,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
