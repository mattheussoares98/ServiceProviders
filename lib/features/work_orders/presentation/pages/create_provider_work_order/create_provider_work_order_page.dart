import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/get_new_date.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_running.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';
import 'package:uuid/uuid.dart';

part './widgets/provider_area_dropdown.dart';
part './widgets/provider_company_dropdown.dart';
part './widgets/provider_description_field.dart';
part './widgets/provider_location_dropdown.dart';
part './widgets/provider_priority_dropdown.dart';
part './widgets/provider_save_button.dart';
part './widgets/provider_scheduled_date.dart';
part './widgets/provider_title_field.dart';
part './widgets/provider_type_dropdown.dart';
part './widgets/provider_work_order_form.dart';

/// Reduced work order form for provider mode (V2 §1.3 / Q5).
///
/// Only the fields a provider owns are offered. Responsible, SLA policy, status
/// and the provider assignment itself belong to the contracting company or are
/// implied — the order is opened as `open`, assigned to the author's own
/// provider company. The equipment field is omitted: `assets` is not readable
/// across a contracting company's registry in provider mode.
@RoutePage()
class CreateProviderWorkOrderPage extends StatelessWidget {
  const CreateProviderWorkOrderPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: BaseAppBar(title: 'Nova ordem de serviço'.hardcoded),
      padding: const EdgeInsets.symmetric(horizontal: Sizes.p8),
      body: const _ProviderWorkOrderForm(),
    );
  }
}
