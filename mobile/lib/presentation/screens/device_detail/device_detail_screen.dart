import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../data/models/control_path.dart';
import '../../providers/device_detail_provider.dart';
import '../../providers/device_list_provider.dart';
import '../../providers/device_control_provider.dart';
import '../../providers/ws_provider.dart';
import '../../widgets/state_badge.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';

void _openChangeWifi(BuildContext context, dynamic device) {
  context.push(
    Uri(
      path: '/provision/ap-setup',
      queryParameters: {
        'serial': device.serial as String,
        'name': device.displayName as String,
        'wifiOnly': '1',
      },
    ).toString(),
  );
}

class DeviceDetailScreen extends ConsumerStatefulWidget {
  final String deviceId;
  const DeviceDetailScreen({super.key, required this.deviceId});

  @override
  ConsumerState<DeviceDetailScreen> createState() =>
      _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends ConsumerState<DeviceDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deviceDetailProvider.notifier).fetch(widget.deviceId);
      ref.read(wsProvider.notifier).subscribeToDevice(widget.deviceId);
    });
  }

  @override
  void dispose() {
    ref.read(wsProvider.notifier).unsubscribeFromDevice(widget.deviceId);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final deviceAsync = ref.watch(deviceDetailProvider);

    return Scaffold(
      appBar: AppBar(
        title: deviceAsync.whenOrNull(
          data: (d) => Text(d.displayName),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'shares') {
                context.push('/device/${widget.deviceId}/shares');
              } else if (value == 'events') {
                context.push('/device/${widget.deviceId}/events');
              } else if (value == 'rename') {
                _showRenameDialog();
              } else if (value == 'wifi') {
                final d = ref.read(deviceDetailProvider).valueOrNull;
                if (d == null) return;
                _openChangeWifi(context, d);
              } else if (value == 'remove') {
                _confirmRemove();
              }
            },
            itemBuilder: (_) {
              final role = ref.read(deviceDetailProvider).valueOrNull?.role;
              // Owner (null) or admin share can mutate; control = power only (H2-04).
              final canAdmin = role == null || role == 'admin';
              return [
                if (canAdmin)
                  PopupMenuItem(
                      value: 'shares', child: Text(l10n.shareAccess)),
                PopupMenuItem(
                    value: 'events', child: Text(l10n.eventHistory)),
                if (canAdmin)
                  PopupMenuItem(value: 'rename', child: Text(l10n.rename)),
                if (canAdmin)
                  PopupMenuItem(
                      value: 'wifi', child: Text(l10n.changeWifiPassword)),
                if (canAdmin)
                  PopupMenuItem(
                    value: 'remove',
                    child: Text(
                      l10n.removeDevice,
                      style: const TextStyle(color: AppTheme.error),
                    ),
                  ),
              ];
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.infoTab),
            Tab(text: l10n.controlTab),
            Tab(text: l10n.readingsTab),
          ],
        ),
      ),
      body: deviceAsync.when(
        data: (device) => TabBarView(
          controller: _tabController,
          children: [
            _InfoTab(
              device: device,
              onRename: (device.role == null || device.role == 'admin')
                  ? _showRenameDialog
                  : null,
              onRemove: (device.role == null || device.role == 'admin')
                  ? _confirmRemove
                  : null,
              canChangeWifi: device.role == null || device.role == 'admin',
              l10n: l10n,
            ),
            _ControlTab(device: device, deviceId: widget.deviceId, l10n: l10n),
            _ReadingsTab(device: device, l10n: l10n),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  l10n.loadDeviceFailed,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '$err',
                  style: TextStyle(color: AppTheme.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(deviceDetailProvider.notifier)
                        .fetch(widget.deviceId);
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRemove() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removeDevice),
        content: Text(l10n.removeDeviceConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final device = ref.read(deviceDetailProvider).valueOrNull;
    final removed = await ref.read(deviceListProvider.notifier).removeDevice(
          widget.deviceId,
          serial: device?.serial,
        );
    if (!mounted) return;
    if (!removed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.removeDeviceFailed)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.deviceRemoved)),
    );
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  void _showRenameDialog() {
    final l10n = AppLocalizations.of(context)!;
    final device = ref.read(deviceDetailProvider).valueOrNull;
    if (device == null) return;
    final controller =
        TextEditingController(text: device.name ?? device.serial);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.renameDevice),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.nameLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await ref
                    .read(deviceDetailProvider.notifier)
                    .updateName(name);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  final dynamic device;
  final VoidCallback? onRename;
  final VoidCallback? onRemove;
  final bool canChangeWifi;
  final AppLocalizations l10n;
  const _InfoTab({
    required this.device,
    this.onRename,
    this.onRemove,
    this.canChangeWifi = false,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final state = device.state;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoRow(
          l10n.nameLabel,
          device.displayName,
          action: onRename == null
              ? null
              : TextButton(
                  onPressed: onRename,
                  child: Text(l10n.edit),
                ),
        ),
        _infoRow(l10n.serialNumber, device.serial),
        _infoRow(l10n.firmware, device.firmwareVersion ?? '--'),
        if (canChangeWifi) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openChangeWifi(context, device),
            icon: const Icon(Icons.wifi_password, size: 18),
            label: Text(l10n.changeWifiPassword),
          ),
        ],
        if (onRemove != null) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
            label: Text(
              l10n.removeDevice,
              style: const TextStyle(color: AppTheme.error),
            ),
          ),
        ],
        if (state != null) ...[
          const Divider(height: 24),
          _infoRow(l10n.powerState, state.isOn ? l10n.powerOn : l10n.powerOff,
              valueWidget: StateBadge(
                label: state.isOn ? l10n.powerOn : l10n.powerOff,
                color: state.isOn ? AppTheme.on : AppTheme.off,
              )),
          _infoRow(l10n.connectivity, state.isOnline ? l10n.online : l10n.offline,
              valueWidget: StateBadge(
                label: state.isOnline ? l10n.online : l10n.offline,
                color: state.isOnline ? AppTheme.online : AppTheme.offline,
              )),
          if (state.lastChangedAt.isNotEmpty)
            _infoRow(
                l10n.lastChanged, formatRelativeTime(state.lastChangedAt)),
          if (state.lastSeenAt.isNotEmpty)
            _infoRow(l10n.lastSeen, formatRelativeTime(state.lastSeenAt)),
        ],
      ],
    );
  }

  Widget _infoRow(String label, String value,
      {Widget? action, Widget? valueWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ),
          Expanded(
            child: valueWidget ??
                Text(value, style: const TextStyle(fontSize: 14)),
          ),
          if (action != null) action,
        ],
      ),
    );
  }
}

