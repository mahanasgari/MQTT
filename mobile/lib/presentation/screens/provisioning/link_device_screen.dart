import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/household_provider.dart';
import '../../providers/provisioning_provider.dart';
import '../../../data/models/household_models.dart';

class LinkDeviceScreen extends ConsumerStatefulWidget {
  final String deviceId;
  const LinkDeviceScreen({super.key, required this.deviceId});

  @override
  ConsumerState<LinkDeviceScreen> createState() => _LinkDeviceScreenState();
}

class _LinkDeviceScreenState extends ConsumerState<LinkDeviceScreen> {
  final _nameController = TextEditingController();
  String? _selectedHouseholdId;
  bool _showCreateHousehold = false;
  final _newHouseholdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _newHouseholdController.dispose();
    super.dispose();
  }

  Future<void> _handleLink() async {
    final l10n = AppLocalizations.of(context)!;
    if (_showCreateHousehold) {
      final name = _newHouseholdController.text.trim();
      if (name.isEmpty) return;
      final created = await ref
          .read(householdListProvider.notifier)
          .create(name);
      if (!mounted || !created) return;
      final households = ref.read(householdListProvider).valueOrNull ?? [];
      if (households.isNotEmpty) {
        _selectedHouseholdId = households.first.id;
      }
      setState(() => _showCreateHousehold = false);
    }

    if (_selectedHouseholdId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectHouseholdFirst),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final success = await ref
        .read(provisioningProvider.notifier)
        .linkDevice(
          _selectedHouseholdId!,
          name: name.isNotEmpty ? name : null,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.deviceLinked),
          backgroundColor: AppTheme.on,
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.read(provisioningProvider.notifier).reset();
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provState = ref.watch(provisioningProvider);
    final device = provState.registeredDevice;
    final householdsAsync = ref.watch(householdListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.linkDevice)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.power_settings_new,
                      color: AppTheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device?.displayName ?? 'Device',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        device?.serial ?? widget.deviceId,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              l10n.linkToHousehold,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            householdsAsync.when(
              data: (households) => _buildHouseholdSelector(households, l10n),
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Text(
                '${l10n.loadHouseholdsFailed}: $err',
                style: TextStyle(color: AppTheme.error),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.deviceNameOptional,
                hintText: l10n.deviceNameHint,
                prefixIcon: const Icon(Icons.edit),
              ),
            ),
            if (provState.error != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  provState.error!,
                  style: TextStyle(fontSize: 13, color: Colors.red[800]),
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: provState.isLinking ? null : _handleLink,
                child: provState.isLinking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.linkAndDone),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseholdSelector(
    List<Household> households,
    AppLocalizations l10n,
  ) {
    if (households.isEmpty) {
      return _buildCreateHouseholdForm(l10n);
    }

    if (_showCreateHousehold) {
      return _buildCreateHouseholdForm(l10n);
    }

    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selectedHouseholdId,
          decoration: InputDecoration(
            labelText: l10n.household,
            prefixIcon: const Icon(Icons.home),
          ),
          hint: Text(l10n.selectHousehold),
          items: households
              .map((h) => DropdownMenuItem(
                    value: h.id,
                    child: Text('${h.name} (${h.deviceCount})'),
                  ))
              .toList(),
          onChanged: (id) => setState(() => _selectedHouseholdId = id),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.newHousehold),
            onPressed: () => setState(() => _showCreateHousehold = true),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateHouseholdForm(AppLocalizations l10n) {
    return Column(
      children: [
        TextField(
          controller: _newHouseholdController,
          decoration: InputDecoration(
            labelText: l10n.newHouseholdName,
            hintText: l10n.newHouseholdHint,
            prefixIcon: const Icon(Icons.home),
          ),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 8),
        if (!_showCreateHousehold)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => _showCreateHousehold = false),
              child: Text(l10n.selectExisting),
            ),
          ),
      ],
    );
  }
}
