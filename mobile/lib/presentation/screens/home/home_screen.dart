import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/household_provider.dart';
import '../../providers/device_list_provider.dart';
import '../../providers/ws_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/device_card.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedHouseholdId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(householdListProvider.notifier).refresh();
      ref.read(deviceListProvider.notifier).fetch();
      ref.read(wsProvider.notifier).connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final householdsAsync = ref.watch(householdListProvider);
    final devicesAsync = ref.watch(deviceListProvider);
    final wsState = ref.watch(wsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/provision'),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (wsState.isConnected)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.wifi, size: 18, color: AppTheme.online),
            ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => context.push('/help'),
            tooltip: l10n.help,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(wsProvider.notifier).disconnect();
                ref.read(authProvider.notifier).logout();
              } else if (value == 'en' || value == 'fa') {
                ref.read(localeProvider.notifier).setLocale(Locale(value));
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'phone',
                enabled: false,
                child: Text(auth.phone ?? '', style: const TextStyle(color: Colors.grey)),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'en',
                child: Text(l10n.languageEn),
              ),
              PopupMenuItem(
                value: 'fa',
                child: Text(l10n.languageFa),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.logout),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (householdsAsync.hasValue)
            ...switch (householdsAsync.value!) {
              final households when households.isNotEmpty => [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Household',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedHouseholdId,
                        isDense: true,
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All devices'),
                          ),
                          ...households.map((h) => DropdownMenuItem(
                            value: h.id,
                            child: Text('${h.name} (${h.deviceCount})'),
                          )),
                        ],
                        onChanged: (id) {
                          setState(() => _selectedHouseholdId = id);
                          ref.read(deviceListProvider.notifier).fetch(householdId: id);
                        },
                      ),
                    ),
                  ),
                ),
              ],
              _ => [],
            },
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(deviceListProvider.notifier).refresh();
              },
              child: devicesAsync.when(
                data: (devices) {
                  if (devices.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.power_off_outlined,
                                    size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 12),
                                Text(
                                  'No devices yet',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: Colors.grey[500]),
                                ),
                const SizedBox(height: 4),
                Text(
                  'Add a device to get started',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[400]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/provision'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Device'),
                ),
              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: devices.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DeviceCard(
                        device: devices[i],
                        onTap: () => context.push('/device/${devices[i].id}'),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Failed to load devices: $err',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.error),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
