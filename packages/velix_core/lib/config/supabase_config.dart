class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://bbtcvqmbpzwmljwxfwbx.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJidGN2cW1icHp3bWxqd3hmd2J4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2NzQ4MDAsImV4cCI6MjA5NDI1MDgwMH0.vfH739yfu3vUz7DoCgnht3Ud5d6lrt78-hnE0nFmRz4',
  );

  // Supabase Storage Buckets
  static const String bucketAvatars = 'avatars';
  static const String bucketVehicles = 'vehicles';
  static const String bucketKycDocuments = 'kyc-documents';
  static const String bucketDisputeEvidence = 'dispute-evidence';

  // API Gateway URL
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://velix-backend-a4jx.onrender.com/api',
  );
}
