import 'package:flutter/material.dart';
import 'dart:ui';
import 'pages/map_page.dart';
import 'pages/profile_page.dart';
import 'pages/placeholder_page.dart';

final ColorScheme dipColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF2196F3),
  primary: const Color(0xFF2196F3),
  secondary: const Color(0xFF64B5F6),
  surface: const Color(0xFFE3F2FD),
  onPrimary: Colors.white,
  onSecondary: Colors.white,
  onSurface: const Color(0xFF0D47A1),
  brightness: Brightness.light,
);

final ColorScheme dipDarkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF0D47A1),
  primary: const Color(0xFF1976D2),
  secondary: const Color(0xFF64B5F6),
  surface: const Color(0xFF102840),
  onPrimary: Colors.white,
  onSecondary: Colors.white,
  onSurface: Colors.white,
  brightness: Brightness.dark,
);

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);

class DipApp extends StatelessWidget {
  const DipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Dip - Carte des baignades',
          theme: ThemeData(
            colorScheme: dipColorScheme,
            useMaterial3: true,
            fontFamily: 'Montserrat',
            scaffoldBackgroundColor: const Color(0xFFF7F9FB),
            appBarTheme: AppBarTheme(
              backgroundColor: dipColorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
                letterSpacing: 1.1,
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: dipColorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.white.withValues(alpha: 0.95),
              selectedItemColor: dipColorScheme.primary,
              unselectedItemColor: dipColorScheme.secondary,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
            ),
            sliderTheme: SliderThemeData(
              activeTrackColor: dipColorScheme.primary,
              inactiveTrackColor: dipColorScheme.secondary.withValues(alpha: 0.3),
              thumbColor: dipColorScheme.primary,
              overlayColor: dipColorScheme.primary.withValues(alpha: 0.1),
            ),
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: dipColorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: dipColorScheme.primary,
              contentTextStyle: const TextStyle(color: Colors.white),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: dipDarkColorScheme,
            useMaterial3: true,
            fontFamily: 'Montserrat',
            scaffoldBackgroundColor: const Color(0xFF0A1929),
            appBarTheme: AppBarTheme(
              backgroundColor: dipDarkColorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
                letterSpacing: 1.1,
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: dipDarkColorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: dipDarkColorScheme.surface.withValues(alpha: 0.95),
              selectedItemColor: dipDarkColorScheme.primary,
              unselectedItemColor: dipDarkColorScheme.secondary,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
            ),
            sliderTheme: SliderThemeData(
              activeTrackColor: dipDarkColorScheme.primary,
              inactiveTrackColor: dipDarkColorScheme.secondary.withValues(alpha: 0.3),
              thumbColor: dipDarkColorScheme.primary,
              overlayColor: dipDarkColorScheme.primary.withValues(alpha: 0.1),
            ),
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: dipDarkColorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: dipDarkColorScheme.primary,
              contentTextStyle: const TextStyle(color: Colors.white),
            ),
          ),
          themeMode: mode,
          home: MainNavigation(onThemeModeChanged: (ThemeMode m) => themeModeNotifier.value = m),
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  final void Function(ThemeMode)? onThemeModeChanged;
  const MainNavigation({super.key, this.onThemeModeChanged});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const MapPage(),
      ProfilePage(onThemeModeChanged: widget.onThemeModeChanged),
      const PlaceholderPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 18.0, left: 16, right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.map_rounded),
                    label: 'Carte',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_rounded),
                    label: 'Profil',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.star_rounded),
                    label: 'À venir',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}