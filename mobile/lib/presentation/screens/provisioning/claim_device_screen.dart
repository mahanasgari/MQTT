import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/provisioning_provider.dart';

class ClaimDeviceScreen extends ConsumerStatefulWidget {
  const ClaimDeviceScreen({super.key});

  @override
  ConsumerState<ClaimDeviceScreen> createState() => _ClaimDeviceScreenState();
}

class _ClaimDeviceScreenState extends ConsumerState<ClaimDeviceScreen> {
  final _serialController = TextEditingController();
  final _tokenController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _serialController.dispose();
    _tokenController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleGetToken() async {
    final l10n = AppLocalizations.of(context)!;
    final serial = _serialController.text.trim().toUpperCase();
    if (serial.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterSerialFirst),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final token = await ref
        .read(provisioningProvider.notifier)
        .fetchPairingToken(serial);

    if (!mounted) return;

    if (token != null) {
      _tokenController.text = token;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tokenGenerated),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleClaim() async {
    final l10n = AppLocalizations.of(context)!;
    final serial = _serialController.text.trim().toUpperCase();
    final token = _tokenController.text.trim();

    if (serial.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterSerial),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterToken),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final success = await ref
        .read(provisioningProvider.notifier)
        .claimDevice(serial, token, name: name.isNotEmpty ? name : null);

    if (!mounted) return;

    if (success) {
      final device = ref.read(provisioningProvider).registeredDevice;
      if (device != null) {
        context.pushReplacement('/provision/link/${device.id}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(provisioningProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.claimDevice)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.qr_code_scanner, size: 40, color: AppTheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.enterDeviceDetails,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.claimSubtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _serialController,
              decoration: InputDecoration(
                labelText: l10n.serialNumber,
                hintText: 'SP123456789',
                prefixIcon: const Icon(Icons.memory),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                labelText: l10n.pairingToken,
                hintText: l10n.pairingTokenHint,
                prefixIcon: const Icon(Icons.vpn_key),
                suffixIcon: TextButton(
                  onPressed: state.isClaiming ? null : _handleGetToken,
                  child: Text(l10n.getToken),
                ),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.deviceNameOptional,
                hintText: l10n.deviceNameHint,
                prefixIcon: const Icon(Icons.edit),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleClaim(),
            ),
            if (state.error != null) ...[
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
                  state.error!,
                  style: TextStyle(fontSize: 13, color: Colors.red[800]),
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: state.isClaiming ? null : _handleClaim,
                child: state.isClaiming
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.claimDeviceBtn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
