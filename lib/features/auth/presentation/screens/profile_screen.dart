import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/string_ext.dart';
import '../../../../shared/models/currency_info.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../shared/widgets/finn_card.dart';
import '../../../../shared/widgets/finn_snackbar.dart';
import '../providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final session = ref.watch(appSessionProvider);
    final currency = ref.watch(selectedCurrencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          FinnCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Text(user?.name.initials ?? 'F'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Guest',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        user?.email ?? 'Sign in to sync your profile',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Chip(label: Text('Demo mode')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ToggleTile(
            title: 'Dark mode',
            value: ref.watch(themeModeProvider) == ThemeMode.dark,
            onChanged: (value) {
              ref
                  .read(appSessionProvider)
                  .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          const SizedBox(height: 12),
          _ToggleTile(
            title: 'Notifications',
            value: session.notificationsEnabled,
            onChanged: (value) {
              ref.read(appSessionProvider).setNotificationsEnabled(value);
            },
          ),
          const SizedBox(height: 12),
          _ToggleTile(
            title: 'Biometric lock',
            value: session.biometricEnabled,
            onChanged: (value) {
              ref.read(appSessionProvider).setBiometricEnabled(value);
            },
          ),
          const SizedBox(height: 12),
          FinnCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Currency',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${currency.label} (${currency.code})',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                DropdownButton<CurrencyInfo>(
                  value: currency,
                  items: CurrencyInfo.popular
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.code),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    ref.read(appSessionProvider).selectCurrency(value);
                    showFinnSnackBar(
                      context,
                      message: 'Currency updated to ${value.code}',
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () async {
              final failure = await ref
                  .read(authActionProvider.notifier)
                  .signOut();
              if (failure != null && context.mounted) {
                showFinnSnackBar(context, message: failure.message);
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      tileColor: Theme.of(context).cardTheme.color,
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
