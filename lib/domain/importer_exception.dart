class ImporterException implements Exception {
  final String message;
  final Object parent;

  const ImporterException(this.message, [this.parent]);

  @override
  String toString() =>
      '$ImporterException: $message. ${parent == null ? '' : 'Parental exception: $parent'}';
}
