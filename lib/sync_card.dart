import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'o_core.dart';
import 'title_card.dart';

class SyncCard extends StatelessWidget {
  const SyncCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OCore>(
      builder: (context, oCore, child) {
        final l10n = AppLocalizations.of(context)!;
        return TitleCard(
          title: l10n.sync,
          subtitle: oCore.isSyncing
              ? oCore.localizedSyncState(l10n)
              : oCore.loginStatus == LoginStatus.loading
                  ? l10n.loadingLogin
                  : l10n.syncSubtitle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: oCore.isSyncing
                ? _SyncProgressSection(oCore: oCore)
                : _SyncStartButton(oCore: oCore),
          ),
        );
      },
    );
  }
}

class _SyncStartButton extends StatelessWidget {
  final OCore oCore;
  const _SyncStartButton({required this.oCore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton.icon(
        onPressed: oCore.runAllSyncTasks,
        icon: const Icon(Icons.sync_rounded),
        label: Text(AppLocalizations.of(context)!.startSync),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        ),
      ),
    );
  }
}

class _SyncProgressSection extends StatelessWidget {
  final OCore oCore;
  const _SyncProgressSection({required this.oCore});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = oCore.syncProgress;
    final hasFiles = progress.totalFiles > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasFiles) ...[
          LinearProgressIndicator(
            value: progress.overallProgress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  progress.transferredTextFormatted(
                    (completed, total) => AppLocalizations.of(context)!.filesTransferred(completed, total),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              _SpeedBadge(speed: progress.speedText),
            ],
          ),
          const SizedBox(height: 8),
          if (progress.currentFile.isNotEmpty)
            Text(
              progress.currentFile,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: colorScheme.outline),
            ),
          const SizedBox(height: 16),
          Text(
            '${(progress.overallProgress * 100).toStringAsFixed(1)}%',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ] else ...[
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  oCore.localizedSyncState(AppLocalizations.of(context)!),
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Center(
          child: FilledButton.tonalIcon(
            onPressed: oCore.cancelRequested ? null : oCore.cancelSync,
            icon: Icon(
              oCore.cancelRequested ? Icons.hourglass_top_rounded : Icons.stop_rounded,
              size: 18,
            ),
            label: Text(
              oCore.cancelRequested
                  ? AppLocalizations.of(context)!.cancelling
                  : AppLocalizations.of(context)!.cancelSync,
            ),
            style: FilledButton.styleFrom(
              foregroundColor: colorScheme.error,
              backgroundColor: colorScheme.errorContainer,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpeedBadge extends StatelessWidget {
  final String speed;
  const _SpeedBadge({required this.speed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        speed,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
