# Attachments — Implementation Plan

## Overview

This document defines the full step-by-step plan to implement the attachment feature for work orders. The feature allows technicians to:

- **Take photos** directly with the camera
- **Pick images** from the device gallery
- **Attach documents** — PDF, Word (`.docx`), Excel (`.xlsx`)

The upload strategy follows the **AWS/Cloudflare R2 Presigned URL pattern**, which is the industry standard for secure, client-side file uploads to object storage without exposing credentials in the app.

---

## Presigned URL Pattern (AWS Standard)

This is the upload flow used by Amazon S3, Cloudflare R2, Google Cloud Storage, and all major cloud storage providers.

```
┌─────────────────────────────────────────────────────────────┐
│  WHY PRESIGNED URLS?                                        │
│                                                             │
│  • Never expose storage credentials to the client app       │
│  • Upload goes directly from device → R2 (no proxy server)  │
│  • Each URL is scoped to one file and expires (e.g. 15 min) │
│  • Works offline-first: local save first, upload when online │
└─────────────────────────────────────────────────────────────┘
```

### Upload Sequence

```
┌──────────────┐     1. Request presigned URL      ┌──────────────────┐
│  Flutter App  │ ──────────────────────────────►  │  Supabase Edge   │
│               │                                   │  Function        │
│               │ ◄──── 2. Return { uploadUrl,      │  (generate_url)  │
│               │                   fileKey }       └──────────────────┘
│               │                                          │
│               │     3. PUT file bytes directly           │ Signs request
│               │ ──────────────────────────────►          ▼
│               │         to uploadUrl              ┌──────────────────┐
│               │                                   │  Cloudflare R2   │
│               │ ◄──── 4. 200 OK                   │  Object Storage  │
│               │                                   └──────────────────┘
│               │
│               │     5. Confirm upload (PATCH)     ┌──────────────────┐
│               │ ──────────────────────────────►   │  Supabase DB     │
│               │ ◄──── 6. remoteUrl saved           │  (attachments)   │
└──────────────┘                                   └──────────────────┘
```

### Object Key Convention

R2/S3 keys follow a hierarchical path. Ours will be:

```
attachments/{company_id}/{work_order_id}/{uuid}.{extension}
```

**Example:**
```
attachments/abc-corp/wo-123/a1b2c3d4.webp
attachments/abc-corp/wo-123/a1b2c3d4.pdf
```

This allows future RLS-style bucket policies per company without any database changes.

---

## File Type Support & Rules

| Type | Extensions | MIME Types | Max Size | Compressible? |
|---|---|---|---|---|
| **Image** | `.jpg`, `.jpeg`, `.png`, `.webp`, `.heic` | `image/*` | 20 MB (original) | Yes — compressed to WebP ≤ 1 MB |
| **Video** | `.mp4`, `.mov` | `video/*` | 100 MB (original) | Yes — compressed to MP4 ≤ 10 MB (max 30s) |
| **PDF** | `.pdf` | `application/pdf` | **10 MB** | No |
| **Word** | `.docx` | `application/vnd.openxmlformats-officedocument.wordprocessingml.document` | **5 MB** | No |
| **Excel** | `.xlsx` | `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` | **5 MB** | No |

> [!NOTE]
> **Why these file types?** PDF, Word, Excel, images, and videos cover 95%+ of real-world CMMS maintenance documents (reports, checklists, visual evidence, parts lists). Allowing arbitrary files (e.g. `.exe`, `.zip`) is a security risk.

> [!IMPORTANT]
> Images and videos are the only file types that are compressed locally. Other file types (PDF, Word, Excel) must be rejected if they exceed the size limits.

### Web Compatibility Warning

> [!WARNING]
> The current `FileService` implementation relies on `dart:io` and native libraries (`ffmpeg_kit_flutter_min`, `flutter_image_compress`). As a result, it is **mobile-only** (iOS & Android) and will not compile/run on Web devices.
>
> For Web compatibility in future versions, picking must use HTML file inputs, and compression/handling must be adjusted to run in a web-compatible environment (or performed server-side).

---

## Image Compression Strategy

Images are compressed **before** being saved to the local sandbox, using `flutter_image_compress`.

### Compression Rules

