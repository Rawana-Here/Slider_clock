import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/theme_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _showColorPicker(BuildContext context, Color initialColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2a2a3a),
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initialColor,
              onColorChanged: onColorChanged,
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showFontPicker(BuildContext context, ThemeProvider themeProvider) {
    final List<String> fonts = [
      'Roboto Mono', 'Source Code Pro', 'Space Mono', 'Fira Code', 'IBM Plex Mono', 'Major Mono Display'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a2a3a),
      builder: (context) {
        return ListView.builder(
          itemCount: fonts.length,
          itemBuilder: (context, index) {
            final font = fonts[index];
            final bool isActive = themeProvider.activeTheme.fontFamily == font;
            return ListTile(
              title: Text(font, style: GoogleFonts.getFont(font)),
              trailing: isActive ? Icon(Icons.check, color: themeProvider.activeTheme.primaryColor) : null,
              onTap: () {
                themeProvider.activeTheme.setFontFamily(font);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final activeTheme = themeProvider.activeTheme;
        
        return Scaffold(
          backgroundColor: activeTheme.backgroundColor,
          appBar: AppBar(
            title: Text('Settings for ${themeProvider.activeClock.name.toUpperCase()} Clock'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSettingsCard(
                context,
                title: 'Color Palette',
                children: [
                  _buildSettingTile(
                    icon: Icons.color_lens_outlined,
                    title: 'Background Color',
                    trailing: _buildColorIndicator(activeTheme.backgroundColor),
                    onTap: () => _showColorPicker(context, activeTheme.backgroundColor, activeTheme.setBackgroundColor),
                  ),
                  _buildSettingTile(
                    icon: Icons.text_fields_outlined,
                    title: 'Primary Color',
                    trailing: _buildColorIndicator(activeTheme.primaryColor),
                    onTap: () => _showColorPicker(context, activeTheme.primaryColor, activeTheme.setPrimaryColor),
                  ),
                  _buildSettingTile(
                    icon: Icons.flare_outlined,
                    title: 'Glow Color',
                    trailing: _buildColorIndicator(activeTheme.glowColor, isGlow: true),
                    onTap: () => _showColorPicker(context, activeTheme.glowColor, activeTheme.setGlowColor),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSettingsCard(
                context,
                title: 'Typography',
                children: [
                  _buildSettingTile(
                    icon: Icons.font_download_outlined,
                    title: 'Font Family',
                    subtitle: activeTheme.fontFamily,
                    onTap: () => _showFontPicker(context, themeProvider),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                icon: const Icon(Icons.refresh, color: Colors.white54),
                label: const Text('Reset Theme to Default', style: TextStyle(color: Colors.white54)),
                onPressed: () {
                  themeProvider.resetThemeToDefault(themeProvider.activeClock);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorIndicator(Color color, {bool isGlow = false}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white30),
        boxShadow: isGlow ? [BoxShadow(color: color, blurRadius: 5)] : [],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.white54)) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
