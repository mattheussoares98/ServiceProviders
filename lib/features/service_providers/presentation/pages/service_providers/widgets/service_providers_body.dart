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
      onRetry: () => context
          .read<ServiceProvidersCubit>()
          .loadCompaniesAndProfiles(forceRefresh: true),
      dataSelector: (state) => state.companies,
      builder: (context, companies) {
        return ResponsiveListFlow(
          itemCount: companies.length,
          itemBuilder: (context, index) {
            final company = companies[index];
            final isSelected =
                context.read<ServiceProvidersCubit>().state.selectedCompanyId ==
                company.id;
            final isEnabled =
                company.invitationStatus ==
                ServiceProviderInvitationStatus.accepted;
            return Card(
              clipBehavior: .hardEdge,
              child: Theme(
                data: context.theme.copyWith(
                  disabledColor: context.theme.textTheme.bodyMedium?.color,
                ),
                child: ExpansionTile(
                  key: ValueKey(company.id),
                  childrenPadding: isEnabled ? null : EdgeInsets.zero,
                  initiallyExpanded: isSelected,
                  trailing: isEnabled ? null : const SizedBox.shrink(),
                  enabled: isEnabled,
                  onExpansionChanged: (expanded) {
                    if (expanded) {
                      context.read<ServiceProvidersCubit>().selectCompany(
                        company.id,
                        emitLoading: false,
                      );
                    } else {
                      context.read<ServiceProvidersCubit>().selectCompany(null);
                    }
                  },
                  title: BaseText.titleMedium(company.name),
                  subtitle: ServiceProviderCompanySubtitle(company: company),
                  leading: EditServiceProviderCompanyButton(
                    companyId: company.id,
                  ),
                  children: [
                    ServiceProvidersInvitationsItems(company: company),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
