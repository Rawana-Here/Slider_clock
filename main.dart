import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/theme_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const UltimateClockApp());
}

class UltimateClockApp extends StatelessWidget {
  const UltimateClockApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This sets up the ThemeProvider so any widget in the app can access it.
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        title: 'Ultimate Clock Collection',
        theme: ThemeData.dark().copyWith(
          // This ensures our slide-up menu has a cool, blurry background
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.black.withOpacity(0.5),
          ),
        ),
        debugShowCheckedModeBanner: false,
        // The HomeScreen is now the starting point of our app.
        home: const HomeScreen(),
      ),
    );
  }
}
