import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/service_provider.dart';

/// A stateful widget that overlays a privacy screen when the application goes into the background.
///
/// This serves two purposes:
/// 1. Visual Privacy: Hides sensitive vault contents from the app switcher.
/// 2. User Interaction Tracking: Resets the auto-lock timer on user interactions.
class PrivacyOverlay extends StatefulWidget {
  final Widget child;
  const PrivacyOverlay({super.key, required this.child});

  @override
  State<PrivacyOverlay> createState() => _PrivacyOverlayState();
}

class _PrivacyOverlayState extends State<PrivacyOverlay> with WidgetsBindingObserver {
  bool _isBackgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called when the system puts the app in the background or returns to foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      // Hide content when app is inactive or paused (backgrounded)
      _isBackgrounded = state == AppLifecycleState.inactive || state == AppLifecycleState.paused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        // Reset auto-lock timer on any interaction
        try {
          final services = ServiceProvider.of(context);
          services.vaultManager.resetTimer();
        } catch (_) {
          // ServiceProvider might not be available yet at the very root
        }
      },
      child: Stack(
        children: [
          widget.child,
        if (_isBackgrounded)
          Positioned.fill(
            child: Container(
              color: AppColors.deepPurple,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'PassM is Secure',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
