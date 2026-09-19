import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/delete_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/get_attachments_batch_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/get_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/pick_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/upload_attachment_use_case.dart';

class MockPickAttachmentUseCase extends Mock implements PickAttachmentUseCase {}

class MockUploadAttachmentUseCase extends Mock
    implements UploadAttachmentUseCase {}

class MockGetAttachmentsUseCase extends Mock implements GetAttachmentsUseCase {}

class MockDeleteAttachmentUseCase extends Mock
    implements DeleteAttachmentUseCase {}

class MockGetAttachmentsBatchUseCase extends Mock
    implements GetAttachmentsBatchUseCase {}
