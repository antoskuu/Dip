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

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late Future<UserStats> _statsFuture;
  late AnimationController _xpController;
  late Animation<double> _xpAnimation;

  @override
  void initState() {
    super.initState();
    _statsFuture = UserStatsService.instance.getStats();
    _xpController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _xpAnimation = CurvedAnimation(parent: _xpController, curve: Curves.easeOutBack);
    _xpController.forward();
  }

  @override
  void dispose() {
    _xpController.dispose();
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
    return FutureBuilder<UserStats>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final stats = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundImage: AssetImage('assets/avatar_placeholder.png'),
              ),
              const SizedBox(height: 16),
              Text(
                'Mon Profil',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                icon: Icon(
                  themeModeNotifier.value == ThemeMode.dark
                      ? Icons.dark_mode_rounded
                      : themeModeNotifier.value == ThemeMode.light
                          ? Icons.light_mode_rounded
                          : Icons.brightness_auto_rounded,
                ),
                label: Text(
                  themeModeNotifier.value == ThemeMode.dark
                      ? 'Mode sombre'
                      : themeModeNotifier.value == ThemeMode.light
                          ? 'Mode clair'
                          : 'Mode auto',
                ),
                onPressed: _showThemeModeSelector,
              ),
              const SizedBox(height: 18),
              AnimatedBuilder(
                animation: _xpAnimation,
                builder: (context, child) {
                  return Column(
                    children: [
                      Text(
                        'XP',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: stats.xp.toDouble()),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) => Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (stats.xp % 100) / 100,
                        minHeight: 8,
                        backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 8),
                      Text('Niveau ${(stats.xp ~/ 100) + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatCard(
                    icon: Icons.water_drop_rounded,
                    label: 'Baignades',
                    value: stats.dipsCount.toString(),
                    color: Colors.blue[400]!,
                  ),
                  _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Série défi',
                    value: stats.dailyChallengeStreak.toString(),
                    color: Colors.orange[400]!,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _BadgesSection(badges: stats.badges),
              const SizedBox(height: 24),
              _ChallengesSection(challenges: stats.dailyChallenges),
            ],
          ),
        );
      },
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

class _BadgesSection extends StatelessWidget {
  final List<String> badges;
  const _BadgesSection({required this.badges});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Badges', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        badges.isEmpty
            ? Text('Aucun badge débloqué', style: TextStyle(color: Colors.grey[400]))
            : Wrap(
                spacing: 10,
                children: badges
                    .map((b) => Chip(
                          label: Text(b),
                          backgroundColor: Colors.blue[50],
                          avatar: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 20),
                        ))
                    .toList(),
              ),
      ],
    );
  }
}

class _ChallengesSection extends StatelessWidget {
  final List<DailyChallenge> challenges;
  const _ChallengesSection({required this.challenges});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Défis du jour', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...challenges.map((c) => AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: c.completed ? Colors.green[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: c.completed ? Colors.green : Colors.blue[200]!,
                  width: 1.5,
                ),
              ),
              child: ListTile(
                leading: Icon(
                  c.completed ? Icons.check_circle_rounded : Icons.flag_rounded,
                  color: c.completed ? Colors.green : Colors.blue[400],
                ),
                title: Text(c.description),
                trailing: c.completed
                    ? const Icon(Icons.emoji_events_rounded, color: Colors.amber)
                    : null,
              ),
            )),
      ],
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