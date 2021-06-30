/// Defines how newly created worksheet should be filled
enum WorksheetCreationMode {
  /// Empty page will be created
  empty,

  /// Imports content from request list saved in the specified format
  import,

  /// Imports counters list into new page
  importCounters,

  /// Imports content saved in the native format
  importNative,
}