| Original Size | Target Output | Max Dimension | Quality | Format |
|---|---|---|---|---|
| Any | ≤ 1 MB | 1920px (longest side) | 80 | WebP |

### Algorithm

```
1. Get original file size
2. If size <= 1 MB AND already WebP/JPEG → skip compression
3. Else:
   a. Decode image dimensions
   b. Calculate resize factor so longest side ≤ 1920px
   c. Compress with quality=80, format=WebP
   d. If result > 1 MB → retry with quality=65
   e. If still > 1 MB → retry with quality=50, maxDimension=1280
   f. If still > 1 MB → reject: "Imagem muito grande para comprimir"
4. Save compressed bytes to app sandbox
5. Set isCompressed = true on AttachmentEntity
```

> [!NOTE]
> HEIC (iPhone format) is automatically decoded by `flutter_image_compress` before compression. No special handling needed in the app.

---

## Packages to Add

```yaml
dependencies:
  flutter_image_compress: ^2.3.0   # Image compression (camera + gallery)
  file_picker: ^9.0.0              # Document picker (PDF, DOCX, XLSX)
  open_filex: ^4.6.0               # Open attachment previews natively
  # image_picker already in pubspec.yaml
  # path_provider already in pubspec.yaml
  # permission_handler already in pubspec.yaml
```

---

## Implementation Steps

### Step 1 — Add Packages

Add `flutter_image_compress`, `file_picker`, and `open_filex` to `pubspec.yaml`.

**Platform setup required:**

**iOS (`Info.plist`):**
```xml
<key>NSCameraUsageDescription</key>
<string>Necessário para fotografar documentos e equipamentos nas ordens de serviço.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Necessário para selecionar fotos da galeria para ordens de serviço.</string>
```

**Android (`AndroidManifest.xml`):**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

---

### Step 2 — Core: File Service (Domain Layer)

Create a domain service interface for file operations. This is **not a repository** — it abstracts device I/O.

**File:** `lib/core/services/file_service.dart`

```dart
// Abstract interface — no DI annotation (injected via impl)
abstract interface class FileService {
  Future<String?> pickImageFromGallery();
  Future<String?> takePhoto();
  Future<String?> pickDocument();
  FutureString compressAndSaveImage(String sourcePath);
  FutureString copyFileToSandbox(String sourcePath, String fileName);
  Future<int> getFileSizeBytes(String path);
  String getMimeType(String path);
  FutureBool deleteLocalFile(String path);
}
```

**File:** `lib/core/services/file_service_impl.dart`

```dart
@LazySingleton(as: FileService)
final class FileServiceImpl implements FileService { ... }
```

> [!IMPORTANT]
> `FileService` lives in `lib/core/services/`, not inside the attachments feature. File I/O is shared infrastructure — it may be reused by user avatar upload, signature capture, etc.

---

### Step 3 — File Size Validation (Domain Layer)

**File:** `lib/features/attachments/domain/value_objects/attachment_file_validator.dart`

```dart
sealed class AttachmentValidationResult { ... }
final class AttachmentValid extends AttachmentValidationResult { ... }
final class AttachmentInvalidSize extends AttachmentValidationResult {
  final int maxBytes;
  final int actualBytes;
}
final class AttachmentInvalidType extends AttachmentValidationResult {
  final String extension;
}

abstract final class AttachmentFileValidator {
  static const _maxImageBytes    = 20 * 1024 * 1024; // 20 MB
  static const _maxPdfBytes      = 10 * 1024 * 1024; // 10 MB
  static const _maxDocumentBytes =  5 * 1024 * 1024; //  5 MB

  static const _allowedExtensions = {
    'jpg', 'jpeg', 'png', 'webp', 'heic',
    'pdf', 'docx', 'xlsx',
  };

  static AttachmentValidationResult validate(String extension, int sizeBytes) {
    final ext = extension.toLowerCase();
    if (!_allowedExtensions.contains(ext)) return AttachmentInvalidType(extension: ext);
    final maxBytes = switch (ext) {
      'pdf'  => _maxPdfBytes,
      'docx' || 'xlsx' => _maxDocumentBytes,
      _ => _maxImageBytes,
    };
    if (sizeBytes > maxBytes) return AttachmentInvalidSize(maxBytes: maxBytes, actualBytes: sizeBytes);
    return const AttachmentValid();
  }
}
```

