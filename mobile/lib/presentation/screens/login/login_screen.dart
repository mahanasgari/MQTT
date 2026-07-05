import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ws_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/phone_validator.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _otpFocus = FocusNode();

  bool _showOtpStep = false;
  String? _phoneError;
  String? _error;
  bool _loading = false;
  int _countdown = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _phoneFocus.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _startCountdown(int seconds) {
    setState(() => _countdown = seconds);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_countdown > 0) _countdown--;
      });
      return _countdown > 0;
    });
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    final error = formatPhoneError(phone);
    if (error != null) {
      setState(() => _phoneError = error);
      return;
    }
    setState(() {
      _phoneError = null;
      _error = null;
      _loading = true;
    });

    final result = await ref.read(authProvider.notifier).sendOtp(phone);
    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _showOtpStep = true;
        _loading = false;
      });
      _startCountdown(result.retryAfterSeconds ?? 60);
      Future.delayed(const Duration(milliseconds: 100), () {
        _otpFocus.requestFocus();
      });
    } else {
      final errMsg = result.error ?? 'Failed to send code';
      setState(() {
        _loading = false;
        _error = errMsg;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errMsg), backgroundColor: Colors.red[700]),
        );
      }
    }
  }

  Future<void> _handleVerifyOtp() async {
    final code = _otpController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Enter the verification code');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });

    final phone = _phoneController.text.trim();
    final success = await ref.read(authProvider.notifier).verifyOtp(phone, code);
    if (!mounted) return;

    if (success) {
      ref.read(wsProvider.notifier).reconnectAfterLogin();
    } else {
      setState(() {
        _loading = false;
        _error = ref.read(authProvider).error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.power_settings_new_rounded,
                  size: 48,
                  color: AppTheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _showOtpStep ? 'Enter the verification code' : 'Sign in with your phone number',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 32),

                if (_error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: AppTheme.error, fontSize: 14),
                    ),
                  ),

                if (!_showOtpStep) ..._buildPhoneStep(l10n),
                if (_showOtpStep) ..._buildOtpStep(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPhoneStep(AppLocalizations l10n) {
    return [
      TextField(
        controller: _phoneController,
        focusNode: _phoneFocus,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: l10n.phoneLabel,
          hintText: l10n.phoneHint,
          errorText: _phoneError,
          prefixIcon: const Icon(Icons.phone),
        ),
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _handleSendOtp(),
        onChanged: (_) => setState(() => _phoneError = null),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _loading ? null : _handleSendOtp,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.sendOtp),
        ),
      ),
    ];
  }

  List<Widget> _buildOtpStep(AppLocalizations l10n) {
    return [
      Text(
        'Code sent to ${_phoneController.text.trim()}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _otpController,
        focusNode: _otpFocus,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: InputDecoration(
          labelText: l10n.otpLabel,
          hintText: '123456',
          counterText: '',
          prefixIcon: const Icon(Icons.smartphone),
        ),
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _handleVerifyOtp(),
        onChanged: (_) => setState(() => _error = null),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _loading ? null : _handleVerifyOtp,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.verify),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => setState(() {
              _showOtpStep = false;
              _error = null;
              _otpController.clear();
            }),
            child: const Text('Change number'),
          ),
          if (_countdown > 0)
            Text(
              'Resend in ${_countdown}s',
              style: TextStyle(color: Colors.grey[400]),
            )
          else
            TextButton(
              onPressed: _loading ? null : _handleSendOtp,
              child: const Text('Resend code'),
            ),
        ],
      ),
    ];
  }
}