class _ControlTab extends ConsumerWidget {
  final dynamic device;
  final String deviceId;
  final AppLocalizations l10n;
  const _ControlTab({required this.device, required this.deviceId, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlState = ref.watch(deviceControlProvider);
    final isOn = device.state?.isOn ?? false;
    final isOnline = device.state?.isOnline ?? false;
    final lastChanged = device.state?.lastChangedAt ?? '';
    final hasLan = (device.lanIp as String?)?.isNotEmpty == true;
    final isViewOnly = device.role == 'view';
    // Cloud-offline still allows SoftAP / LAN HTTP control.
    final canTryLocalOrCloud = !controlState.isLoading && !isViewOnly;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isViewOnly)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  l10n.permView,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            Opacity(
              opacity: isViewOnly ? 0.45 : 1.0,
              child: GestureDetector(
                onTap:
                    canTryLocalOrCloud ? () => _toggle(context, ref) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOn ? AppTheme.on : Colors.grey[200],
                    boxShadow: isOn
                        ? [
                            BoxShadow(
                              color: AppTheme.on.withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: controlState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Icon(
                            Icons.power_settings_new_rounded,
                            size: 64,
                            color: isOn ? Colors.white : Colors.grey[400],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isOn ? l10n.powerOn : l10n.powerOff,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isOn ? AppTheme.on : Colors.grey,
                  ),
            ),
            if (lastChanged.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.lastChanged} ${formatRelativeTime(lastChanged)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline ? AppTheme.online : AppTheme.offline,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isOnline ? l10n.connected : l10n.offline,
                  style: TextStyle(
                    fontSize: 13,
                    color: isOnline ? AppTheme.online : AppTheme.offline,
                  ),
                ),
              ],
            ),
            if (controlState.lastPath != null) ...[
              const SizedBox(height: 10),
              _ControlPathChip(path: controlState.lastPath!, l10n: l10n),
            ],
            const SizedBox(height: 20),
            _PreferredPathPicker(
              serial: device.serial as String,
              l10n: l10n,
            ),
            if (!isOnline && !isViewOnly) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Text(
                  hasLan
                      ? l10n.offlineControlHintHomeWifi
                      : l10n.offlineControlHintHotspot,
                  style: TextStyle(
                      fontSize: 12, color: Colors.orange[800], height: 1.4),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _openChangeWifi(context, device),
                icon: const Icon(Icons.wifi_password, size: 18),
                label: Text(l10n.changeWifiPassword),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: controlState.isLoading
                    ? null
                    : () => _toggle(context, ref),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.retry),
              ),
            ],
            if (controlState.error != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.toggleFailed,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[800]),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.controlFailedTips,
                      style: TextStyle(
                          fontSize: 12, color: Colors.red[700], height: 1.4),
                    ),
                    if (!isViewOnly) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: controlState.isLoading
                            ? null
                            : () => _toggle(context, ref),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(l10n.retry),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _localizedPath(ControlPath path) {
    switch (path) {
      case ControlPath.softAp:
        return l10n.pathSoftAp;
      case ControlPath.lan:
        return l10n.pathLan;
      case ControlPath.cloud:
        return l10n.pathCloud;
    }
  }

  void _toggle(BuildContext context, WidgetRef ref) async {
    final isOn = device.state?.isOn ?? false;
    final currentState = device.state;
    final result = await ref.read(deviceControlProvider.notifier).togglePower(
          deviceId: deviceId,
          serial: device.serial as String,
          nextPower: isOn ? 'off' : 'on',
          currentState: currentState,
          lanIp: device.lanIp as String?,
        );

    if (!context.mounted) return;

    if (result != null) {
      ref.read(deviceControlProvider.notifier).clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${isOn ? l10n.turnedOff : l10n.turnedOn} · ${_localizedPath(result.path)}',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.controlFailedTips),
          backgroundColor: AppTheme.error,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: l10n.retry,
            textColor: Colors.white,
            onPressed: () => _toggle(context, ref),
          ),
        ),
      );
    }
  }
}

