import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'models/log_localizer.dart';
import 'o_core.dart';

class SyncLogPage extends StatefulWidget {
  const SyncLogPage({super.key});

  @override
  State<SyncLogPage> createState() => _SyncLogPageState();
}

class _SyncLogPageState extends State<SyncLogPage> {
  final _scrollController = ScrollController();

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.fullLog),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: AppLocalizations.of(context)!.clearLog,
            onPressed: () => context.read<SyncLogRepository>().clear(),
          ),
        ],
      ),
      body: Consumer2<OCore, SyncLogRepository>(
        builder: (context, oCore, logRepo, child) {
          final logs = logRepo.logs.reversed.toList();

          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.article_outlined, size: 48, color: colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noLogRecords,
                    style: TextStyle(fontSize: 15, color: colorScheme.outline),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        color: oCore.isSyncing ? colorScheme.primary : colorScheme.outline,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        oCore.localizedSyncState(AppLocalizations.of(context)!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.logCount(logs.length),
                      style: TextStyle(fontSize: 12, color: colorScheme.outline),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: logs.length,
                  itemBuilder: (context, index) => LogEntryWidget(entry: logs[index]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _scrollToTop,
        tooltip: AppLocalizations.of(context)!.latestLog,
        child: const Icon(Icons.arrow_upward_rounded),
      ),
    );
  }
}

class LogEntryWidget extends StatelessWidget {
  final SyncLogEntry entry;
  final bool compact;
  const LogEntryWidget({super.key, required this.entry, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (entry.level) {
      LogLevel.success => (Icons.check_circle_rounded, colorScheme.primary),
      LogLevel.warning => (Icons.warning_rounded, colorScheme.tertiary),
      LogLevel.error => (Icons.error_rounded, colorScheme.error),
      LogLevel.info => (Icons.info_rounded, colorScheme.outline),
    };

    final l10n = AppLocalizations.of(context)!;
    final message = LogLocalizer.getMessage(entry, l10n);

    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            entry.timeText,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.outline,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
