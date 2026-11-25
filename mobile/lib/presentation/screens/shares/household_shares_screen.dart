import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import '../../providers/share_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/phone_validator.dart';
import '../../../data/models/share_models.dart';

/// Share an entire household (section) with another phone number.
class HouseholdSharesScreen extends ConsumerStatefulWidget {
  final String householdId;
  const HouseholdSharesScreen({super.key, required this.householdId});

  @override
  ConsumerState<HouseholdSharesScreen> createState() =>
      _HouseholdSharesScreenState();
}

class _HouseholdSharesScreenState
    extends ConsumerState<HouseholdSharesScreen> {
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
          .read(householdShareListProvider.notifier)
          .fetch(widget.householdId);
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
    final sharesAsync = ref.watch(householdShareListProvider);

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              l10n.householdSectionsHint,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          if (_showForm) _buildCreateForm(l10n),
          Expanded(
            child: sharesAsync.when(
              data: (shares) {
                if (shares.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.share,
                              size: 48, color: Colors.grey[300]),
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
                            l10n.emptyHouseholdSharesHint,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[400]),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () =>
                                setState(() => _showForm = true),
                            icon: const Icon(Icons.person_add, size: 18),
                            label: Text(l10n.shareNow),
                          ),
                        ],
                      ),
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
    final l10n = AppLocalizations.of(context)!;
    final error = formatPhoneError(phone, l10n);
    if (error != null) {
      setState(() => _phoneError = error);
      return;
    }
    setState(() => _creating = true);
    final success = await ref
        .read(householdShareListProvider.notifier)
        .create(phone, _selectedPermission);
    if (!mounted) return;
    setState(() {
      _creating = false;
      if (success) {
        _phoneController.clear();
        _showForm = false;
      }
    });
  }

  Widget _shareTile(Share share, AppLocalizations l10n) {
    final statusColor = switch (share.status) {
      'accepted' => AppTheme.on,
      'pending' => Colors.orange,
      _ => Colors.grey,
    };

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          child: Icon(Icons.home, color: AppTheme.primary, size: 20),
        ),
        title: Text(share.granteePhone),
        subtitle: Text(
          '${_permLabel(share.permission, l10n)} · ${_statusLabel(share.status, l10n)}',
          style: TextStyle(color: statusColor, fontSize: 12),
        ),
        trailing: TextButton(
          onPressed: () async {
            await ref.read(householdShareListProvider.notifier).revoke(share.id);
          },
          child: Text(l10n.revoke),
        ),
      ),
    );
  }

  String _permLabel(String permission, AppLocalizations l10n) {
    switch (permission) {
      case 'view':
        return l10n.permView;
      case 'admin':
        return l10n.permAdmin;
      case 'control':
      default:
        return l10n.permControl;
    }
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'accepted':
        return l10n.shareStatusAccepted;
      case 'revoked':
      case 'declined':
        return l10n.shareStatusRevoked;
      case 'pending':
      default:
        return l10n.shareStatusPending;
    }
  }
}
