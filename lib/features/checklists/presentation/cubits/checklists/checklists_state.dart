part of 'checklists_cubit.dart';

class ChecklistsState extends BaseState {
  const ChecklistsState({super.sections});

  const ChecklistsState.empty() : super();

  @override
  List<Object?> get props => [sections];
}