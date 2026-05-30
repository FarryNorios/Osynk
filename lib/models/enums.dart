enum LoginStatus {
  loading,
  loggedOut,
  loggedIn,
}

enum SyncStatusType {
  idle,
  loading,
  notLoggedIn,
  noTasks,
  syncing,
  starting,
  uploading,
  downloading,
  completed,
  cancelled,
  failed,
}

enum ResponseStatus {
  success,
  authError,
  serverError,
  notFound,
  emptyResponse,
  timeout,
  networkError,
}

enum SyncMode {
  bidirectional(1),
  upload(2),
  download(3);

  final int value;
  const SyncMode(this.value);

  static SyncMode fromValue(int value) {
    return SyncMode.values.firstWhere(
      (m) => m.value == value,
      orElse: () => SyncMode.bidirectional,
    );
  }
}
