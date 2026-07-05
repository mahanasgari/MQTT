import 'package:intl/intl.dart';

String formatRelativeTime(String isoString) {
  final date = DateTime.tryParse(isoString);
  if (date == null) return isoString;

  final now = DateTime.now().toUtc();
  final diff = now.difference(date.toUtc());

  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('MMM d, yyyy').format(date.toLocal());
}

String formatDateTime(String isoString) {
  final date = DateTime.tryParse(isoString);
  if (date == null) return isoString;
  return DateFormat('MMM d, yyyy HH:mm').format(date.toLocal());
}
