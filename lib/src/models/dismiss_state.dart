/// Dismiss State
/// ------------------------------------------------------------------------------------------------

enum DismissState {

  /// Automatically dismiss the modal bottom sheet when the request completes successfully.
  success,

  /// Automatically dismiss the modal bottom sheet when the request completes with an error.
  error,

  /// Automatically dismiss the modal bottom sheet when the request completes (success or error).
  done,
  ;
}
