import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import '../../providers/device_detail_provider.dart';
import '../../providers/device_control_provider.dart';
import '../../providers/ws_provider.dart';
import '../../widgets/state_badge.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';

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
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'shares', child: Text(l10n.shareAccess)),
              PopupMenuItem(
                  value: 'events', child: Text(l10n.eventHistory)),
              PopupMenuItem(value: 'rename', child: Text(l10n.rename)),
            ],
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
            _InfoTab(device: device, onRename: _showRenameDialog, l10n: l10n),
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
  final VoidCallback onRename;
  final AppLocalizations l10n;
  const _InfoTab({required this.device, required this.onRename, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final state = device.state;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoRow(l10n.nameLabel, device.displayName,
            action: TextButton(
          onPressed: onRename,
          child: Text(l10n.edit),
        )),
        _infoRow(l10n.serialNumber, device.serial),
        _infoRow(l10n.firmware, device.firmwareVersion ?? '--'),
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: isOnline && !controlState.isLoading
                  ? () => _toggle(context, ref)
                  : null,
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
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : Icon(
                          Icons.power_settings_new_rounded,
                          size: 64,
                          color: isOn ? Colors.white : Colors.grey[400],
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
            if (!isOnline) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Text(
                      l10n.offlineCannotControl,
                      style: TextStyle(
                          fontSize: 12, color: Colors.orange[800]),
                    ),
                  ],
                ),
              ),
            ],
            if (controlState.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controlState.error!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.red[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggle(BuildContext context, WidgetRef ref) async {
    final isOn = device.state?.isOn ?? false;
    final currentState = device.state;
    final success = await ref
        .read(deviceControlProvider.notifier)
        .sendCommand(deviceId, 'power', isOn ? 'off' : 'on', currentState);

    if (!context.mounted) return;

    if (success) {
      ref.read(deviceControlProvider.notifier).clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isOn ? l10n.turnedOff : l10n.turnedOn),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.toggleFailed),
          backgroundColor: AppTheme.error,
          duration: const Duration(seconds: 3),
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
