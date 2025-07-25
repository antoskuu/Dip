import 'package:flutter/material.dart';
import '../services/user_stats_service.dart';
import '../models/user_stats.dart';
import '../app.dart';

class ProfilePage extends StatefulWidget {
  final void Function(ThemeMode)? onThemeModeChanged;
  const ProfilePage({super.key, this.onThemeModeChanged});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    _statsFuture = UserStatsService.instance.getStats();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showThemeModeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ThemeModeSheet(
        current: themeModeNotifier.value,
        onChanged: (mode) {
          widget.onThemeModeChanged?.call(mode);
          Navigator.of(context).pop();
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mon Profil',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              themeModeNotifier.value == ThemeMode.dark
                  ? Icons.dark_mode_rounded
                  : themeModeNotifier.value == ThemeMode.light
                      ? Icons.light_mode_rounded
                      : Icons.brightness_auto_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _showThemeModeSelector,
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<UserStats?>(
          valueListenable: UserStatsService.instance.statsNotifier,
          builder: (context, stats, _) {
            if (stats == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage('assets/avatar_placeholder.png'),
                  ),
                  const SizedBox(height: 16),
                  Text('Utilisateur', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  _XpLevelCard(xp: stats.xp),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatCard(
                        icon: Icons.waves,
                        label: 'Baignades',
                        value: stats.dipsCount.toString(),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _XpLevelCard extends StatelessWidget {
  final int xp;
  const _XpLevelCard({required this.xp});

  int get level => (xp / 100).floor() + 1;
  int get currentLevelXp => (level - 1) * 100;
  int get nextLevelXp => level * 100;
  double get progress => (xp - currentLevelXp) / (nextLevelXp - currentLevelXp);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Niveau $level', style: Theme.of(context).textTheme.titleLarge),
                Text('$xp XP', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$currentLevelXp XP', style: Theme.of(context).textTheme.bodySmall),
                Text('$nextLevelXp XP', style: Theme.of(context).textTheme.bodySmall),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}


class _ThemeModeSheet extends StatelessWidget {
  final ThemeMode current;
  final void Function(ThemeMode) onChanged;
  const _ThemeModeSheet({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_auto_rounded),
            title: const Text('Mode auto (système)'),
            trailing: current == ThemeMode.system ? const Icon(Icons.check, color: Colors.blue) : null,
            onTap: () => onChanged(ThemeMode.system),
          ),
          ListTile(
            leading: const Icon(Icons.light_mode_rounded),
            title: const Text('Mode clair'),
            trailing: current == ThemeMode.light ? const Icon(Icons.check, color: Colors.blue) : null,
            onTap: () => onChanged(ThemeMode.light),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_rounded),
            title: const Text('Mode sombre'),
            trailing: current == ThemeMode.dark ? const Icon(Icons.check, color: Colors.blue) : null,
            onTap: () => onChanged(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}