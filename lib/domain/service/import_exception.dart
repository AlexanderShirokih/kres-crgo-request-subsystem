/// Used when document import has failed
class ImportException implements Exception {
  final String message;
  final Object? parent;

  const ImportException(this.message, [this.parent]);

  @override
  String toString() =>
      '$ImportException: $message. ${parent == null ? '' : 'Parental exception: $parent'}';
}