---

### Step 4 — Expand `FileType` Enum

Add `spreadsheet` and a `fromExtension` factory.

**File:** `lib/features/attachments/domain/entities/file_type.dart`

```dart
enum FileType {
  image('image'),
  pdf('pdf'),
  document('document'),
  spreadsheet('spreadsheet'), // NEW: Excel .xlsx
  signature('signature');

  ...

  static FileType fromExtension(String ext) => switch (ext.toLowerCase()) {
    'jpg' || 'jpeg' || 'png' || 'webp' || 'heic' => FileType.image,
    'pdf'  => FileType.pdf,
    'docx' => FileType.document,
    'xlsx' => FileType.spreadsheet,
    _      => FileType.document,
  };
}
```

---

### Step 5 — Add `UploadStatus.uploading`

The cubit needs an intermediate state for in-progress uploads.

**File:** `lib/features/attachments/domain/entities/upload_status.dart`

```dart
enum UploadStatus {
  pending('pending'),
  uploading('uploading'),  // NEW: actively uploading to R2
  uploaded('uploaded'),
  failed('failed');
  ...
}
```

---

### Step 6 — Storage Client (Core Infrastructure)

**File:** `lib/core/clients/remote/storage/storage_client.dart`

```dart
abstract interface class StorageClient {
  Future<PresignedUrlResponse> getPresignedUploadUrl(String objectKey);
  FutureString uploadFile({
    required String presignedUrl,
    required String filePath,
    required String mimeType,
  });
}

class PresignedUrlResponse {
  const PresignedUrlResponse({required this.uploadUrl, required this.fileKey});
  final String uploadUrl;
  final String fileKey;
}
```

**File:** `lib/core/clients/remote/storage/r2_storage_client.dart`

```dart
@LazySingleton(as: StorageClient)
final class R2StorageClient implements StorageClient { ... }
```

> [!NOTE]
> The presigned URL is generated by a Supabase Edge Function. The Flutter app never holds R2 credentials.

---

### Step 7 — Remote Data Source: Upload

Expand `AttachmentsRemoteDataSource` with upload methods.

```dart
abstract interface class AttachmentsRemoteDataSource {
  FutureData<PresignedUrlResponse> getPresignedUploadUrl({
    required String companyId,
    required String workOrderId,
    required String fileName,
    required String extension,
  });
  FutureBool confirmUpload({required String attachmentId, required String remoteUrl});
  FutureList<AttachmentResponseModel> getAttachmentsByWorkOrder(String workOrderId);
}
```

---

### Step 8 — Domain Repository: Add Upload Method

**File:** `lib/features/attachments/domain/repositories/attachments_repository.dart`

```dart
enum AttachmentSource { camera, gallery, document }

abstract interface class AttachmentsRepository {
  FutureList<AttachmentEntity> getAttachmentsByWorkOrder(String workOrderId);
  FutureBool createAttachment(AttachmentEntity attachment);
  FutureBool deleteAttachment(String id);

  // Picks a file, validates, compresses (if image), saves locally.
  // Returns the new AttachmentEntity with uploadStatus: pending.
  FutureData<AttachmentEntity> pickAndPrepareAttachment({
    required AttachmentSource source,
    required String workOrderId,
    required String companyId,
    required String uploadedById,
  });

  // Uploads a pending attachment to R2 and updates remoteUrl in local DB.
  FutureBool uploadPendingAttachment(AttachmentEntity attachment);
}
```

---

### Step 9 — New Use Cases

All in `lib/features/attachments/domain/use_cases/`:

| File | Class | Implements |
|---|---|---|
| `pick_attachment_use_case.dart` | `PickAttachmentUseCase` | `UseCase<AttachmentEntity, PickAttachmentParams>` |
| `upload_attachment_use_case.dart` | `UploadAttachmentUseCase` | `UseCase<bool, AttachmentEntity>` |
| `open_attachment_use_case.dart` | `OpenAttachmentUseCase` | `UseCase<void, AttachmentEntity>` |

