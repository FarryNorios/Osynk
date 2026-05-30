import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'source_picker.dart';
import 'local_provider.dart';
import 'remote_provider.dart';
import 'o_core.dart';

enum SyncTaskPageMode { add, edit }

class SyncTaskPage extends StatefulWidget {
  final SyncTaskPageMode pageMode;
  final int? index;
  const SyncTaskPage({super.key, required this.pageMode, this.index});

  @override
  State<SyncTaskPage> createState() => _SyncTaskPageState();
}

class _SyncTaskPageState extends State<SyncTaskPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _localPathController = TextEditingController();
  final TextEditingController _remotePathController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  SyncMode mode = SyncMode.bidirectional;

  @override
  void initState() {
    super.initState();
    if (widget.pageMode == SyncTaskPageMode.edit && widget.index != null) {
      final tasks = context.read<SyncTaskRepository>().tasks;
      if (widget.index! < tasks.length) {
        final task = tasks[widget.index!];
        _nameController.text = task.name;
        _localPathController.text = task.localPath;
        _remotePathController.text = task.remotePath;
        mode = task.mode;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _localPathController.dispose();
    _remotePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageMode == SyncTaskPageMode.edit ? l10n.editTask : l10n.addTask),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.taskName),
                validator: (value) => (value == null || value.isEmpty) ? l10n.taskNameRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _localPathController,
                decoration: InputDecoration(
                  labelText: l10n.localPath,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () async {
                      if (!await Permission.manageExternalStorage.isGranted) {
                        Fluttertoast.showToast(msg: l10n.needStoragePermission);
                        await Permission.manageExternalStorage.request();
                        if (!await Permission.manageExternalStorage.isGranted) return;
                      }
                      if (!context.mounted) return;
                      final selectedPath = await Navigator.push<String?>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SourcePicker(provider: LocalSourceProvider(rootName: l10n.internalStorage)),
                        ),
                      );
                      if (!mounted) return;
                      if (selectedPath != null) {
                        _localPathController.text = selectedPath;
                        _formKey.currentState?.validate();
                      }
                    },
                  ),
                ),
                validator: (value) => (value == null || value.isEmpty) ? l10n.localPathRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remotePathController,
                decoration: InputDecoration(
                  labelText: l10n.remotePath,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () async {
                      final selectedPath = await Navigator.push<String?>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SourcePicker(provider: RemoteSourceProvider(context.read<OCore>().graphList)),
                        ),
                      );
                      if (!mounted) return;
                      if (selectedPath != null) {
                        _remotePathController.text = selectedPath;
                        _formKey.currentState?.validate();
                      }
                    },
                  ),
                ),
                validator: (value) => (value == null || value.isEmpty) ? l10n.remotePathRequired : null,
              ),
              const SizedBox(height: 24),
              SegmentedButton<SyncMode>(
                segments: [
                  ButtonSegment(value: SyncMode.bidirectional, label: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.bidirectional))),
                  ButtonSegment(value: SyncMode.upload, label: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.uploadMirror))),
                  ButtonSegment(value: SyncMode.download, label: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.downloadMirror))),
                ],
                selected: {mode},
                onSelectionChanged: (Set<SyncMode> selected) {
                  setState(() => mode = selected.first);
                },
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'save',
            icon: const Icon(Icons.save_rounded),
            label: Text(l10n.save),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(
                  context,
                  SyncTask(
                    name: _nameController.text,
                    localPath: _localPathController.text,
                    remotePath: _remotePathController.text,
                    mode: mode,
                  ),
                );
              }
            },
          ),
          if (widget.pageMode == SyncTaskPageMode.edit) ...[
            const SizedBox(height: 16),
            FloatingActionButton.extended(
              heroTag: 'delete',
              icon: const Icon(Icons.delete_rounded),
              label: Text(l10n.delete),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              onPressed: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ],
      ),
    );
  }
}
