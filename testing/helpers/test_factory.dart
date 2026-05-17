import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/core/domain/entities/user_entity.dart';
import 'package:clean_architecture/features/auth/data/models/requests/authentication_model.dart';
import 'package:clean_architecture/features/auth/data/models/requests/sign_up_request_model.dart';
import 'package:clean_architecture/features/auth/domain/entities/authentication_entity.dart';
import 'package:clean_architecture/features/auth/domain/entities/sign_up_entity.dart';
import 'package:faker/faker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Single helper factory for generating entities and request models in test suites.
abstract final class TestFactory {
  static UserEntity makeUserEntity() {
    return UserEntity(
      id: faker.guid.guid(),
      firstName: faker.person.firstName(),
      lastName: faker.person.lastName(),
      username: faker.internet.userName(),
      email: faker.internet.email(),
      isActive: true,
    );
  }

  static User makeUser() {
    return User(
      id: faker.guid.guid(),
      appMetadata: {},
      userMetadata: {},
      aud: faker.randomGenerator.string(5),
      createdAt: faker.date.dateTime().toIso8601String(),
    );
  }

  static UserDataEntity makeUserDataEntity() {
    return UserDataEntity(
      user: makeUserEntity(),
      accessToken: faker.jwt.valid(),
      refreshToken: faker.jwt.valid(),
    );
  }

  static AuthenticationEntity makeAuthentication() {
    return AuthenticationEntity(
      username: faker.internet.userName(),
      password: faker.internet.password(),
    );
  }

  static SignUpEntity makeSignUp() {
    return SignUpEntity(
      name: faker.person.name(),
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
  }

  static AuthenticationModel makeAuthenticationModel() {
    return AuthenticationModel(
      username: faker.internet.email(),
      password: faker.internet.password(),
    );
  }

  static SignUpRequestModel makeSignUpRequest() {
    return SignUpRequestModel(
      name: faker.person.name(),
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
  }
}
