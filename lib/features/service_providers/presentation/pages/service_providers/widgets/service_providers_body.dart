part of './../service_providers_page.dart';

class _ServiceProvidersBody extends StatelessWidget {
  const _ServiceProvidersBody();

  @override
  Widget build(BuildContext context) {
    return BaseStateView<
      ServiceProvidersCubit,
      ServiceProvidersState,
      List<ServiceProviderCompanyEntity>
    >(
      dataSelector: (state) => state.companies,
      builder: (context, companies) {
        return ResponsiveListFlow(
          itemCount: companies.length,
          itemBuilder: (context, index) {
            final company = companies[index];
            final isSelected =
                context.read<ServiceProvidersCubit>().state.selectedCompanyId ==
                company.id;
            return Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                key: ValueKey(company.id),
                initiallyExpanded: isSelected,
                onExpansionChanged: (expanded) {
                  if (expanded) {
                    context.read<ServiceProvidersCubit>().selectCompany(
                      company.id,
                    );
                  } else {
                    context.read<ServiceProvidersCubit>().selectCompany(null);
                  }
                },
                title: BaseText.titleMedium(company.name),
                subtitle: company.contactEmail != null
                    ? BaseText.bodySmall(company.contactEmail!)
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EditServiceProviderCompanyButton(companyId: company.id),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(Sizes.p8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (company.contactPhone != null &&
                            company.contactPhone!.isNotEmpty) ...[
                          BaseText.bodyMedium(
                            'Telefone: ${company.contactPhone}'.hardcoded,
                          ),
                          gapH8,
                        ],
                        TitleAndSubtitle(
                          title: company.documentType.name.toUpperCase(),
                          subtitle: company.document,
                        ),
                        gapH8,
                        const Divider(),
                        gapH8,
                        //TODO check whether it is possible to use sliver instead
                        ServiceProvidersInvitationsItems(companyId: company.id),
                        gapH8,
                        const Divider(),
                        gapH8,
                        ServiceProvidersProfilesItems(companyId: company.id),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
