import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/device_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../providers/device_control_provider.dart';
import 'package:smartplug/l10n/app_localizations.dart';

class DeviceCard extends ConsumerWidget {
  final Device device;
  final VoidCallback? onTap;
  /// Optional quick-toggle callback from the parent.  When provided, a power
  /// control is shown on the card so the user can toggle without navigating
  /// to the detail screen.
  final VoidCallback? onToggle;

  const DeviceCard({
    super.key,
    required this.device,
    this.onTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isOn = device.state?.isOn ?? false;
    final isOnline = device.state?.isOnline ?? false;
    final lastChanged = device.state?.lastChangedAt ?? '';
    final controlState = ref.watch(deviceControlProvider);
    final isThisDevicePending =
        controlState.isLoading && controlState.pendingDeviceId == device.id;
    // H2-09: lock every card switch while any toggle is in flight.
    final anyTogglePending = controlState.isLoading;

    final sharedRole = device.role;
    final isShared = sharedRole != null;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOn
                      ? AppTheme.on.withValues(alpha: 0.12)
                      : Colors.grey.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.power_settings_new_rounded,
                  color: isOn ? AppTheme.on : Colors.grey[400],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isOnline ? AppTheme.online : AppTheme.offline,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isOnline ? l10n.online : l10n.offline,
                            style: TextStyle(
                              fontSize: 13,
                              color: isOnline
                                  ? AppTheme.online
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (lastChanged.isNotEmpty) ...[
                          Text(
                            ' · ',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[400]),
                          ),
                          Flexible(
                            child: Text(
                              formatRelativeTime(lastChanged),
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isShared) ...[
                      const SizedBox(height: 6),
                      _SharedBadge(role: sharedRole, l10n: l10n),
                    ],
                  ],
                ),
              ),
              if (isThisDevicePending)
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (onToggle != null)
                // Absorb tap so the card InkWell does not open detail.
                GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: Switch.adaptive(
                    value: isOn,
                    onChanged: (isThisDevicePending || anyTogglePending)
                        ? null
                        : (_) => onToggle?.call(),
                  ),
                )
              else
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _SharedBadge extends StatelessWidget {
  final String role;
  final AppLocalizations l10n;
  const _SharedBadge({required this.role, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.share_outlined,
              size: 11, color: Colors.indigo.shade700),
          const SizedBox(width: 3),
          Text(
            _roleLabel(role, l10n),
            style: TextStyle(
                fontSize: 10,
                color: Colors.indigo.shade700,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role, AppLocalizations l10n) {
    switch (role) {
      case 'view':
        return l10n.permView;
      case 'admin':
        return l10n.permAdmin;
      case 'control':
      default:
        return l10n.sharedWithYou;
    }
  }
}
