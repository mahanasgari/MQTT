import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  List<_HelpSection> _sections(AppLocalizations l10n) => [
        _HelpSection(
          title: l10n.helpLoginTitle,
          steps: [l10n.helpLoginStep1, l10n.helpLoginStep2],
        ),
        _HelpSection(
          title: l10n.helpHouseholdTitle,
          steps: [
            l10n.helpHouseholdStep1,
            l10n.helpHouseholdStep2,
            l10n.helpHouseholdStep3,
          ],
        ),
        _HelpSection(
          title: l10n.helpAddTitle,
          steps: [
            l10n.helpAddStep1,
            l10n.helpAddStep2,
            l10n.helpAddStep3,
          ],
        ),
        _HelpSection(
          title: l10n.helpControlTitle,
          steps: [
            l10n.helpControlStep1,
            l10n.helpControlStep2,
            l10n.helpControlStep3,
            l10n.helpControlStep4,
          ],
        ),
        _HelpSection(
          title: l10n.helpShareTitle,
          steps: [
            l10n.helpShareStep1,
            l10n.helpShareStep2,
            l10n.helpShareStep3,
          ],
        ),
        _HelpSection(
          title: l10n.helpOfflineTitle,
          steps: [
            l10n.helpOfflineStep1,
            l10n.helpOfflineStep2,
            l10n.helpOfflineStep3,
          ],
        ),
        _HelpSection(
          title: l10n.helpTroubleTitle,
          steps: [
            l10n.helpTroubleStep1,
            l10n.helpTroubleStep2,
            l10n.helpTroubleStep3,
            l10n.helpTroubleStep4,
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
          ..._sections(l10n).map(
            (section) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: Icon(Icons.help_outline, color: AppTheme.primary),
                title: Text(
                  section.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                children: [
                  for (final step in section.steps)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.check_circle_outline, size: 18),
                      title: Text(step, style: const TextStyle(fontSize: 14)),
                    ),
                  const SizedBox(height: 8),
                ],
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
