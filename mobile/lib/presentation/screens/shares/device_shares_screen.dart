import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import '../../providers/share_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/phone_validator.dart';

class DeviceSharesScreen extends ConsumerStatefulWidget {
  final String deviceId;
  const DeviceSharesScreen({super.key, required this.deviceId});

  @override
  ConsumerState<DeviceSharesScreen> createState() =>
      _DeviceSharesScreenState();
}

class _DeviceSharesScreenState extends ConsumerState<DeviceSharesScreen> {
  final _phoneController = TextEditingController();
  String? _phoneError;
  String _selectedPermission = 'control';
  bool _showForm = false;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(deviceShareListProvider.notifier)
          .fetch(widget.deviceId);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sharesAsync = ref.watch(deviceShareListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shareAccess),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.person_add),
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showForm) _buildCreateForm(l10n),
          Expanded(
            child: sharesAsync.when(
              data: (shares) {
                if (shares.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.share, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noSharesYet,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.tapToShare,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: shares.length,
                  itemBuilder: (_, i) => _shareTile(shares[i], l10n),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('$err',
                    style: TextStyle(color: AppTheme.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateForm(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.phoneLabel,
              hintText: l10n.phoneHint,
              errorText: _phoneError,
              isDense: true,
            ),
            onChanged: (_) => setState(() => _phoneError = null),
          ),
          const SizedBox(height: 12),
          Text(l10n.permission,
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Row(
            children: [
              _permissionChip('view', l10n.permView),
              const SizedBox(width: 8),
              _permissionChip('control', l10n.permControl),
              const SizedBox(width: 8),
              _permissionChip('admin', l10n.permAdmin),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _creating ? null : _handleCreate,
              child: _creating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.addShare),
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionChip(String value, String label) {
    final selected = _selectedPermission == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedPermission = value),
    );
  }

  Future<void> _handleCreate() async {
    final phone = _phoneController.text.trim();
    final error = formatPhoneError(phone);
    if (error != null) {
      setState(() => _phoneError = error);
      return;
    }
    setState(() => _creating = true);
    final success = await ref
        .read(deviceShareListProvider.notifier)
        .create(phone, _selectedPermission);
    if (!mounted) return;
    if (success) {
      setState(() {
        _phoneController.clear();
        _showForm = false;
        _creating = false;
      });
    } else {
      setState(() => _creating = false);
    }
  }

  Widget _shareTile(dynamic share, AppLocalizations l10n) {
    final statusColor = switch (share.status) {
      'accepted' => AppTheme.on,
      'pending' => Colors.orange,
      'declined' || 'revoked' => Colors.grey,
      _ => Colors.grey,
    };

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          child: Text(
            share.granteePhone.isNotEmpty
                ? share.granteePhone[share.granteePhone.length - 4]
                : '?',
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(share.granteePhone),
        subtitle: Text(
          '${share.permission.toUpperCase()} · ${share.status.toUpperCase()}',
          style: TextStyle(color: statusColor, fontSize: 12),
        ),
        trailing: share.status == 'pending'
            ? TextButton(
                onPressed: () => _confirmRevoke(share.id, l10n),
                child: Text(l10n.revoke),
              )
            : null,
      ),
    );
  }

  void _confirmRevoke(String id, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.revokeShareTitle),
        content: Text(l10n.revokeShareBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(deviceShareListProvider.notifier)
                  .revoke(id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style:
                FilledButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text(l10n.revoke),
          ),
        ],
      ),
    );
  }
}