`PickAttachmentParams` is a simple class holding `source`, `workOrderId`, `companyId`, `uploadedById`.

---

### Step 10 — Cubit & State

**File:** `lib/features/attachments/presentation/cubits/attachments/attachments_state.dart`

```dart
class AttachmentsState extends BaseState {
  const AttachmentsState({
    required super.status,
    this.attachments = const [],
    this.uploadingIds = const {},
    super.errorMessage,
  });

  const AttachmentsState.empty() : this(status: StateStatus.initial);

  final List<AttachmentEntity> attachments;
  final Set<String> uploadingIds;  // tracks which items show a progress indicator

  @override
  List<Object?> get props => [status, attachments, uploadingIds, errorMessage];
}
```

**File:** `lib/features/attachments/presentation/cubits/attachments/attachments_cubit.dart`

```dart
@injectable
class AttachmentsCubit extends BaseCubit<AttachmentsState> {
  Future<void> init(String workOrderId) { ... }
  Future<void> pickFromCamera() { ... }
  Future<void> pickFromGallery() { ... }
  Future<void> pickDocument() { ... }
  Future<void> deleteAttachment(String id) { ... }
  Future<void> openAttachment(AttachmentEntity attachment) { ... }
}
```

**File:** `lib/features/attachments/presentation/cubits/attachments/attachments_cubit_use_cases.dart`

```dart
@LazySingleton()
class AttachmentsCubitUseCases {
  const AttachmentsCubitUseCases({
    required this.getAttachments,
    required this.pickAttachment,
    required this.uploadAttachment,
    required this.deleteAttachment,
    required this.openAttachment,
  });

  final GetAttachmentsUseCase getAttachments;
  final PickAttachmentUseCase pickAttachment;
  final UploadAttachmentUseCase uploadAttachment;
  final DeleteAttachmentUseCase deleteAttachment;
  final OpenAttachmentUseCase openAttachment;
}
```

---

### Step 11 — UI Widgets

#### `AttachmentSourceSheet` (bottom sheet)

Displayed when user taps "Adicionar Anexo". Four options:

| Option | Icon | Label |
|---|---|---|
| Camera photo | `Icons.camera_alt_outlined` | Tirar foto (1 foto por vez) |
| Camera video | `Icons.videocam_outlined` | Gravar vídeo (máx. 30s) |
| Gallery | `Icons.photo_library_outlined` | Galeria — fotos e vídeos (multi-seleção) |
| Document | `Icons.attach_file_outlined` | Selecionar arquivo (multi-seleção) |

#### `Attachments` widget (main)

Renders the full attachment list for a work order. States:

| State | UI |
|---|---|
| Loading | Shimmer placeholders |
| Empty | "Nenhum anexo ainda" + add button |
| Has items | Image grid + document list rows |
| Item uploading | Circular progress overlay on item |
| Error | Snackbar with retry |

#### `AttachmentItem` widget

| File Type | Preview |
|---|---|
| Image | `CachedNetworkImage` (remote) / `Image.file` (local) |
| PDF | PDF icon + file name + size badge |
| Document/Spreadsheet | Office icon + file name + size badge |

---

### Step 12 — Error Messages (pt-BR)

| Code | Message |
|---|---|
| `file_too_large_image` | `"Imagem muito grande. O máximo é 20 MB."` |
| `file_too_large_pdf` | `"PDF muito grande. O máximo é 10 MB."` |
| `file_too_large_document` | `"Documento muito grande. O máximo é 5 MB."` |
| `invalid_file_type` | `"Tipo de arquivo não suportado: .{ext}"` |
| `compression_failed` | `"Não foi possível comprimir a imagem. Tente uma foto menor."` |
| `upload_failed` | `"Falha no envio. O arquivo foi salvo localmente e será enviado quando houver conexão."` |
| `permission_denied` | `"Permissão negada. Acesse Configurações para permitir o acesso à câmera/galeria."` |

---

### Step 13 — Supabase Edge Function

A Supabase Edge Function (`generate_presigned_url`) generates a time-limited presigned URL for R2. The function:

1. Validates the caller's JWT
2. Validates `company_id` ownership
3. Generates a presigned PUT URL using the R2 SDK
4. Returns `{ uploadUrl, fileKey }`

