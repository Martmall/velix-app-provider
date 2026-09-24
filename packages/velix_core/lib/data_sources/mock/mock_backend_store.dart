@Deprecated('Use live ApiClient and Supabase repositories instead')
class MockBackendStore {
  static final MockBackendStore _instance = MockBackendStore._internal();
  factory MockBackendStore() => _instance;
  MockBackendStore._internal();
}

