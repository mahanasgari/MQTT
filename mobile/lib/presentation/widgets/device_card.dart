import 'package:flutter/material.dart';
import '../../data/models/device_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback? onTap;

  const DeviceCard({super.key, required this.device, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOn = device.state?.isOn ?? false;
    final isOnline = device.state?.isOnline ?? false;
    final lastChanged = device.state?.lastChangedAt ?? '';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOn
                      ? AppTheme.on.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.power_settings_new_rounded,
                  color: isOn ? AppTheme.on : Colors.grey[400],
                ),
              ),
              const SizedBox(width: 16),
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
                    Text(
                      device.serial,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isOnline
                          ? AppTheme.online.withValues(alpha: 0.1)
                          : AppTheme.offline.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isOnline ? AppTheme.online : AppTheme.offline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isOn ? 'ON' : 'OFF',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isOn ? AppTheme.on : AppTheme.off,
                    ),
                  ),
                  if (lastChanged.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      formatRelativeTime(lastChanged),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
