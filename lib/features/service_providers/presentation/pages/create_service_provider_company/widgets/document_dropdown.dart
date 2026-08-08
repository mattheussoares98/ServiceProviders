part of '../create_update_service_provider_company_page.dart';

class _DocumentDropdown extends StatelessWidget {
  const _DocumentDropdown({required this.documentType});

  final ValueNotifier<DocumentType> documentType;

  @override
  Widget build(BuildContext context) {
    return BaseDropDown<DocumentType>(
      selectedItem: documentType.value,
      label: 'Tipo de documento'.hardcoded,
      items: [
        DropdownMenuItem(
          value: DocumentType.cpf,
          child: BaseText(DocumentType.cpf.name.toUpperCase().hardcoded),
        ),
        DropdownMenuItem(
          value: DocumentType.cnpj,
          child: BaseText(DocumentType.cnpj.name.toUpperCase().hardcoded),
        ),
      ],
      onChanged: (val) => documentType.value = val,
    );
  }
}
