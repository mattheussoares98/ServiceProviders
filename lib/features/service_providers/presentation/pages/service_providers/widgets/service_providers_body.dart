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

            final invitations = context
                .read<ServiceProvidersCubit>()
                .state
                .invitations;
            final hasPendingInvitation =
                invitations[company.id]?.any(
                  (inv) =>
                      inv.serviceProviderCompanyId == company.id &&
                      inv.status == ServiceProviderInvitationStatus.pending,
                ) ??
                false;
            final isLoadingCompany = context
                .select<ServiceProvidersCubit, bool>(
                  (cubit) => cubit.state.loadingCompanyIds.contains(company.id),
                );

            return Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                key: ValueKey(company.id),
                initiallyExpanded: isSelected,
                enabled:
                    company.invitationStatus ==
                    ServiceProviderInvitationStatus.accepted,
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
                subtitle: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .stretch,
                  children: [
                    if (company.contactEmail?.isNotEmpty ?? false)
                      Row(
                        children: [
                          Expanded(
                            child: BaseText.bodySmall(company.contactEmail!),
                          ),
                          if (company.invitationStatus == null)
                            BaseTextButton(
                              text: 'Convidar'.hardcoded,
                              platformIcon: const PlatformIcon(
                                materialIcon: Icons.mail,
                                cupertinoIcon: CupertinoIcons.mail,
                              ),
                              onPressed: () {
                                showAlertDialog(
                                  context: context,
                                  title: 'Enviar convite'.hardcoded,
                                  contentText:
                                      'Deseja enviar o convite para ${company.contactEmail}?'
                                          .hardcoded,
                                  defaultActionText: 'Sim'.hardcoded,
                                  cancelActionText: 'Não'.hardcoded,
                                  onOkPressed: () {
                                    //TODO send invitation
                                  },
                                );
                              },
                            )
                          else if (company.invitationStatus !=
                              ServiceProviderInvitationStatus.accepted)
                            BaseText.caption(company.invitationStatus!.label),
                        ],
                      ),
                    if (hasPendingInvitation)
                      BaseText.bodySmall('Há convite(s) pendente(s)'.hardcoded),
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
                  ],
                ),
                leading: EditServiceProviderCompanyButton(
                  companyId: company.id,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(Sizes.p8),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        gapH8,
                        if (isLoadingCompany)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: Sizes.p16),
                            child: Center(child: LoadingCircle()),
                          )
                        else if (company.invitationStatus ==
                            ServiceProviderInvitationStatus.accepted) ...[
                          const Divider(),
                          gapH8,
                          ServiceProvidersInvitationsItems(company: company),
                        ],
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
