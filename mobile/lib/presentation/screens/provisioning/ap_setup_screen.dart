import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/provisioning_models.dart';
import '../../providers/provisioning_provider.dart';
import '../../widgets/step_indicator.dart';

List<String> _stepLabels(AppLocalizations l10n) => [
      l10n.apStepPrepare,
      l10n.apStepConnect,
      l10n.apStepWifi,
      l10n.apStepWait,
    ];

class ApSetupScreen extends ConsumerStatefulWidget {
  const ApSetupScreen({super.key});

  @override
  ConsumerState<ApSetupScreen> createState() => _ApSetupScreenState();
}

class _ApSetupScreenState extends ConsumerState<ApSetupScreen> {
  ApSetupStep _step = ApSetupStep.instructions;
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serialController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    _serialController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  int get _stepIndex {
    switch (_step) {
      case ApSetupStep.instructions:
        return 0;
      case ApSetupStep.connectToAp:
        return 1;
      case ApSetupStep.enterWifiCreds:
        return 2;
      case ApSetupStep.sendingCreds:
      case ApSetupStep.waitingForDevice:
        return 3;
      case ApSetupStep.success:
      case ApSetupStep.failed:
        return 4;
    }
  }

  void _nextStep() {
    setState(() {
      switch (_step) {
        case ApSetupStep.instructions:
          _step = ApSetupStep.connectToAp;
          break;
        case ApSetupStep.connectToAp:
          _step = ApSetupStep.enterWifiCreds;
          break;
        case ApSetupStep.enterWifiCreds:
          _sendWifiCreds();
          break;
        case ApSetupStep.sendingCreds:
          break;
        case ApSetupStep.waitingForDevice:
          break;
        case ApSetupStep.success:
        case ApSetupStep.failed:
          break;
      }
    });
  }

  void _sendWifiCreds() async {
    final ssid = _ssidController.text.trim();
    final serial = _serialController.text.trim().toUpperCase();
    if (ssid.isEmpty || serial.isEmpty) return;

    setState(() => _step = ApSetupStep.sendingCreds);

    final name = _nameController.text.trim();
    final device = await ref.read(provisioningProvider.notifier).startApProvisioning(
          ssid: ssid,
          password: _passwordController.text,
          serial: serial,
          name: name.isNotEmpty ? name : null,
        );

    if (!mounted) return;

    if (device != null) {
      setState(() => _step = ApSetupStep.success);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      context.pushReplacement('/provision/link/${device.id}');
    } else {
      setState(() => _step = ApSetupStep.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.wifiSetup)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepIndicator(
              totalSteps: 4,
              currentStep: _stepIndex.clamp(0, 3),
              labels: _stepLabels(l10n),
            ),
            const SizedBox(height: 32),
            Expanded(child: _buildStepContent(l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(AppLocalizations l10n) {
    switch (_step) {
      case ApSetupStep.instructions:
        return _buildInstructions(l10n);
      case ApSetupStep.connectToAp:
        return _buildConnectToAp(l10n);
      case ApSetupStep.enterWifiCreds:
        return _buildWifiCredsForm(l10n);
      case ApSetupStep.sendingCreds:
        return _buildSendingCreds(l10n);
      case ApSetupStep.waitingForDevice:
        return _buildWaiting(l10n);
      case ApSetupStep.success:
        return _buildSuccess(l10n);
      case ApSetupStep.failed:
        return _buildFailed(l10n);
    }
  }

  Widget _buildInstructions(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 40, color: AppTheme.primary),
        const SizedBox(height: 16),
        Text(
          l10n.apPrepareTitle,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.apPrepare1,
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.apPrepare2,
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.apPrepare3,
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextStep,
            child: Text(l10n.continueBtn),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectToAp(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.wifi, size: 40, color: AppTheme.primary),
        const SizedBox(height: 16),
        Text(
          l10n.apConnectTitle,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.apConnectBody,
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 18, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.apNoPasswordHint,
                  style: TextStyle(fontSize: 13, color: Colors.blue[800]),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextStep,
            child: Text(l10n.apConnected),
          ),
        ),
      ],
    );
  }

  Widget _buildWifiCredsForm(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.wifi_password, size: 40, color: AppTheme.primary),
        const SizedBox(height: 16),
        Text(
          l10n.apWifiTitle,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.apWifiSubtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _ssidController,
          decoration: InputDecoration(
            labelText: l10n.wifiSsid,
            prefixIcon: const Icon(Icons.wifi),
          ),
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.wifiPassword,
            prefixIcon: const Icon(Icons.lock),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _serialController,
          decoration: InputDecoration(
            labelText: l10n.deviceSerial,
            hintText: 'SN-2026-000001',
            prefixIcon: const Icon(Icons.memory),
          ),
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
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
          onSubmitted: (_) => _nextStep(),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline,
                  size: 16, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.apCredsHint,
                  style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _ssidController.text.trim().isEmpty ||
                    _serialController.text.trim().isEmpty
                ? null
                : _nextStep,
            child: Text(l10n.sendToDevice),
          ),
        ),
      ],
    );
  }

  Widget _buildSendingCreds(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            l10n.configuringDevice,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.sendingCreds,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildWaiting(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.waitingForDevice,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.deviceWillAppear,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.pushReplacement('/provision/claim'),
            child: Text(l10n.claimInstead),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 64, color: AppTheme.on),
          const SizedBox(height: 16),
          Text(
            l10n.deviceConnected,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.redirectingLink,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFailed(AppLocalizations l10n) {
    final error = ref.watch(provisioningProvider).error;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text(
            l10n.setupFailed,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error ?? l10n.setupFailedDefault,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(provisioningProvider.notifier).clearError();
                setState(() => _step = ApSetupStep.instructions);
              },
              child: Text(l10n.tryAgain),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.pushReplacement('/provision/claim'),
            child: Text(l10n.usePairingCode),
          ),
        ],
      ),
    );
  }
}
