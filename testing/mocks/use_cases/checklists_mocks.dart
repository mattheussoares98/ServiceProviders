import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/create_checklist_item_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/create_checklist_template_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/delete_checklist_item_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/delete_checklist_template_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/get_checklist_items_by_template_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/get_checklist_template_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/get_checklists_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/get_work_order_checklist_answers_batch_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/get_work_order_checklist_answers_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/save_checklist_response_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/update_checklist_item_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/update_checklist_template_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/watch_checklist_answers_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/watch_checklist_items_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/watch_checklist_templates_realtime_use_case.dart';

class MockGetChecklistsUseCase extends Mock implements GetChecklistsUseCase {}

class MockGetChecklistTemplateByIdUseCase extends Mock
    implements GetChecklistTemplateByIdUseCase {}

class MockCreateChecklistTemplateUseCase extends Mock
    implements CreateChecklistTemplateUseCase {}

class MockUpdateChecklistTemplateUseCase extends Mock
    implements UpdateChecklistTemplateUseCase {}

class MockDeleteChecklistTemplateUseCase extends Mock
    implements DeleteChecklistTemplateUseCase {}

class MockGetChecklistItemsByTemplateUseCase extends Mock
    implements GetChecklistItemsByTemplateUseCase {}

class MockCreateChecklistItemUseCase extends Mock
    implements CreateChecklistItemUseCase {}

class MockUpdateChecklistItemUseCase extends Mock
    implements UpdateChecklistItemUseCase {}

class MockDeleteChecklistItemUseCase extends Mock
    implements DeleteChecklistItemUseCase {}

class MockGetWorkOrderChecklistAnswersUseCase extends Mock
    implements GetWorkOrderChecklistAnswersUseCase {}

class MockSaveChecklistResponseUseCase extends Mock
    implements SaveChecklistResponseUseCase {}

class MockWatchChecklistTemplatesRealtimeUseCase extends Mock
    implements WatchChecklistTemplatesRealtimeUseCase {}

class MockWatchChecklistItemsRealtimeUseCase extends Mock
    implements WatchChecklistItemsRealtimeUseCase {}

class MockWatchChecklistAnswersRealtimeUseCase extends Mock
    implements WatchChecklistAnswersRealtimeUseCase {}

class MockGetWorkOrderChecklistAnswersBatchUseCase extends Mock
    implements GetWorkOrderChecklistAnswersBatchUseCase {}
