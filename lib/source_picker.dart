import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'l10n/app_localizations.dart';
import 'source_provider.dart';

class SourcePicker extends StatefulWidget {
  final SourceProvider provider;
  const SourcePicker({super.key, required this.provider});

  @override
  State<SourcePicker> createState() => _SourcePickerState();
}

class _SourcePickerState extends State<SourcePicker> {
  late String basePath;
  List<String> currentPath = [];
  List<FileItem> items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    basePath = widget.provider.rootPath;
    loadDirectory();
  }

  Future<void> loadDirectory() async {
    setState(() => _loading = true);

    var path = basePath;
    if (currentPath.isNotEmpty) {
      path += "/${currentPath.join("/")}";
    }

    try {
      final entities = await widget.provider.list(path);
      if (!mounted) return;

      items = entities;
      items.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      setState(() => _loading = false);
    } on FileSystemException catch (e) {
      if (!mounted) return;
      if (e.osError?.errorCode == 13) { // EACCES: permission denied
        Fluttertoast.showToast(msg: AppLocalizations.of(context)!.noFolderPermission);
        if (currentPath.isNotEmpty) {
          currentPath.removeLast();
          loadDirectory();
        } else {
          setState(() => _loading = false);
        }
      } else {
        setState(() {
          items = [];
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        items = [];
        _loading = false;
      });
    }
  }

  Widget _buildBreadcrumbs(ColorScheme colorScheme) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: currentPath.length + 1,
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.chevron_right_rounded, color: colorScheme.outlineVariant, size: 20),
        ),
        itemBuilder: (context, index) {
          final isRoot = index == 0;
          final name = isRoot ? widget.provider.rootName : currentPath[index - 1];
          final isLast = index == currentPath.length;

          return Container(
            constraints: const BoxConstraints(maxWidth: 160),
            decoration: BoxDecoration(
              color: isLast ? colorScheme.secondaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: isLast ? null : Border.all(color: colorScheme.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: isLast
                  ? null
                  : () {
                      setState(() => currentPath = currentPath.sublist(0, index));
                      loadDirectory();
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
                    color: isLast ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: currentPath.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentPath.isNotEmpty) {
          currentPath.removeLast();
          loadDirectory();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.selectFile)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBreadcrumbs(colorScheme),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.folder_open_rounded, size: 48, color: colorScheme.outlineVariant),
                              const SizedBox(height: 16),
                              Text(l10n.emptyFolder, style: TextStyle(color: colorScheme.outline)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              leading: Icon(
                                item.isDirectory ? Icons.folder_rounded : Icons.insert_drive_file_rounded,
                              ),
                              title: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                if (!item.isDirectory) return;
                                setState(() => currentPath.add(item.name));
                                loadDirectory();
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            String selectedPath;
            if (currentPath.isNotEmpty) {
              selectedPath = basePath.isEmpty
                  ? "/${currentPath.join("/")}"
                  : "$basePath/${currentPath.join("/")}";
            } else {
              selectedPath = basePath.isEmpty ? '/' : basePath;
            }
            Navigator.pop(context, selectedPath);
          },
          icon: const Icon(Icons.check_rounded),
          label: Text(l10n.select),
        ),
      ),
    );
  }
}