> [!CAUTION]
> This function must **never** run without a valid JWT. R2 credentials live only as Supabase secrets, never in the Flutter app or the database. See [database.md](file:/.agents/rules/database.md) for the Edge Function implementation pattern.

---

### Step 14 — Tests

Follow the [QA Agent rules](file:/.agents/rules/quality_assurance.md). Create:

| Test File | What to test |
|---|---|
| `test/features/attachments/domain/use_cases/use_cases_test.dart` | All use cases: pick, upload, delete, open |
| `test/features/attachments/data/data_sources/attachments_remote_data_source_test.dart` | Presigned URL request, confirm upload |
| `test/features/attachments/data/data_sources/attachments_local_data_source_test.dart` | Save, get, soft-delete |
| `test/features/attachments/data/repositories/attachments_repository_test.dart` | Online/offline routing |
| `test/features/attachments/presentation/cubits/attachments_cubit_test.dart` | State emissions for all flows |
| `test/core/services/file_service_test.dart` | Compression logic edge cases |

**Critical compression test scenarios:**
- Image ≤ 1 MB → skip compression, `isCompressed = false`
- Image 5 MB → compressed to ≤ 1 MB, `isCompressed = true`
- Image 22 MB → rejected before compression attempt
- HEIC image → decoded and compressed successfully
- PDF exactly at 10 MB → `AttachmentValid`
- PDF at 10 MB + 1 byte → `AttachmentInvalidSize`
- Unsupported extension `.zip` → `AttachmentInvalidType`

---

## Execution Order

```
[ ] 1.  Add packages to pubspec.yaml
[ ] 2.  Configure iOS Info.plist + Android manifest permissions
[ ] 3.  Create FileService interface + FileServiceImpl (core/services/)
[ ] 4.  Create StorageClient interface + R2StorageClient (core/clients/remote/storage/)
[ ] 5.  Create AttachmentFileValidator value object
[ ] 6.  Expand FileType enum (add spreadsheet + fromExtension)
[ ] 7.  Expand UploadStatus enum (add uploading)
[ ] 8.  Expand AttachmentsRemoteDataSource + Impl (upload methods)
[ ] 9.  Expand AttachmentsRepository interface + Impl
[ ] 10. Create PickAttachmentUseCase
[ ] 11. Create UploadAttachmentUseCase
[ ] 12. Create OpenAttachmentUseCase
[ ] 13. Create AttachmentsCubitUseCases
[ ] 14. Implement AttachmentsCubit + AttachmentsState
[ ] 15. Build AttachmentSourceSheet widget (bottom sheet)
[ ] 16. Build AttachmentItem widget (image / document row)
[ ] 17. Build Attachments widget (list + states)
[ ] 18. Integrate Attachments widget into work order detail page
[ ] 19. Deploy Supabase Edge Function (generate_presigned_url)
[ ] 20. Write all tests (QA Agent)
```

---

## Resolved Decisions

| Decision | Resolution |
|---|---|
| **Upload timing** | Upload immediately to R2 when internet is available. Save locally **only** as an offline fallback. No sync queue involved for attachments. |
| **Multiple file selection** | Fully supported. Camera picks one at a time (OS limitation). Gallery and document picker support multi-select. Each file is validated, compressed, and uploaded independently. |
| **Closed work orders** | New attachments on closed work orders are routed to `work_order_change_requests` — see [architecture.md](file:///Users/mattheus/Development/Projects/ServiceProviders/docs/cmms/architecture.md). |

### Upload Strategy Detail

```
User picks file(s)
        │
        ▼
  Validate + compress each file
        │
        ▼
  Internet available?
   ├── YES → Upload directly to R2 via presigned URL
   │              → Save remoteUrl to Supabase
   │              → Save locally (localPath + remoteUrl, status: uploaded)
   └── NO  → Save locally only (localPath, status: pending)
                  → Show "Será enviado quando houver conexão" badge
                  → On next app launch with internet, upload pending items
```

> [!NOTE]
> The local database is the **fallback**, not the primary path. When online, the file goes to R2 first, and the local record is saved last with the final `remoteUrl`. This avoids a double-save problem and keeps the offline path simple.