class _PreferredPathPicker extends StatefulWidget {
  final String serial;
  final AppLocalizations l10n;
  const _PreferredPathPicker({required this.serial, required this.l10n});

  @override
  State<_PreferredPathPicker> createState() => _PreferredPathPickerState();
}

class _PreferredPathPickerState extends State<_PreferredPathPicker> {
  String _value = 'auto';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await SecureStorage.preferredControlPath(widget.serial);
    if (!mounted) return;
    // Default Auto = cloud-first; SoftAP is no longer the preferred path.
    setState(() => _value = (v == null || v.isEmpty) ? 'cloud' : v);
  }

  Future<void> _set(String next) async {
    setState(() => _value = next);
    await SecureStorage.savePreferredControlPath(widget.serial, next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return Column(
      children: [
        Text(
          l10n.preferredPath,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'auto', label: Text(l10n.pathAuto)),
            ButtonSegment(value: 'softAp', label: Text(l10n.pathSoftAp)),
            ButtonSegment(value: 'lan', label: Text(l10n.pathLan)),
            ButtonSegment(value: 'cloud', label: Text(l10n.pathCloud)),
          ],
          selected: {_value},
          onSelectionChanged: (s) => _set(s.first),
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}

/// A chip-style widget showing which control path (SoftAP / LAN / Cloud)
/// was used for the last successful toggle.
class _ControlPathChip extends StatelessWidget {
  final ControlPath path;
  final AppLocalizations l10n;
  const _ControlPathChip({required this.path, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (path) {
      ControlPath.softAp => (
          Icons.wifi_tethering,
          Colors.purple,
          l10n.pathSoftAp,
        ),
      ControlPath.lan => (
          Icons.router_outlined,
          AppTheme.primary,
          l10n.pathLan,
        ),
      ControlPath.cloud => (
          Icons.cloud_outlined,
          AppTheme.online,
          l10n.pathCloud,
        ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${l10n.controlVia} ',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadingsTab extends StatelessWidget {
  final dynamic device;
  final AppLocalizations l10n;
  const _ReadingsTab({required this.device, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _readingCard(Icons.bolt, l10n.voltage, '-- V'),
        const SizedBox(height: 12),
        _readingCard(Icons.electric_meter, l10n.current, '-- A'),
        const SizedBox(height: 12),
        _readingCard(Icons.speed, l10n.powerConsumption, '-- W'),
      ],
    );
  }

  Widget _readingCard(IconData icon, String label, String value) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
