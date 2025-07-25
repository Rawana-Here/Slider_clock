import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/theme_provider.dart';

// Import all clock widgets to be used as previews
import '../clocks/sliding_clock.dart';
import '../clocks/Fading_clock.dart';
import '../clocks/gyro_clock.dart';
import '../clocks/rotating_ring_clock.dart';
import '../clocks/orbital_clock.dart';
import '../clocks/text_clock.dart';
import '../clocks/corner_rotation_clock.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black, // A neutral background for the gallery
      appBar: AppBar(
        title: const Text('Select a Clock Theme'),
        backgroundColor: const Color(0xFF1a2a3a),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: screenWidth > 600 ? 3 : 2, // Responsive grid
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: ClockType.values.length,
        itemBuilder: (context, index) {
          final clockType = ClockType.values[index];
          final theme = themeProvider.activeThemeFor(clockType);
          final bool isActive = themeProvider.activeClock == clockType;

          return _buildClockPreviewCard(
            context: context,
            title: _getClockName(clockType),
            clockPreview: _getClockPreview(clockType, theme),
            theme: theme,
            isActive: isActive,
            onTap: () => themeProvider.setActiveClock(clockType),
          );
        },
      ),
    );
  }

  String _getClockName(ClockType type) {
    // Simple helper to format enum names nicely
    return type.name.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim().toUpperCase();
  }

  Widget _getClockPreview(ClockType type, ClockTheme theme) {
    // Return the correct clock widget for the preview
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
    }
  }

  Widget _buildClockPreviewCard({
    required BuildContext context,
    required String title,
    required Widget clockPreview,
    required ClockTheme theme,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isActive ? 10 : 2,
        clipBehavior: Clip.antiAlias, // Ensures the preview is contained
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isActive ? theme.glowColor : Colors.white12,
            width: isActive ? 3 : 1,
          ),
        ),
        color: theme.backgroundColor,
        child: Stack(
          children: [
            // The live clock preview, scaled down to fit the card
            Transform.scale(
              scale: 0.4, // Adjust scale to fit your previews best
              child: IgnorePointer( // Prevents interaction with the small clock
                child: clockPreview,
              ),
            ),
            // Gradient overlay for text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            // Clock title and selection indicator
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (isActive)
                    Icon(Icons.check_circle, color: theme.primaryColor, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
