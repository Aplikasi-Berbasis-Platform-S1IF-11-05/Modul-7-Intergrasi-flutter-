class SupabaseConfig {
  // TODO: Add your Supabase credentials here for Online database mode.
  // Leave them empty or default to trigger the Local Fallback (offline) mode automatically.
  static const String supabaseUrl = 'https://hcyvzbnfbweqjqtmhhky.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_I2CBlkU793p1o_nriDBfBg_37VLOtGz';

  static bool get isConfigured {
    return supabaseUrl.isNotEmpty && 
           supabaseAnonKey.isNotEmpty && 
           supabaseUrl.startsWith('http');
  }
}
