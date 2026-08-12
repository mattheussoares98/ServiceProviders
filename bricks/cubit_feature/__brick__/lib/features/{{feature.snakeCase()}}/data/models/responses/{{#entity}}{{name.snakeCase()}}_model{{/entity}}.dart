import 'package:o_jogo_da_obra/core/data/models/domain_convertible.dart';
import 'package:o_jogo_da_obra/features/{{feature.snakeCase()}}/domain/entities/test_user.dart';

{{#entity}}
class {{name.pascalCase()}} implements DomainConvertible<{{name.pascalCase()}}> {
  const {{name.pascalCase()}}({
    {{#variables}}
    required this.{{name.camelCase()}},
    {{/variables}}
  });
  
  {{#variables}}
  final {{{type}}} {{name.camelCase()}};
  {{/variables}}


  @override
  {{name.pascalCase()}} toEntity() {
    return {{name.pascalCase()}}(
      {{#variables}}
      {{name.camelCase()}}: {{name.camelCase()}},
      {{/variables}}
    );
  }
}
{{/entity}}