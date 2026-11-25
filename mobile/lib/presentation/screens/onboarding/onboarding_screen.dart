import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import '../../../core/constants/device_endpoints.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_theme.dart';

/// First-run buyer tour: plug + app only, how control works, ready CTA.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _index = 0;

  static const _pageCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish({String? nextRoute}) async {
    await SecureStorage.setOnboardingDone(true);
    // Lab / known LAN IP from .env so SoftAP→LAN→cloud works after first setup.
    final lan = deviceDefaultLanIp;
    if (lan.isNotEmpty) {
      await SecureStorage.saveDeviceLanIp('SP0005C873', lan);
    }
    if (!mounted) return;
    context.go(nextRoute ?? '/');
  }

  void _next() {
    if (_index < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      _OnboardPage(
        icon: Icons.power_settings_new_rounded,
        title: l10n.onboardWelcomeTitle,
        body: l10n.onboardWelcomeBody,
      ),
      _OnboardPage(
        icon: Icons.wifi_tethering,
        title: l10n.onboardModesTitle,
        body: l10n.onboardModesBody,
      ),
      _OnboardPage(
        icon: Icons.check_circle_outline,
        title: l10n.onboardReadyTitle,
        body: l10n.onboardReadyBody,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _finish(),
                  child: Text(l10n.skip),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => pages[i],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pageCount,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? AppTheme.primary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(
                    _index == _pageCount - 1
                        ? l10n.getStarted
                        : l10n.continueBtn,
                  ),
                ),
              ),
              if (_index == _pageCount - 1) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _finish(nextRoute: '/provision/ap-setup'),
                    child: Text(l10n.onboardSetupWifiNow),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Icon(icon, size: 56, color: AppTheme.primary),
        const SizedBox(height: 24),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          body,
          style: TextStyle(
            fontSize: 16,
            height: 1.55,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
