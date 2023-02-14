/// Dismiss Mode
/// ------------------------------------------------------------------------------------------------

enum DismissMode {

  /// Do not automatically dismiss the modal bottom sheet.
  none,

  /// Automatically dismiss the modal bottom sheet when the request completes successfully.
  success,

  /// Automatically dismiss the modal bottom sheet when the request completes unsuccessfully.
  error,

  /// Automatically dismiss the modal bottom sheet when the request completes.
  done,
}