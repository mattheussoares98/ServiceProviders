import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/config/injector/injector.config.dart';

@InjectableInit(initializerName: 'initialize')
Future<void> configureDependencies({String? environment}) =>
    GetIt.I.initialize(environment: environment);
