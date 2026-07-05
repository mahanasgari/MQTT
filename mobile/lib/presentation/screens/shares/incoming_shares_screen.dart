import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import '../../providers/share_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';

class IncomingSharesScreen extends ConsumerWidget {
  const IncomingSharesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sharesAsync = ref.watch(incomingShareListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.incomingShares)),
      body: sharesAsync.when(
        data: (shares) {
          final pending =
              shares.where((s) => s.status == 'pending').toList();
          if (pending.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    l10n.noPendingInvitations,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pending.length,
            itemBuilder: (_, i) => _incomingTile(context, ref, pending[i], l10n),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('$err', style: TextStyle(color: AppTheme.error)),
        ),
      ),
    );
  }

  Widget _incomingTile(
    BuildContext context,
    WidgetRef ref,
    dynamic share,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smartphone, size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.accessLabel(share.scope.toUpperCase()),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.scopeId(share.scopeId.substring(0, 8)),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                StatefulBuilder(
                  builder: (ctx, setLocalState) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          setLocalState(() {});
                          await ref
                              .read(incomingShareListProvider.notifier)
                              .decline(share.id);
                        },
                        child: Text(l10n.decline),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          setLocalState(() {});
                          await ref
                              .read(incomingShareListProvider.notifier)
                              .accept(share.id);
                        },
                        child: Text(l10n.accept),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (share.createdAt.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.sharedAgo(formatRelativeTime(share.createdAt)),
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
