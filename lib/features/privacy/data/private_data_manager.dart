/// Stub implementation for PrivateDataManager to fix build errors.
class PrivateDataManager {
  PrivateDataManager();

  Future<void> clearPrivateSessionData() async {
    // Stub: implement actual clearing logic if needed
  }

  bool shouldRecordHistory({required bool isPrivate}) {
    // Stub: return false for private, true otherwise
    return !isPrivate;
  }

  bool shouldPersistTab({required bool isPrivate}) {
    // Stub: return false for private, true otherwise
    return !isPrivate;
  }
}
