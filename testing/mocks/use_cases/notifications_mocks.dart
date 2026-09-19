import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/notifications/domain/use_cases/delete_device_token_use_case.dart';
import 'package:o_jogo_da_obra/features/notifications/domain/use_cases/register_device_token_use_case.dart';

class MockRegisterDeviceTokenUseCase extends Mock
    implements RegisterDeviceTokenUseCase {}

class MockDeleteDeviceTokenUseCase extends Mock
    implements DeleteDeviceTokenUseCase {}
