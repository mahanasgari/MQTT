import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/household_provider.dart';
import '../../providers/device_list_provider.dart';
import '../../providers/device_control_provider.dart';
import '../../providers/ws_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/device_card.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/device_models.dart';
import '../../../routes/app_route_observer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with RouteAware {
  String? _selectedHouseholdId;
  String _searchQuery = '';
  ModalRoute<void>? _subscribedRoute;

  List<Device> _visibleDevices(List<Device> devices) {
    final q = _searchQuery.trim().toLowerCase();
    Iterable<Device> list = devices;
    // H2-05: only show devices that belong to the selected household.
    if (_selectedHouseholdId != null) {
      list = list.where((d) => d.householdId == _selectedHouseholdId);
    }
    if (q.isNotEmpty) {
      list = list.where((d) {
        final name = (d.name ?? '').toLowerCase();
        return name.contains(q) || d.serial.toLowerCase().contains(q);
      });
    }
    final sorted = list.toList()
      ..sort((a, b) {
        final aOnline = a.state?.isOnline == true;
        final bOnline = b.state?.isOnline == true;
        if (aOnline != bOnline) return aOnline ? -1 : 1;
        final aLabel = (a.name ?? a.serial).toLowerCase();
        final bLabel = (b.name ?? b.serial).toLowerCase();
        return aLabel.compareTo(bLabel);
      });
    return sorted;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!await SecureStorage.onboardingDone) {
        if (mounted) context.go('/onboarding');
        return;
      }
      ref.read(householdListProvider.notifier).refresh();
      ref.read(deviceListProvider.notifier).fetch();
      ref.read(wsProvider.notifier).connect();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route != _subscribedRoute) {
      if (_subscribedRoute != null) {
        appRouteObserver.unsubscribe(this);
      }
      appRouteObserver.subscribe(this, route);
      _subscribedRoute = route;
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    ref.read(deviceListProvider.notifier).refresh();
    ref.read(householdListProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final householdsAsync = ref.watch(householdListProvider);
    final devicesAsync = ref.watch(deviceListProvider);
    final isOffline = ref.watch(deviceListIsOfflineProvider);
    final wsState = ref.watch(wsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/provision'),
        tooltip: l10n.addDevice,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (wsState.isConnected)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.wifi, size: 18, color: AppTheme.online),
            ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            tooltip: l10n.incomingShares,
            onPressed: () => context.push('/shares/incoming'),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => context.push('/help'),
            tooltip: l10n.help,
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                ref.read(wsProvider.notifier).disconnect();
                ref.read(authProvider.notifier).logout();
              } else if (value == 'en' || value == 'fa') {
                ref.read(localeProvider.notifier).setLocale(Locale(value));
              } else if (value == 'onboarding') {
                await SecureStorage.setOnboardingDone(false);
                if (context.mounted) context.go('/onboarding');
              } else if (value == 'incoming') {
                context.push('/shares/incoming');
              } else if (value == 'households') {
                context.push('/households');
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'phone',
                enabled: false,
                child: Text(auth.phone ?? '',
                    style: const TextStyle(color: Colors.grey)),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'households',
                child: Text(l10n.manageHouseholds),
              ),
              PopupMenuItem(
                value: 'incoming',
                child: Text(l10n.incomingShares),
              ),
              PopupMenuItem(
                value: 'onboarding',
                child: Text(l10n.helpTitle),
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
          if (isOffline)
            Container(
              width: double.infinity,
              color: Colors.amber.shade50,
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.offlineBannerTitle,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          l10n.offlineBannerBody,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(deviceListProvider.notifier).refresh(),
                    child: Text(l10n.retry),
                  ),
                  TextButton(
                    onPressed: () => context.push('/help'),
                    child: Text(l10n.offlineBannerHelp),
                  ),
                ],
              ),
            ),
          if (householdsAsync.hasValue)
            ...switch (householdsAsync.value!) {
              final households when households.isNotEmpty => [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.household,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        isDense: true,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: _selectedHouseholdId,
                          isDense: true,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text(l10n.allDevices),
                            ),
                            ...households.map(
                              (h) => DropdownMenuItem(
                                value: h.id,
                                child: Text(
                                    '${h.name} (${h.deviceCount})'),
                              ),
                            ),
                          ],
                          onChanged: (id) {
                            setState(() => _selectedHouseholdId = id);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              _ => [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/households'),
                      icon: const Icon(Icons.home_work_outlined, size: 18),
                      label: Text(l10n.createFirstHousehold),
                    ),
                  ),
                ],
            },
          if (devicesAsync.hasValue && devicesAsync.value!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.deviceSearchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.search,
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(deviceListProvider.notifier).refresh();
              },
              child: devicesAsync.when(
                data: (devices) {
                  final visible = _visibleDevices(devices);
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
                                  l10n.noDevices,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: Colors.grey[500]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isOffline
                                      ? l10n.noDevicesOfflineHint
                                      : l10n.emptyDevicesHint,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey[400]),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      context.push('/provision'),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: Text(l10n.addDevice),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  if (visible.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: Center(
                            child: Text(
                              l10n.deviceSearchEmpty,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: visible.length + 1,
                    itemBuilder: (_, i) {
                      if (i == visible.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 80),
                          child: TextButton.icon(
                            onPressed: () => context.push('/provision'),
                            icon: const Icon(Icons.add),
                            label: Text(l10n.addAnotherDevice),
                          ),
                        );
                      }
                      final d = visible[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DeviceCard(
                          device: d,
                          onTap: () => context.push('/device/${d.id}'),
                          onToggle: d.role == 'view'
                              ? null
                              : () => _quickToggle(d, l10n),
                        ),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.loadDevicesFailed,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.error),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(deviceListProvider.notifier)
                              .fetch(),
                          child: Text(l10n.retry),
                        ),
                      ],
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

  Future<void> _quickToggle(Device device, AppLocalizations l10n) async {
    final next = (device.state?.isOn ?? false) ? 'off' : 'on';
    final result = await ref.read(deviceControlProvider.notifier).togglePower(
          deviceId: device.id,
          serial: device.serial,
          nextPower: next,
          currentState: device.state,
          lanIp: device.lanIp,
        );
    if (!mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.controlFailedTips)),
      );
    }
  }
}
