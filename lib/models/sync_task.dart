import 'enums.dart';

class SyncTask {
  final bool isEnabled;
  final String name;
  final String localPath;
  final String remotePath;
  final SyncMode mode;

  SyncTask({
    this.isEnabled = true,
    required this.name,
    required this.localPath,
    required this.remotePath,
    this.mode = SyncMode.bidirectional,
  });

  SyncTask copyWith({bool? isEnabled, String? name, String? localPath, String? remotePath, SyncMode? mode}) {
    return SyncTask(
      isEnabled: isEnabled ?? this.isEnabled,
      name: name ?? this.name,
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
      mode: mode ?? this.mode,
    );
  }

  Map<String, dynamic> toJson() => {
    'isEnabled': isEnabled,
    'name': name,
    'localPath': localPath,
    'remotePath': remotePath,
    'mode': mode.value,
  };

  factory SyncTask.fromJson(Map<String, dynamic> json) => SyncTask(
    isEnabled: json['isEnabled'] as bool? ?? true,
    name: json['name'] as String? ?? '',
    localPath: json['localPath'] as String? ?? '',
    remotePath: json['remotePath'] as String? ?? '',
    mode: SyncMode.fromValue(json['mode'] as int? ?? 1),
  );
}
