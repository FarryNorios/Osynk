import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'o_core.dart';
import 'sync_log_page.dart';
import 'title_card.dart';

class LogCard extends StatelessWidget {
  const LogCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer2<OCore, SyncLogRepository>(
      builder: (context, oCore, logRepo, child) {
        final logs = logRepo.logs.reversed.take(3).toList();
        final l10n = AppLocalizations.of(context)!;

        return TitleCard(
          title: l10n.log,
          subtitle: l10n.logSubtitle,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SyncLogPage()),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SyncStateIndicator(
                  syncState: oCore.localizedSyncState(l10n),
                  isActive: oCore.isSyncing,
                ),
                const SizedBox(height: 12),
                if (logs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        l10n.noLogs,
                        style: TextStyle(fontSize: 13, color: colorScheme.outline),
                      ),
                    ),
                  )
                else
                  ...logs.map((e) => LogEntryWidget(entry: e, compact: true)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SyncStateIndicator extends StatelessWidget {
  final String syncState;
  final bool isActive;
  const SyncStateIndicator({super.key, required this.syncState, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? colorScheme.primary : colorScheme.outline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              syncState,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
