enum AccessLogAction {
  login('login'),
  logout('logout'),
  appAccess('app_access');

  const AccessLogAction(this.code);
  final String code;

  static AccessLogAction? fromCode(String? code) {
    if (code == null) return null;
    for (final val in AccessLogAction.values) {
      if (val.code == code) return val;
    }
    return null;
  }
}
