/// Independent ordinary users, each with a separate authenticated client.
enum Identity {
  admin,
  technician,
  supervisor,
  provider,
  foreign;

  bool get isRequired => true;
}
