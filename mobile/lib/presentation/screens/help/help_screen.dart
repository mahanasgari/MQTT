import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _sections = [
    _HelpSection(
      title: '1. Log in with your phone',
      steps: [
        'Open SmartPlug and enter your phone number in international format.',
        'Enter the one-time code sent to your phone.',
      ],
    ),
    _HelpSection(
      title: '2. Create a household',
      steps: [
        'From the home screen, create a household when linking your first device.',
        'Households group devices so family members can share access.',
      ],
    ),
    _HelpSection(
      title: '3. Add a device',
      steps: [
        'Wi-Fi setup: put the plug in AP mode (hold button 5 s), connect to SmartPlug-XXXX, enter home Wi-Fi and serial (e.g. SN-2026-000001).',
        'Claim code: tap + on home, choose Claim with code, enter serial and pairing token from the label.',
        'Use Get token if you only have the serial number.',
      ],
    ),
    _HelpSection(
      title: '4. Control power',
      steps: [
        'Tap a device on the home screen to open details.',
        'Use the power toggle when the device shows online.',
      ],
    ),
    _HelpSection(
      title: '5. Share access',
      steps: [
        'Open device details → Shares to invite by phone number.',
        'Choose view, control, or admin permission.',
        'Accept incoming shares from the share icon on the home screen.',
      ],
    ),
    _HelpSection(
      title: '6. Troubleshooting',
      steps: [
        'Offline device: check Wi-Fi password and that serial matches the label exactly.',
        'Registration failed: generate a new pairing token (expires in 24 hours).',
        'AP setup failed: confirm you are connected to the device SmartPlug Wi-Fi network.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.help),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.helpTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.helpSubtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/provision'),
              icon: const Icon(Icons.add),
              label: Text(l10n.addDevice),
            ),
          ),
          const SizedBox(height: 16),
          ..._sections.map(
            (section) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(
                  section.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                children: section.steps
                    .map(
                      (step) => ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: AppTheme.primary,
                        ),
                        title: Text(
                          step,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpSection {
  final String title;
  final List<String> steps;

  const _HelpSection({required this.title, required this.steps});
}
