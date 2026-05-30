import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'o_core.dart';
import 'synctask_page.dart' show SyncTaskPage, SyncTaskPageMode;
import 'title_card.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TitleCard(
      title: AppLocalizations.of(context)!.syncTasks,
      subtitle: AppLocalizations.of(context)!.syncTasksSubtitle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Column(
          children: [
            Selector<SyncTaskRepository, List<SyncTask>>(
              selector: (context, repo) => repo.tasks,
              builder: (context, syncTasks, child) {
                if (syncTasks.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.noTasks,
                        style: TextStyle(fontSize: 13, color: colorScheme.outline),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: syncTasks.length,
                  itemBuilder: (context, index) {
                    final task = syncTasks[index];
                    return _TaskTile(task: task, index: index);
                  },
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SyncTaskPage(pageMode: SyncTaskPageMode.add)),
                  );
                  if (!context.mounted || result == null) return;
                  context.read<SyncTaskRepository>().add(result);
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(AppLocalizations.of(context)!.addTask),
                style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final SyncTask task;
  final int index;
  const _TaskTile({required this.task, required this.index});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: task.isEnabled
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          getModeIcon(task.mode),
          size: 20,
          color: task.isEnabled
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        task.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: task.isEnabled ? null : colorScheme.outline,
        ),
      ),
      subtitle: Text(
        getModeName(task.mode, l10n),
        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: task.isEnabled,
              onChanged: (value) {
                context.read<SyncTaskRepository>().update(index, task.copyWith(isEnabled: value));
              },
            ),
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SyncTaskPage(pageMode: SyncTaskPageMode.edit, index: index),
                ),
              );
              if (!context.mounted || result == null) return;
              if (result is String && result == 'delete') {
                context.read<SyncTaskRepository>().delete(index);
              } else if (result is SyncTask) {
                context.read<SyncTaskRepository>().update(index, result);
              }
            },
            icon: Icon(Icons.edit_rounded, size: 20, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

IconData getModeIcon(SyncMode mode) {
  return switch (mode) {
    SyncMode.upload => Icons.upload_rounded,
    SyncMode.download => Icons.download_rounded,
    _ => Icons.sync_rounded,
  };
}

String getModeName(SyncMode mode, AppLocalizations l10n) {
  return switch (mode) {
    SyncMode.upload => l10n.uploadMirror,
    SyncMode.download => l10n.downloadMirror,
    _ => l10n.bidirectional,
  };
}
