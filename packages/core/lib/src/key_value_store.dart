/// Minimal string key-value persistence, backed in production by
/// `shared_preferences` (implemented in the `database` package).
///
/// The persisted cart lives behind this interface so the storage engine can
/// be swapped without touching `feature_cart`.
abstract interface class KeyValueStore {
  /// Reads the value stored under [key], or `null` when absent.
  Future<String?> read(String key);

  /// Writes [value] under [key]; returns `true` on success.
  Future<bool> write(String key, String value);

  /// Removes [key]; returns `true` when something was removed.
  Future<bool> delete(String key);
}
