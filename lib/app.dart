import 'package:flutter/material.dart';
import 'pages/map_page.dart';
import 'pages/profile_page.dart';
import 'pages/placeholder_page.dart';

final ColorScheme dipColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF2196F3),
  primary: const Color(0xFF2196F3),
  secondary: const Color(0xFF64B5F6),
  surface: const Color(0xFFE3F2FD),
  background: const Color(0xFFF7F9FB),
  onPrimary: Colors.white,
  onSecondary: Colors.white,
  onSurface: const Color(0xFF0D47A1),
  onBackground: const Color(0xFF1976D2),
  brightness: Brightness.light,
);

final ColorScheme dipDarkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF0D47A1),
  primary: const Color(0xFF1976D2),
  secondary: const Color(0xFF64B5F6),
  surface: const Color(0xFF102840),
  background: const Color(0xFF0A1929),
  onPrimary: Colors.white,
  onSecondary: Colors.white,
  onSurface: Colors.white,
  onBackground: Colors.white,
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
            scaffoldBackgroundColor: dipColorScheme.background,
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
              backgroundColor: Colors.white.withOpacity(0.95),
              selectedItemColor: dipColorScheme.primary,
              unselectedItemColor: dipColorScheme.secondary,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
            ),
            sliderTheme: SliderThemeData(
              activeTrackColor: dipColorScheme.primary,
              inactiveTrackColor: dipColorScheme.secondary.withOpacity(0.3),
              thumbColor: dipColorScheme.primary,
              overlayColor: dipColorScheme.primary.withOpacity(0.1),
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
            scaffoldBackgroundColor: dipDarkColorScheme.background,
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
              backgroundColor: dipDarkColorScheme.surface.withOpacity(0.95),
              selectedItemColor: dipDarkColorScheme.primary,
              unselectedItemColor: dipDarkColorScheme.secondary,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
            ),
            sliderTheme: SliderThemeData(
              activeTrackColor: dipDarkColorScheme.primary,
              inactiveTrackColor: dipDarkColorScheme.secondary.withOpacity(0.3),
              thumbColor: dipDarkColorScheme.primary,
              overlayColor: dipDarkColorScheme.primary.withOpacity(0.1),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 18.0, left: 16, right: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            elevation: 8,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.secondary,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
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
    );
  }
}