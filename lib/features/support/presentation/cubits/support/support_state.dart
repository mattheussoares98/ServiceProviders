part of 'support_cubit.dart';

enum SupportSection implements SectionKey { launch, copy }

class SupportState extends BaseState {
  const SupportState({
    this.supportEmail = '',
    this.isEmailAvailable = false,
    this.userDescription = '',
    this.lastCopiedText,
    super.sections = const {},
  });

  const SupportState.initial()
    : supportEmail = '',
      isEmailAvailable = false,
      userDescription = '',
      lastCopiedText = null,
      super();

  final String supportEmail;
  final bool isEmailAvailable;
  final String userDescription;
  final String? lastCopiedText;

  static const int maxDescriptionLength = 2000;

  bool get hasValidDraft =>
      userDescription.trim().isNotEmpty &&
      userDescription.length <= maxDescriptionLength;

  SupportState copyWith({
    String? supportEmail,
    bool? isEmailAvailable,
    String? userDescription,
    String? lastCopiedText,
    bool annulLastCopiedText = false,
    Map<SectionKey, SectionState>? sections,
  }) {
    return SupportState(
      supportEmail: supportEmail ?? this.supportEmail,
      isEmailAvailable: isEmailAvailable ?? this.isEmailAvailable,
      userDescription: userDescription ?? this.userDescription,
      lastCopiedText: annulLastCopiedText
          ? null
          : lastCopiedText ?? this.lastCopiedText,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    supportEmail,
    isEmailAvailable,
    userDescription,
    lastCopiedText,
    ...super.props,
  ];
}
