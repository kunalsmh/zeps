import Foundation
import Supabase

// MARK: - Configuration
// API keys are loaded from SupabaseConfig.local.swift (gitignored)
// or from environment variables (for CI/CD).
// SupabaseConfig.local.swift is automatically used if it exists.

class SupabaseConfig {
    static let shared = SupabaseConfig()
    
    let client: SupabaseClient
    
    private init() {
        let urlString: String
        let key: String
        
        // Priority 1: Environment variables (for CI/CD)
        if let envURL = ProcessInfo.processInfo.environment["SUPABASE_URL"],
           let envKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"],
           !envURL.isEmpty, !envKey.isEmpty {
            urlString = envURL
            key = envKey
        }
        // Priority 2: Local config file (SupabaseConfig.local.swift)
        // This file is gitignored and contains SupabaseLocalConfig struct
        else {
            urlString = SupabaseLocalConfig.url
            key = SupabaseLocalConfig.key
        }
        
        guard let url = URL(string: urlString) else {
            fatalError("Invalid Supabase URL: \(urlString)")
        }
        
        guard !key.isEmpty else {
            fatalError("Supabase key is empty")
        }
        
        client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    }
}
