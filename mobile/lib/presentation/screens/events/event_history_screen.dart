import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartplug/l10n/app_localizations.dart';
import '../../providers/event_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';

class EventHistoryScreen extends ConsumerStatefulWidget {
  final String deviceId;
  const EventHistoryScreen({super.key, required this.deviceId});

  @override
  ConsumerState<EventHistoryScreen> createState() =>
      _EventHistoryScreenState();
}

class _EventHistoryScreenState extends ConsumerState<EventHistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(eventListProvider(widget.deviceId).notifier)
          .loadFirstPage();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(eventListProvider(widget.deviceId).notifier)
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(eventListProvider(widget.deviceId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.eventHistory)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Text(
                    l10n.errorPrefix(state.error!),
                    style: TextStyle(color: AppTheme.error),
                  ),
                )
              : state.events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history,
                              size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noEventsYet,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(
                            l10n.eventCount(state.total),
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding:
                                const EdgeInsets.fromLTRB(16, 4, 16, 80),
                            itemCount: state.events.length +
                                (state.isLoadingMore ? 1 : 0),
                            itemBuilder: (_, i) {
                              if (i == state.events.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                      child:
                                          CircularProgressIndicator()),
                                );
                              }
                              return _eventTile(state.events[i], l10n);
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _eventTile(dynamic event, AppLocalizations l10n) {
    IconData icon;
    Color color;
    switch (event.type) {
      case 'power_on':
        icon = Icons.power_settings_new;
        color = AppTheme.on;
        break;
      case 'power_off':
        icon = Icons.power_settings_new;
        color = AppTheme.off;
        break;
      case 'device_online':
        icon = Icons.wifi;
        color = AppTheme.online;
        break;
      case 'device_offline':
        icon = Icons.wifi_off;
        color = AppTheme.offline;
        break;
      case 'provisioned':
        icon = Icons.add_circle;
        color = AppTheme.primary;
        break;
      case 'linked':
        icon = Icons.link;
        color = AppTheme.primary;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(event.displayType),
        subtitle: Text(
          event.initiator == 'device' ? l10n.byDevice : l10n.byUser,
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: Text(
          formatRelativeTime(event.occurredAt),
          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
        ),
      ),
    );
  }
}
