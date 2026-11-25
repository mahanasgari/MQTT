import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import '../../../core/constants/device_endpoints.dart';
import '../../../core/network/nearby_wifi.dart';
import '../../../core/network/soft_ap_ssid.dart';
import '../../../core/network/soft_ap_wifi.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/device_models.dart';
import '../../../data/models/provisioning_models.dart';
import '../../providers/device_list_provider.dart';
import '../../providers/provisioning_provider.dart';
import '../../utils/provision_error.dart';
import '../../widgets/step_indicator.dart';

List<String> _stepLabels(AppLocalizations l10n) => [
      l10n.apStepPrepare,
      l10n.apStepSerial,
      l10n.apStepWifi,
      l10n.apStepPassword,
      l10n.apStepWait,
    ];

class ApSetupScreen extends ConsumerStatefulWidget {
  final String? initialSerial;
  final String? initialName;
  final bool wifiOnly;

  const ApSetupScreen({
    super.key,
    this.initialSerial,
    this.initialName,
    this.wifiOnly = false,
  });

  @override
  ConsumerState<ApSetupScreen> createState() => _ApSetupScreenState();
}

class _ApSetupScreenState extends ConsumerState<ApSetupScreen> {
  ApSetupStep _step = ApSetupStep.instructions;
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serialController = TextEditingController();
  final _nameController = TextEditingController();
  bool _connectingAp = false;
  bool _apReady = false;
  bool _obscurePassword = true;
  bool _scanningWifi = false;
  bool _scanningPlugs = false;
  bool _readingPlugSerial = false;
  bool _showOtherSsid = false;
  String? _homeSsid;
  String? _connectError;
  String? _scanError;
  String? _expectedSoftApTail;
  String? _selectedSoftApSsid;
  List<NearbyWifi> _wifiNetworks = const [];
  List<NearbyWifi> _plugHotspots = const [];
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    final serial = widget.initialSerial?.trim();
    if (serial != null && serial.isNotEmpty) {
      _serialController.text = serial.toUpperCase();
      _step = widget.wifiOnly
          ? ApSetupStep.pickWifi
          : ApSetupStep.enterSerialOnline;
    }
    final name = widget.initialName?.trim();
    if (name != null && name.isNotEmpty) {
      _nameController.text = name;
    }
    if (widget.wifiOnly) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _prepareWifiOnly());
    }
  }

  Future<void> _prepareWifiOnly() async {
    final serial = _serialController.text.trim().toUpperCase();
    if (serial.isEmpty) return;
    await _captureHomeSsid();
    if (!mounted) return;
    if (_ssidController.text.trim().isEmpty &&
        _homeSsid != null &&
        _homeSsid!.isNotEmpty) {
      _ssidController.text = _homeSsid!;
    }
    final name = _nameController.text.trim();
    ref.read(provisioningProvider.notifier).prepareWifiChange(
          serial: serial,
          name: name.isNotEmpty ? name : null,
        );
    if (!mounted) return;
    await _enterPickWifi();
  }

  @override
  void dispose() {
    // Fire-and-forget; never block dispose. Native side is now safe (no Wi‑Fi tear-down).
    SoftApWifi.disconnect();
    _ssidController.dispose();
    _passwordController.dispose();
    _serialController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String get _plugSsid {
    if (_selectedSoftApSsid != null && _selectedSoftApSsid!.isNotEmpty) {
      return _selectedSoftApSsid!;
    }
    final serial = ref.read(provisioningProvider).pendingSerial ??
        _serialController.text;
    return SoftApWifi.ssidFromSerial(serial);
  }

  bool get _serialValid {
    final serial = _serialController.text.trim().toUpperCase();
    if (serial.isEmpty) return false;
    final tail = _expectedSoftApTail;
    if (tail == null || tail.isEmpty) return true;
    return serialMatchesSoftApTail(serial, tail);
  }

  /// Honest step mapping: Prepare → Serial → Wi‑Fi → Password → Finish.
  int get _stepIndex {
    switch (_step) {
      case ApSetupStep.instructions:
        return 0;
      case ApSetupStep.enterSerialOnline:
        return 1;
      case ApSetupStep.pickWifi:
        return 2;
      case ApSetupStep.enterWifiCreds:
        return 3;
      case ApSetupStep.connectToAp:
      case ApSetupStep.sendingCreds:
      case ApSetupStep.waitingForDevice:
      case ApSetupStep.success:
      case ApSetupStep.failed:
        return 4;
    }
  }

  String _mapSoftApError(Object e, AppLocalizations l10n) {
    if (e is SoftApWifiException) {
      switch (e.code) {
        case SoftApWifiErrorCode.permission:
          return l10n.softApErrorPermission;
        case SoftApWifiErrorCode.unavailable:
          return l10n.softApErrorUnavailable;
        case SoftApWifiErrorCode.unsupported:
          return l10n.softApErrorUnsupported;
        case SoftApWifiErrorCode.notReachable:
          return l10n.softApErrorNotReachable;
        case SoftApWifiErrorCode.settings:
          return l10n.softApErrorSettings;
        case SoftApWifiErrorCode.unknown:
          return l10n.softApErrorUnknown;
      }
    }
    return l10n.softApErrorUnknown;
  }

  void _nextStep() {
    switch (_step) {
      case ApSetupStep.instructions:
        setState(() => _step = ApSetupStep.enterSerialOnline);
      case ApSetupStep.enterSerialOnline:
        _prepareOnline();
      case ApSetupStep.pickWifi:
        if (_ssidController.text.trim().isNotEmpty) {
          _goToWifiForm();
        }
      case ApSetupStep.enterWifiCreds:
        _goToConnectStep();
      case ApSetupStep.connectToAp:
        if (_apReady && _ssidController.text.trim().isNotEmpty) {
          _sendWifiCreds();
        } else {
          _connectThenSend();
        }
      case ApSetupStep.sendingCreds:
      case ApSetupStep.waitingForDevice:
      case ApSetupStep.success:
      case ApSetupStep.failed:
        break;
    }
  }

  ApSetupStep? _previousStep() {
    switch (_step) {
      case ApSetupStep.instructions:
        return null;
      case ApSetupStep.enterSerialOnline:
        return ApSetupStep.instructions;
      case ApSetupStep.pickWifi:
        return widget.wifiOnly
            ? (widget.initialSerial == null
                ? ApSetupStep.enterSerialOnline
                : null)
            : ApSetupStep.enterSerialOnline;
      case ApSetupStep.enterWifiCreds:
        return ApSetupStep.pickWifi;
      case ApSetupStep.connectToAp:
        return ApSetupStep.enterWifiCreds;
      case ApSetupStep.sendingCreds:
        // Token prep reuses sendingCreds UI — Back must return to serial, not SoftAP.
        if (_isPreparingPairingToken) {
          return ApSetupStep.enterSerialOnline;
        }
        return ApSetupStep.connectToAp;
      case ApSetupStep.waitingForDevice:
        return ApSetupStep.enterWifiCreds;
      case ApSetupStep.success:
        return null;
      case ApSetupStep.failed:
        final token = ref.read(provisioningProvider).pendingPairingToken;
        if (token != null || widget.wifiOnly) {
          return ApSetupStep.enterWifiCreds;
        }
        if (_serialController.text.trim().isNotEmpty) {
          return ApSetupStep.enterSerialOnline;
        }
        return ApSetupStep.instructions;
    }
  }

  void _handleBack() {
    if (_leaving) return;
    if (_step == ApSetupStep.waitingForDevice ||
        _step == ApSetupStep.sendingCreds) {
      ref.read(provisioningProvider.notifier).cancelCloudWait();
    }
    final prev = _previousStep();
    if (prev != null) {
      if (prev == ApSetupStep.enterSerialOnline ||
          prev == ApSetupStep.instructions ||
          prev == ApSetupStep.pickWifi ||
          prev == ApSetupStep.enterWifiCreds) {
        SoftApWifi.disconnect();
        _apReady = false;
        _connectingAp = false;
        _connectError = null;
      }
      ref.read(provisioningProvider.notifier).clearError();
      if (!mounted) return;
      setState(() => _step = prev);
      return;
    }
    _leaveWizard();
  }

  void _leaveWizard() {
    if (_leaving) return;
    _leaving = true;
    _connectingAp = false;
    SoftApWifi.disconnect();
    final notifier = ref.read(provisioningProvider.notifier);
    notifier.cancelCloudWait();
    notifier.reset();
    ref.read(deviceListProvider.notifier).refresh();
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  Future<void> _openRegisteredDevice(Device device) async {
    ref.read(deviceListProvider.notifier).refresh();
    setState(() => _step = ApSetupStep.success);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    if (device.householdId != null && device.householdId!.isNotEmpty) {
      context.go('/');
    } else {
      context.pushReplacement('/provision/link/${device.id}');
    }
  }

  Widget _bottomNav({
    required AppLocalizations l10n,
    required String continueLabel,
    required VoidCallback? onContinue,
  }) {
    final showBack = _previousStep() != null;
    return Row(
      children: [
        if (showBack) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: _handleBack,
              child: Text(l10n.backBtn),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: onContinue,
            child: Text(continueLabel),
          ),
        ),
      ],
    );
  }

  Future<void> _captureHomeSsid() async {
    _homeSsid ??= await SoftApWifi.currentSsid();
  }

  Future<void> _prepareOnline() async {
    final serial = _serialController.text.trim().toUpperCase();
    if (!_serialValid) return;

    setState(() => _step = ApSetupStep.sendingCreds);
    await SoftApWifi.restoreInternet(preferredSsid: _homeSsid);
    await _captureHomeSsid();
    if (!mounted) return;

    if (!await SoftApWifi.hasInternet()) {
      ref.read(provisioningProvider.notifier).setNetworkError();
      setState(() => _step = ApSetupStep.failed);
      return;
    }

    final name = _nameController.text.trim();
    if (widget.wifiOnly) {
      ref.read(provisioningProvider.notifier).prepareWifiChange(
            serial: serial,
            name: name.isNotEmpty ? name : null,
          );
      if (!mounted) return;
      await _enterPickWifi();
      return;
    }

    final ok = await ref.read(provisioningProvider.notifier).prepareApOnline(
          serial: serial,
          name: name.isNotEmpty ? name : null,
        );

    if (!mounted) return;

    if (ok) {
      await _enterPickWifi();
    } else {
      setState(() => _step = ApSetupStep.failed);
    }
  }

  void _goToWifiForm() {
    if (_ssidController.text.trim().isEmpty &&
        _homeSsid != null &&
        _homeSsid!.isNotEmpty) {
      _ssidController.text = _homeSsid!;
    }
    setState(() => _step = ApSetupStep.enterWifiCreds);
  }

  void _goToConnectStep() {
    _apReady = false;
    _connectError = null;
    setState(() => _step = ApSetupStep.connectToAp);
  }

  Future<void> _enterPickWifi() async {
    setState(() => _step = ApSetupStep.pickWifi);
    await _scanWifi();
  }

  bool get _isPreparingPairingToken =>
      !widget.wifiOnly &&
      _step == ApSetupStep.sendingCreds &&
      ref.read(provisioningProvider).pendingPairingToken == null;

  void _editWifiPassword() {
    ref.read(provisioningProvider.notifier).cancelCloudWait();
    ref.read(provisioningProvider.notifier).clearError();
    SoftApWifi.disconnect();
    _connectingAp = false;
    _apReady = false;
    _connectError = null;
    // During online token prep there is no SoftAP yet — go back to serial.
    if (_isPreparingPairingToken ||
        (!widget.wifiOnly &&
            ref.read(provisioningProvider).pendingPairingToken == null)) {
      setState(() => _step = ApSetupStep.enterSerialOnline);
      return;
    }
    _enterPickWifi();
  }

  Future<void> _scanWifi() async {
    if (_scanningWifi) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _scanningWifi = true;
      _scanError = null;
    });
    try {
      await _captureHomeSsid();
      final list = await SoftApWifi.scanNetworks();
      if (!mounted) return;
      setState(() {
        _wifiNetworks = list
            .where((n) => !n.ssid.startsWith(softApSsidPrefix))
            .toList();
        _scanningWifi = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanningWifi = false;
        _scanError = _mapSoftApError(e, l10n);
      });
    }
  }

  Future<void> _scanPlugHotspots() async {
    if (_scanningPlugs) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _scanningPlugs = true;
      _scanError = null;
      _plugHotspots = const [];
    });
    try {
      final plugs = await SoftApWifi.scanPlugHotspots();
      if (!mounted) return;
      setState(() {
        _plugHotspots = plugs;
        _scanningPlugs = false;
        if (plugs.isEmpty) {
          _scanError = l10n.noPlugHotspotFound;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanningPlugs = false;
        _scanError = _mapSoftApError(e, l10n);
      });
    }
  }

  Future<void> _selectPlugHotspot(NearbyWifi network) async {
    final l10n = AppLocalizations.of(context)!;
    final tail = softApTailFromSsid(network.ssid);
    setState(() {
      _selectedSoftApSsid = network.ssid;
      _expectedSoftApTail = tail;
      _readingPlugSerial = true;
      _scanError = null;
    });

    try {
      var info = await SoftApWifi.tryGetInfo();
      if (info == null || info.serial.trim().isEmpty) {
        await SoftApWifi.connect(network.ssid);
        for (var i = 0; i < 15; i++) {
          info = await SoftApWifi.tryGetInfo();
          if (info != null && info.serial.trim().isNotEmpty) break;
          await Future<void>.delayed(const Duration(milliseconds: 400));
        }
      }
      if (!mounted) return;
      if (info != null && info.serial.trim().isNotEmpty) {
        _serialController.text = info.serial.trim().toUpperCase();
        final infoTail = softApTailFromSsid(
          softApSsidFromSerial(_serialController.text),
        );
        _expectedSoftApTail = infoTail ?? tail;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanError = _mapSoftApError(e, l10n);
      });
    } finally {
      await SoftApWifi.disconnect();
      if (mounted) {
        setState(() => _readingPlugSerial = false);
      } else {
        _readingPlugSerial = false;
      }
    }
  }

  void _selectWifi(NearbyWifi network) {
    if (network.is5g) return;
    _ssidController.text = network.ssid;
    _passwordController.clear();
    _showOtherSsid = false;
    _goToWifiForm();
  }

  Future<bool> _ensureOnPlugAp(AppLocalizations l10n) async {
    if (_leaving) return false;
    if (await SoftApWifi.isDeviceReachable()) {
      _apReady = true;
      return true;
    }
    if (_connectingAp || _leaving) return false;
    if (!mounted) return false;
    setState(() {
      _connectingAp = true;
      _connectError = null;
    });
    try {
      await SoftApWifi.connect(_plugSsid);
      if (_leaving || !mounted) return false;
      for (var i = 0; i < 20; i++) {
        if (_leaving || !mounted) return false;
        if (await SoftApWifi.isDeviceReachable()) {
          _apReady = true;
          return true;
        }
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
      throw SoftApWifiException(
        l10n.softApErrorNotReachable,
        code: SoftApWifiErrorCode.notReachable,
      );
    } catch (e) {
      if (_leaving || !mounted) return false;
      _apReady = false;
      _connectError = _mapSoftApError(e, l10n);
      return false;
    } finally {
      _connectingAp = false;
      if (mounted && !_leaving) {
        setState(() {});
      }
    }
  }

  Future<void> _connectThenSend() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _connectError = null;
      _step = ApSetupStep.connectToAp;
    });
    final ok = await _ensureOnPlugAp(l10n);
    if (!mounted) return;
    if (ok) {
      if (_ssidController.text.trim().isNotEmpty) {
        await _sendWifiCreds();
      } else {
        await _enterPickWifi();
      }
    } else {
      setState(() => _step = ApSetupStep.connectToAp);
    }
  }

  /// SoftAP has no internet — pairing token must already exist from the online step.
  Future<bool> _ensurePairingTokenOrRestart() async {
    if (widget.wifiOnly) return true;
    final token = ref.read(provisioningProvider).pendingPairingToken;
    if (token != null && token.isNotEmpty) return true;
    await SoftApWifi.restoreInternet(preferredSsid: _homeSsid);
    _apReady = false;
    _connectingAp = false;
    ref.read(provisioningProvider.notifier).clearError();
    if (!mounted) return false;
    setState(() => _step = ApSetupStep.enterSerialOnline);
    return false;
  }

  Future<void> _sendWifiCreds() async {
    if (_leaving || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final ssid = _ssidController.text.trim();
    if (ssid.isEmpty) return;

    if (!await _ensurePairingTokenOrRestart()) return;

    setState(() => _step = ApSetupStep.sendingCreds);

    if (!await SoftApWifi.isDeviceReachable()) {
      final joined = await _ensureOnPlugAp(l10n);
      if (!mounted) return;
      if (!joined) {
        setState(() => _step = ApSetupStep.connectToAp);
        return;
      }
    }

    var sent = false;
    try {
      sent = await ref.read(provisioningProvider.notifier).sendApWifiCreds(
            ssid: ssid,
            password: _passwordController.text,
          );
    } finally {
      // Critical: leave SoftAP and wait for home Wi‑Fi/internet before cloud API.
      await SoftApWifi.restoreInternet(
        preferredSsid: _homeSsid ?? ssid,
        timeout: const Duration(seconds: 35),
      );
    }

    if (!mounted) return;

    if (!sent) {
      setState(() => _step = ApSetupStep.failed);
      return;
    }

    if (!await SoftApWifi.hasInternet()) {
      ref.read(provisioningProvider.notifier).setNetworkError();
      setState(() => _step = ApSetupStep.failed);
      return;
    }

    // H1-03: wait until the plug is online (new setup + Change Wi‑Fi).
    setState(() => _step = ApSetupStep.waitingForDevice);

    final Device? device;
    if (widget.wifiOnly) {
      device = await ref.read(provisioningProvider.notifier).waitUntilDeviceOnline(
            serial: widget.initialSerial ??
                ref.read(provisioningProvider).pendingSerial,
          );
    } else {
      device =
          await ref.read(provisioningProvider.notifier).finishApCloudRegister();
    }

    if (!mounted) return;

    if (device != null) {
      if (widget.wifiOnly) {
        setState(() => _step = ApSetupStep.success);
        await Future<void>.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        ref.read(deviceListProvider.notifier).refresh();
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      } else {
        await _openRegisteredDevice(device);
      }
    } else if (ref.read(provisioningProvider).error != null) {
      // Real timeout/fatal — not user cancel (error stays null on cancel).
      setState(() => _step = ApSetupStep.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.wifiOnly ? l10n.changeWifi : l10n.wifiSetup,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepIndicator(
                totalSteps: 5,
                currentStep: _stepIndex.clamp(0, 4),
                labels: _stepLabels(l10n),
              ),
              const SizedBox(height: 32),
              Expanded(child: _buildStepContent(l10n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(AppLocalizations l10n) {
    switch (_step) {
      case ApSetupStep.instructions:
        return _buildInstructions(l10n);
      case ApSetupStep.enterSerialOnline:
        return _buildSerialOnline(l10n);
      case ApSetupStep.connectToAp:
        return _buildConnectToAp(l10n);
      case ApSetupStep.pickWifi:
        return _buildPickWifi(l10n);
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
        _bottomNav(
          l10n: l10n,
          continueLabel: l10n.continueBtn,
          onContinue: _nextStep,
        ),
      ],
    );
  }

  Widget _buildSerialOnline(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.cloud_done_outlined, size: 40, color: AppTheme.primary),
        const SizedBox(height: 16),
        Text(
          widget.wifiOnly ? l10n.changeWifi : l10n.apSerialOnlineTitle,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          widget.wifiOnly ? l10n.changeWifiSub : l10n.apSerialOnlineBody,
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _scanningPlugs || _readingPlugSerial
              ? null
              : _scanPlugHotspots,
          icon: const Icon(Icons.wifi_tethering, size: 18),
          label: Text(l10n.findPlugHotspot),
        ),
        if (_scanningPlugs || _readingPlugSerial) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
          const SizedBox(height: 6),
          Text(
            _readingPlugSerial
                ? l10n.readingPlugSerial
                : l10n.scanningPlugHotspots,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
        if (_selectedSoftApSsid != null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.plugHotspotSelected(_selectedSoftApSsid!),
            style: TextStyle(fontSize: 13, color: Colors.blue[800]),
          ),
        ],
        if (_expectedSoftApTail != null) ...[
          const SizedBox(height: 4),
          Text(
            l10n.serialMustEndWith(_expectedSoftApTail!),
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
        if (_scanError != null && _step == ApSetupStep.enterSerialOnline) ...[
          const SizedBox(height: 8),
          Text(
            _scanError!,
            style: const TextStyle(fontSize: 13, color: AppTheme.error),
          ),
        ],
        if (_plugHotspots.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              itemCount: _plugHotspots.length,
              itemBuilder: (context, i) {
                final n = _plugHotspots[i];
                final selected = n.ssid == _selectedSoftApSsid;
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.wifi_tethering,
                    color: selected ? AppTheme.primary : Colors.grey,
                  ),
                  title: Text(n.ssid),
                  selected: selected,
                  onTap: _readingPlugSerial
                      ? null
                      : () => _selectPlugHotspot(n),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _serialController,
          decoration: InputDecoration(
            labelText: l10n.deviceSerial,
            hintText: _expectedSoftApTail != null
                ? 'SP????${_expectedSoftApTail!}'
                : 'SP0005C873',
            prefixIcon: const Icon(Icons.memory),
            errorText: _serialController.text.trim().isNotEmpty &&
                    !_serialValid &&
                    _expectedSoftApTail != null
                ? l10n.serialMustEndWith(_expectedSoftApTail!)
                : null,
          ),
          textCapitalization: TextCapitalization.characters,
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
          onSubmitted: (_) {
            if (_serialValid) _nextStep();
          },
        ),
        const Spacer(),
        _bottomNav(
          l10n: l10n,
          continueLabel: widget.wifiOnly
              ? l10n.continueBtn
              : l10n.apSerialContinue,
          onContinue: !_serialValid || _readingPlugSerial ? null : _nextStep,
        ),
      ],
    );
  }

  Widget _buildConnectToAp(AppLocalizations l10n) {
    final ssid = _plugSsid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.wifi_tethering, size: 40, color: AppTheme.primary),
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
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ssid,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.apNoPasswordHint,
                style: TextStyle(fontSize: 13, color: Colors.blue[800]),
              ),
            ],
          ),
        ),
        if (_connectingAp) ...[
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 12),
          Center(
            child: Text(
              l10n.apConnecting,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
        if (_connectError != null) ...[
          const SizedBox(height: 16),
          Text(
            _connectError!,
            style: const TextStyle(fontSize: 13, color: AppTheme.error),
          ),
        ],
        const Spacer(),
        if (!_connectingAp)
          _bottomNav(
            l10n: l10n,
            continueLabel: _apReady
                ? l10n.sendToDevice
                : l10n.apConnectInApp(ssid),
            onContinue: _nextStep,
          ),
        if (!_connectingAp) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () async {
                try {
                  await SoftApWifi.openWifiSettings();
                } catch (e) {
                  if (!mounted) return;
                  setState(() => _connectError = _mapSoftApError(e, l10n));
                }
              },
              child: Text(l10n.apOpenWifiSettings),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                if (await SoftApWifi.isDeviceReachable()) {
                  if (!mounted) return;
                  setState(() => _apReady = true);
                  if (_ssidController.text.trim().isNotEmpty) {
                    await _sendWifiCreds();
                  }
                } else {
                  if (!mounted) return;
                  setState(
                    () => _connectError = l10n.softApErrorNotReachable,
                  );
                }
              },
              child: Text(l10n.apCheckConnection),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: _editWifiPassword,
              child: Text(l10n.changeWifiPassword),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPickWifi(AppLocalizations l10n) {
    final twoG = _wifiNetworks.where((n) => n.is24g).toList();
    final fiveG = _wifiNetworks.where((n) => n.is5g).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.wifi_find, size: 40, color: AppTheme.primary),
        const SizedBox(height: 16),
        Text(
          l10n.pickWifiTitle,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.pickWifiSubtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
        ),
        if (_scanningWifi) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Text(l10n.scanningWifi, style: TextStyle(color: Colors.grey[600])),
        ],
        if (_scanError != null) ...[
          const SizedBox(height: 8),
          Text(
            _scanError!,
            style: const TextStyle(color: AppTheme.error, fontSize: 13),
          ),
        ],
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _scanWifi,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (!_scanningWifi && twoG.isEmpty && fiveG.isEmpty)
                  ListTile(
                    leading: const Icon(Icons.wifi_off),
                    title: Text(l10n.noWifiFound),
                  ),
                for (final n in twoG)
                  ListTile(
                    leading: Icon(
                      n.secure ? Icons.wifi_lock : Icons.wifi,
                      color: AppTheme.primary,
                    ),
                    title: Text(n.ssid),
                    subtitle: n.ssid == _homeSsid
                        ? Text(l10n.thisPhoneWifi)
                        : null,
                    trailing: Icon(
                      Icons.network_wifi,
                      color: n.rssi > -60
                          ? Colors.green
                          : n.rssi > -75
                              ? Colors.orange
                              : Colors.grey,
                    ),
                    onTap: () => _selectWifi(n),
                  ),
                for (final n in fiveG)
                  ListTile(
                    enabled: false,
                    leading: const Icon(Icons.wifi_off),
                    title: Text(n.ssid),
                    subtitle: Text(l10n.band5Ghz),
                  ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(l10n.otherNetwork),
                  onTap: () => setState(() => _showOtherSsid = !_showOtherSsid),
                ),
                if (_showOtherSsid) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      controller: _ssidController,
                      decoration: InputDecoration(
                        labelText: l10n.otherNetworkHint,
                        prefixIcon: const Icon(Icons.wifi),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        TextButton.icon(
          onPressed: _scanningWifi ? null : _scanWifi,
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(l10n.refreshWifi),
        ),
        _bottomNav(
          l10n: l10n,
          continueLabel: l10n.continueBtn,
          onContinue: _ssidController.text.trim().isEmpty
              ? null
              : _goToWifiForm,
        ),
      ],
    );
  }

  Widget _buildWifiCredsForm(AppLocalizations l10n) {
    final selected = _ssidController.text.trim();
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
          l10n.pickWifiSubtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Material(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          child: ListTile(
            leading: const Icon(Icons.wifi, color: AppTheme.primary),
            title: Text(
              selected.isEmpty ? l10n.wifiSsid : selected,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: TextButton(
              onPressed: _enterPickWifi,
              child: Text(l10n.edit),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: l10n.wifiPassword,
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              tooltip: _obscurePassword
                  ? l10n.showWifiPassword
                  : l10n.hideWifiPassword,
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (_ssidController.text.trim().isNotEmpty) _nextStep();
          },
        ),
        const SizedBox(height: 12),
        Text(
          l10n.wrongWifiPasswordHint,
          style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
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
              Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
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
        _bottomNav(
          l10n: l10n,
          continueLabel: l10n.connectToSendWifi,
          onContinue:
              _ssidController.text.trim().isEmpty ? null : _nextStep,
        ),
      ],
    );
  }

  Widget _buildSendingCreds(AppLocalizations l10n) {
    final preparingToken =
        !widget.wifiOnly &&
            ref.watch(provisioningProvider).pendingPairingToken == null;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            preparingToken ? l10n.preparingToken : l10n.configuringDevice,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            preparingToken ? l10n.apSerialOnlineBody : l10n.sendingCreds,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _editWifiPassword,
            icon: const Icon(Icons.wifi_password, size: 18),
            label: Text(l10n.changeWifiPassword),
          ),
          TextButton(
            onPressed: _handleBack,
            child: Text(l10n.backBtn),
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
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _editWifiPassword,
            icon: const Icon(Icons.wifi_password, size: 18),
            label: Text(l10n.changeWifiPassword),
          ),
          TextButton(
            onPressed: _handleBack,
            child: Text(l10n.backBtn),
          ),
          TextButton(
            onPressed: () {
              ref.read(provisioningProvider.notifier).cancelCloudWait();
              context.pushReplacement('/provision/claim');
            },
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
            widget.wifiOnly ? l10n.wifiSent : l10n.deviceConnected,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            widget.wifiOnly ? l10n.wifiSentBody : l10n.redirectingLink,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFailed(AppLocalizations l10n) {
    final error = ref.watch(provisioningProvider).error;
    final displayError = localizeProvisionError(error, l10n);
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
              displayError,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _editWifiPassword,
            icon: const Icon(Icons.wifi_password, size: 18),
            label: Text(l10n.changeWifiPassword),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              _apReady = false;
              _connectingAp = false;
              _connectError = null;
              await SoftApWifi.restoreInternet(preferredSsid: _homeSsid);
              if (!await _ensurePairingTokenOrRestart()) return;
              if (!mounted) return;
              setState(() => _step = ApSetupStep.connectToAp);
            },
            child: Text(l10n.apConnectInApp(_plugSsid)),
          ),
          TextButton(
            onPressed: () async {
              _apReady = false;
              _connectingAp = false;
              _connectError = null;
              await SoftApWifi.restoreInternet(preferredSsid: _homeSsid);
              if (!mounted) return;
              // Network error: go online + re-fetch token. SoftAP retry: Wi‑Fi form.
              final err = ref.read(provisioningProvider).error;
              if (err == ProvisionErrorCode.network ||
                  err == ProvisionErrorCode.missingToken ||
                  !await SoftApWifi.hasInternet()) {
                setState(() => _step = ApSetupStep.enterSerialOnline);
                return;
              }
              if (!await _ensurePairingTokenOrRestart()) return;
              if (!mounted) return;
              setState(() => _step = ApSetupStep.enterWifiCreds);
            },
            child: Text(l10n.tryAgain),
          ),
          TextButton(
            onPressed: _leaveWizard,
            child: Text(l10n.backBtn),
          ),
          TextButton(
            onPressed: () {
              SoftApWifi.disconnect();
              ref.read(provisioningProvider.notifier).reset();
              context.pushReplacement('/provision/claim');
            },
            child: Text(l10n.usePairingCode),
          ),
        ],
      ),
    );
  }
}
