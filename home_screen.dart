import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Needed for the blur effect
import '../models/theme_provider.dart';

// Import all your clock widgets with the correct paths
import '../clocks/sliding_clock.dart';
import '../clocks/Fading_clock.dart';
import '../clocks/gyro_clock.dart';
import '../clocks/rotating_ring_clock.dart';
import '../clocks/orbital_clock.dart';
import '../clocks/text_clock.dart';
import '../clocks/corner_rotation_clock.dart';
import 'theme_selection_screen.dart';
import 'stopwatch_screen.dart';
import 'timer_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _tapAnimationController;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    // Set the app to a true full-screen immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Controller for the new tap animation
    _tapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _tapAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _tapAnimationController,
        curve: Curves.easeInOut,
        reverseCurve: Curves.elasticIn,
      ),
    );
  }

  @override
  void dispose() {
    _tapAnimationController.dispose();
    // Restore system UI when the app is closed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.activeTheme;
        return Scaffold(
          backgroundColor: theme.backgroundColor,
          // The entire screen is now a button to open the menu
          body: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Play the tap animation and show the menu
              _tapAnimationController.forward().then((_) {
                _tapAnimationController.reverse();
              });
              _showMainMenu(context, theme);
            },
            child: ScaleTransition(
              scale: _tapAnimation,
              child: Center(
                child: _buildActiveClock(themeProvider.activeClock, theme),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveClock(ClockType type, ClockTheme theme) {
    switch (type) {
      case ClockType.sliding:
        return SlidingClockScreen(theme: theme);
      case ClockType.fading:
        return ClockScreen(theme: theme);
      case ClockType.gyro:
        return GyroClockScreen(theme: theme);
      case ClockType.rotatingRing:
        return RotatingRingClockScreen(theme: theme);
      case ClockType.orbital:
        return OrbitalClockScreen(theme: theme);
      case ClockType.text:
        return TextClockScreen(theme: theme);
      case ClockType.cornerRotation:
        return CornerRotationClockScreen(theme: theme);
      default:
        return SlidingClockScreen(theme: theme);
    }
  }

  void _showMainMenu(BuildContext context, ClockTheme theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return _MainMenuSheet(theme: theme);
      },
    );
  }
}

// A private stateful widget for the bottom sheet content
class _MainMenuSheet extends StatefulWidget {
  final ClockTheme theme;
  const _MainMenuSheet({required this.theme});

  @override
  State<_MainMenuSheet> createState() => _MainMenuSheetState();
}

class _MainMenuSheetState extends State<_MainMenuSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        // Make height responsive to screen size
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
            // Refined glass color
            color: Colors.black.withOpacity(0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(color: Colors.white12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text("Menu",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const Divider(color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAnimatedMenuIcon(context, 0, Icons.watch, "Themes", () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeSelectionScreen()));
                }),
                _buildAnimatedMenuIcon(context, 1, Icons.timer, "Stopwatch", () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => StopwatchScreen(theme: widget.theme)));
                }),
                _buildAnimatedMenuIcon(context, 2, Icons.hourglass_bottom, "Timer", () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TimerScreen(theme: widget.theme)));
                }),
                _buildAnimatedMenuIcon(context, 3, Icons.settings, "Settings", () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedMenuIcon(
      BuildContext context, int index, IconData icon, String label, VoidCallback onTap) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Interval(0.2 * index, 1.0, curve: Curves.easeOut),
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
            .animate(animation),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(label, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
