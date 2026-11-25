import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import '../../providers/household_provider.dart';
import '../../../data/models/household_models.dart';
import '../../../core/theme/app_theme.dart';

class HouseholdsScreen extends ConsumerWidget {
  const HouseholdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final householdsAsync = ref.watch(householdListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.householdsTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref, l10n),
        tooltip: l10n.newHousehold,
        child: const Icon(Icons.add),
      ),
      body: householdsAsync.when(
        data: (households) {
          if (households.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noHouseholdsYet,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.createFirstHousehold,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showCreateDialog(context, ref, l10n),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.createHousehold),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: households.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (_, i) =>
                _HouseholdTile(household: households[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  l10n.loadHouseholdsFailed,
                  style: TextStyle(color: AppTheme.error),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(householdListProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.newHousehold),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.householdNameLabel,
            hintText: l10n.newHouseholdHint,
          ),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) async {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              await ref
                  .read(householdListProvider.notifier)
                  .create(name);
              if (ctx.mounted) Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await ref
                    .read(householdListProvider.notifier)
                    .create(name);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: Text(l10n.createHousehold),
          ),
        ],
      ),
    );
  }
}

class _HouseholdTile extends ConsumerWidget {
  final Household household;
  const _HouseholdTile({required this.household});

  String _roleLabel(String? role, AppLocalizations l10n) {
    switch (role) {
      case 'admin':
        return l10n.householdRoleAdmin;
      case 'member':
        return l10n.householdRoleMember;
      default:
        return role ?? l10n.householdRoleMember;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
        child: const Icon(Icons.home_outlined, color: AppTheme.primary),
      ),
      title: Text(household.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${l10n.devicesCount(household.deviceCount)} · ${_roleLabel(household.role, l10n)}',
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      trailing: household.role == 'admin'
          ? PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'share') {
                  context.push('/household/${household.id}/shares');
                } else if (value == 'rename') {
                  _showRenameDialog(context, ref, l10n);
                } else if (value == 'delete') {
                  _showDeleteDialog(context, ref, l10n);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                    value: 'share',
                    child: Row(children: [
                      const Icon(Icons.person_add_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.shareAccess),
                    ])),
                PopupMenuItem(
                    value: 'rename',
                    child: Row(children: [
                      const Icon(Icons.edit_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.renameHousehold),
                    ])),
                PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          size: 18, color: AppTheme.error),
                      const SizedBox(width: 8),
                      Text(l10n.deleteHousehold,
                          style: TextStyle(color: AppTheme.error)),
                    ])),
              ],
            )
          : null,
    );
  }

  void _showRenameDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final controller = TextEditingController(text: household.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.renameHousehold),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.householdNameLabel),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty && name != household.name) {
                final ok = await ref
                    .read(householdListProvider.notifier)
                    .rename(household.id, name);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  if (!ok) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(l10n.renameFailed),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                  }
                }
              } else {
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    if (household.deviceCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cannotDeleteNonEmpty),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteHousehold),
        content: Text(l10n.deleteHouseholdConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              final ok = await ref
                  .read(householdListProvider.notifier)
                  .delete(household.id);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (!ok) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(l10n.deleteHouseholdFailed),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
