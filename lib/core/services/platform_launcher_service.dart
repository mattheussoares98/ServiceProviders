/// Represents the outcome of an external launch or clipboard operation.
enum LauncherStatus {
  /// The operation completed successfully.
  success,

  /// The operation could not be completed (e.g. no application available,
  /// launchUrl returned false, or user cancelled).
  cannotLaunch,

  /// An unexpected exception occurred while trying to perform the operation.
  failure,
}

/// The result returned by [PlatformLauncherService] methods.
class LauncherResult {
  const LauncherResult._({required this.status, this.errorMessage});

  const LauncherResult.success() : this._(status: LauncherStatus.success);

  const LauncherResult.cannotLaunch()
    : this._(status: LauncherStatus.cannotLaunch);

  const LauncherResult.failure([String? message])
    : this._(status: LauncherStatus.failure, errorMessage: message);

  final LauncherStatus status;
  final String? errorMessage;

  bool get isSuccess => status == LauncherStatus.success;
  bool get isCannotLaunch => status == LauncherStatus.cannotLaunch;
  bool get isFailure => status == LauncherStatus.failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LauncherResult &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(status, errorMessage);

  @override
  String toString() =>
      'LauncherResult(status: $status, errorMessage: $errorMessage)';
}

/// Contract for launching external URLs and interacting with the system clipboard.
abstract interface class PlatformLauncherService {
  /// Attempts to launch the given [uri] in an external application or browser.
  Future<LauncherResult> launchExternalUri(Uri uri);

  /// Copies the provided [text] to the system clipboard.
  Future<LauncherResult> copyToClipboard(String text);
}
