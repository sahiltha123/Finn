import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/string_ext.dart';
import '../../../../shared/models/currency_info.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../shared/providers/service_providers.dart';
import '../../../../shared/widgets/finn_card.dart';
import '../../../../shared/widgets/finn_snackbar.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final session = ref.watch(appSessionProvider);
    final currency = ref.watch(selectedCurrencyProvider);
    // Watch in build so data is ready when user taps export
    ref.watch(transactionsProvider);

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
                const Chip(label: Text('Synced')),
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
            onChanged: (value) async {
              if (value) {
                final biometricService = ref.read(biometricServiceProvider);
                final canAuth = await biometricService.canAuthenticate();
                if (!canAuth) {
                  if (context.mounted) {
                    showFinnSnackBar(
                      context,
                      message: 'Biometrics not available on this device',
                    );
                  }
                  return;
                }

                final authenticated = await biometricService.authenticate();
                if (!authenticated) return;
              }
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
          const SizedBox(height: 24),
          Text(
            'Data & Account',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          FinnCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ref.watch(transactionsProvider).when(
                      data: (transactions) => ListTile(
                        leading: const Icon(Icons.picture_as_pdf_rounded),
                        title: const Text('Export PDF Report'),
                        subtitle: const Text('Professional financial summary'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () async {
                          if (transactions.isEmpty) {
                            showFinnSnackBar(context, message: 'No transactions to export.');
                            return;
                          }
                          try {
                            final name = user?.name ?? 'Finn User';
                            final symbol = currency.symbol;
                            await ref.read(exportTransactionsPdfUseCaseProvider)(transactions, name, symbol);
                          } catch (e) {
                            if (context.mounted) {
                              showFinnSnackBar(context, message: 'PDF Export failed: $e');
                            }
                          }
                        },
                      ),
                      loading: () => const ListTile(
                        leading: Icon(Icons.picture_as_pdf_rounded),
                        title: Text('Export PDF Report'),
                        subtitle: Text('Checking transactions...'),
                        trailing: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                      ),
                      error: (err, _) => ListTile(
                        leading: const Icon(Icons.picture_as_pdf_rounded),
                        title: const Text('Export PDF Report'),
                        subtitle: const Text('Sync error'),
                        trailing: const Icon(Icons.error_outline_rounded, color: Colors.orange),
                        onTap: () => showFinnSnackBar(context, message: 'Could not sync transactions: $err'),
                      ),
                    ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.error),
                  title: Text('Sign out', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign out?'),
                        content: const Text('You can sign back in at any time.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Sign out'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed != true) return;

                    final failure = await ref.read(authActionProvider.notifier).signOut();
                    if (failure != null && context.mounted) {
                      showFinnSnackBar(context, message: failure.message);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
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
