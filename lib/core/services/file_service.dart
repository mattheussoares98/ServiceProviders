import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

/// A file returned by a pick operation.
///
/// [*path] is the temp/cached file path on disk — it changes every time you
/// pick the same gallery item.
/// [*name] is the stable original filename (e.g. `IMG_001.jpg`) that
/// image_picker preserves via `XFile.name`. Use this for deduplication.
typedef PickedFile = ({String path, String name});

/// Abstract service for device file I/O operations.
///
/// Lives in `core/services/` because it is a shared infrastructure concern
/// (camera, gallery, documents), potentially reused by any future feature.
/// It is NOT a repository — it does not persist data to a local/remote source.
///
/// **Note:** This service is only supported on mobile platforms (iOS & Android)
/// and will not work on Web because it depends on `dart:io` and native libraries
/// like `ffmpeg_kit`.
abstract interface class FileService {
  /// Opens the device camera and takes a single photo.
  ///
  /// Returns the temporary file path, or `null` if the user cancelled.
  Future<String?> takePhoto();

  /// Opens the device camera to record a video.
  ///
  /// Returns the temporary file path, or `null` if the user cancelled.
  Future<String?> recordVideo();

  /// Opens the gallery for multi-selection of both images and videos.
  ///
  /// Returns a list of [PickedFile] records, or `null` if the user cancelled.
  Future<List<PickedFile>?> pickMediaFromGallery();

  /// Opens the file picker for multi-document selection (PDF, DOCX, XLSX).
  ///
  /// Returns a list of [PickedFile] records, or `null` if the user cancelled.
  Future<List<PickedFile>?> pickDocuments();

  /// Compresses an image at [sourcePath] and copies the result into the
  /// app's secure sandbox directory.
  ///
  /// Applies progressive quality reduction until the output is ≤ 1 MB.
  /// Returns the absolute path of the saved compressed file.
  FutureString compressAndSaveImage(String sourcePath);

  /// Compresses a video at [sourcePath] to H.264 MP4, max 720p, ≤ 10 MB,
  /// and saves it to the app's secure sandbox directory.
  ///
  /// Returns the absolute path of the compressed file.
  FutureString compressAndSaveVideo(String sourcePath);

  /// Extracts the first frame of a video at [videoPath] and saves it as a jpeg thumbnail.
  ///
  /// Returns the absolute path of the generated thumbnail image.
  FutureString getOrCreateVideoThumbnail(String videoPath);

  /// Copies any file at [sourcePath] into the app's secure sandbox directory
  /// using [fileName] as the destination file name.
  ///
  /// Returns the absolute path of the copied file.
  FutureString copyFileToSandbox(String sourcePath, String fileName);

  /// Returns the size in bytes of the file at [path].
  Future<int> getFileSizeBytes(String path);

  /// Returns the MIME type string for the given file [path] based on extension.
  ///
  /// Example: `'image/webp'`, `'application/pdf'`.
  String getMimeType(String path);

  /// Deletes the file at [path] from the local filesystem.
  FutureBool deleteLocalFile(String path);

  /// Opens a file at [path] (either local path or remote URL).
  FutureBool openFile(String path);

  /// Resolves a local path (absolute, relative, or just filename) to an absolute
  /// path in the secure sandbox directory.
  ///
  /// Returns null if [localPath] is null or empty.
  Future<String?> resolveSandboxPath(String? localPath);
}

