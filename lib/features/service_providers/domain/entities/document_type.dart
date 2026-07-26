enum DocumentType {
  cpf,
  cnpj;

  static DocumentType fromName(String name) => switch (name) {
    'cpf' => DocumentType.cpf,
    'cnpj' => DocumentType.cnpj,
    _ => throw Exception('Document type not found'),
  };
}
