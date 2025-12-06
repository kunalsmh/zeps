import Foundation
import Combine
import Supabase
import GoogleSignIn

// MARK: - DTOs (File Level for Safety)
// We keep SubjectNameRow as it is Decodable and seemingly working or harmless.
// We bypass Encodable structs for RPC/Update to avoid "Main actor-isolated conformance" issues completely.

@MainActor
class SubjectsManager: ObservableObject {
    @Published var subjects: [Subject] = []
    private let client = SupabaseConfig.shared.client
    
    init() {
        Task {
            await loadAuthorizedSubjects()
        }
    }
    
    // MARK: - Subject Management
    
    func checkSubjectExists(qrCode: String) async -> String? {
        do {
            print("🔍 Checking QR: \(qrCode)")
            // Use client.from directly (client.database is deprecated)
            let rows: [SubjectNameRow] = try await client
                .from("subjects")
                .select("name")
                .eq("qr_code", value: qrCode)
                .limit(1)
                .execute()
                .value
            
            return rows.first?.name
        } catch {
            print("❌ Check subject error: \(error)")
            return nil
        }
    }
    
    func getSubjectName(for qrCode: String) -> String? {
         return nil
    }
    
    func addUserToSubject(qrCode: String) async -> Bool {
        guard let email = UserDefaults.standard.string(forKey: "userEmail") else { return false }
        
        do {
            // Use Dictionary to avoid Encodable conformance isolation issues with structs
            let params = ["qr_code_text": qrCode, "user_email": email]
            
            print("🚀 Calling RPC add_user_to_subject")
            let success: Bool = try await client
                .rpc("add_user_to_subject", params: params)
                .execute()
                .value
            
            if success {
                await loadAuthorizedSubjects()
            }
            return success
        } catch {
            print("❌ Add user error: \(error)")
            return false
        }
    }
    
    func loadAuthorizedSubjects() async {
        guard let email = UserDefaults.standard.string(forKey: "userEmail") else { return }
        
        do {
            // Use client.from directly
            var loadedSubjects: [Subject] = try await client
                .from("subjects")
                .select()
                .contains("auth_users", value: [email])
                .execute()
                .value
            
            // Inject userId since it's missing from DB response
            for i in 0..<loadedSubjects.count {
                loadedSubjects[i].userId = email
            }
            
            self.subjects = loadedSubjects
            print("📦 Loaded \(subjects.count) subjects")
        } catch {
            print("❌ Load subjects error: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("Type mismatch: expected \(type), context: \(context.debugDescription) - path: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("Value not found: expected \(type), context: \(context.debugDescription) - path: \(context.codingPath)")
                case .keyNotFound(let key, let context):
                    print("Key not found: \(key), context: \(context.debugDescription) - path: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context.debugDescription) - path: \(context.codingPath)")
                @unknown default:
                    print("Unknown decoding error")
                }
            }
        }
    }
    
    // MARK: - Note Operations
    
    func addNote(to subject: Subject, title: String) -> SubjectNote {
        let note = SubjectNote(title: title)
        return addNote(to: subject, note: note)
    }
    
    func addNote(to subject: Subject, note: SubjectNote) -> SubjectNote {
        guard let index = subjects.firstIndex(where: { $0.id == subject.id }) else { return note }
        
        var newNote = note
        // Ensure ID uniqueness
        if subjects[index].notes.contains(where: { $0.id == newNote.id }) {
            newNote.id = UUID()
        }
        
        subjects[index].notes.insert(newNote, at: 0)
        saveNotes(for: subjects[index])
        return newNote
    }
    
    func updateNote(_ note: SubjectNote, in subject: Subject) {
        guard let subjectIndex = subjects.firstIndex(where: { $0.id == subject.id }),
              let noteIndex = subjects[subjectIndex].notes.firstIndex(where: { $0.id == note.id }) else { return }
        
        var updated = note
        updated.modifiedDate = Date()
        subjects[subjectIndex].notes[noteIndex] = updated
        saveNotes(for: subjects[subjectIndex])
    }
    
    func deleteNote(_ note: SubjectNote, from subject: Subject) {
        guard let subjectIndex = subjects.firstIndex(where: { $0.id == subject.id }) else { return }
        
        subjects[subjectIndex].notes.removeAll { $0.id == note.id }
        saveNotes(for: subjects[subjectIndex])
    }
    
    private func saveNotes(for subject: Subject) {
        let notes = subject.notes
        let subjectId = subject.id
        
        Task {
            do {
                let data = try JSONEncoder().encode(notes)
                let jsonString = String(data: data, encoding: .utf8) ?? "[]"
                
                // Use Dictionary for update payload
                let updatePayload = ["notes": jsonString]
                
                try await client
                    .from("subjects")
                    .update(updatePayload)
                    .eq("id", value: subjectId)
                    .execute()
                print("✅ Notes saved")
            } catch {
                print("❌ Save notes error: \(error)")
            }
        }
    }
    
    // MARK: - User & Content Management
    
    func syncUser(email: String, name: String) async {
        do {
            // Upsert user logic
            struct UserID: Decodable, Sendable { let id: String }
            let existing: [UserID] = try await client.from("users").select("id").eq("email", value: email).execute().value
            
            let now = ISO8601DateFormatter().string(from: Date())
            
            if let id = existing.first?.id {
                // Update
                try await client.from("users").update(["name": name, "last_login": now]).eq("id", value: id).execute()
            } else {
                // Insert
                let newId = UUID().uuidString
                let newUser = ["id": newId, "email": email, "name": name, "last_login": now]
                try await client.from("users").insert(newUser).execute()
            }
            print("✅ User synced")
        } catch {
            print("❌ Sync user error: \(error)")
        }
    }
    
    func updateSubjectContent(subjectId: UUID, field: String, content: String) async -> Bool {
        do {
            // Validate field name
            let allowedFields = ["chapters", "flashcards", "pyqs", "exemplars", "notes"]
            guard allowedFields.contains(field) else { 
                print("❌ Invalid field: \(field)")
                return false 
            }
            
            let payload = [field: content]
            try await client.from("subjects").update(payload).eq("id", value: subjectId).execute()
            
            print("✅ Content updated for \(field)")
            await loadAuthorizedSubjects()
            return true
        } catch {
            print("❌ Update content error: \(error)")
            return false
        }
    }
    
    // MARK: - College Application
    
    func saveCollegeApplication(
        grade9: String,
        grade10: String?,
        grade11: String?,
        grade12: String?,
        extracurriculars: String?,
        needsAid: Bool,
        location: CollegeApplication.Location,
        countries: [String]
    ) async -> Bool {
        guard let email = UserDefaults.standard.string(forKey: "userEmail") else {
            print("❌ No user email found for college application")
            return false
        }
        
        do {
            let now = ISO8601DateFormatter().string(from: Date())
            
            // Create Encodable payload struct
            struct CollegeAppPayload: Encodable {
                let user_email: String
                let grade_9: String
                let grade_10: String?
                let grade_11: String?
                let grade_12: String?
                let extracurriculars: String?
                let needs_aid: Bool
                let location: String
                let countries: [String]?
                let created_at: String?
                let updated_at: String
            }
            
            let basePayload = CollegeAppPayload(
                user_email: email,
                grade_9: grade9,
                grade_10: grade10?.isEmpty == false ? grade10 : nil,
                grade_11: grade11?.isEmpty == false ? grade11 : nil,
                grade_12: grade12?.isEmpty == false ? grade12 : nil,
                extracurriculars: extracurriculars?.isEmpty == false ? extracurriculars : nil,
                needs_aid: needsAid,
                location: location.rawValue,
                countries: location == .abroad && !countries.isEmpty ? countries : nil,
                created_at: nil,
                updated_at: now
            )
            
            // Check if application exists
            struct AppID: Decodable, Sendable { let id: UUID }
            let existing: [AppID] = try await client
                .from("college_applications")
                .select("id")
                .eq("user_email", value: email)
                .execute()
                .value
            
            if let appId = existing.first?.id {
                // Update existing
                let updatePayload = CollegeAppPayload(
                    user_email: email,
                    grade_9: grade9,
                    grade_10: grade10?.isEmpty == false ? grade10 : nil,
                    grade_11: grade11?.isEmpty == false ? grade11 : nil,
                    grade_12: grade12?.isEmpty == false ? grade12 : nil,
                    extracurriculars: extracurriculars?.isEmpty == false ? extracurriculars : nil,
                    needs_aid: needsAid,
                    location: location.rawValue,
                    countries: location == .abroad && !countries.isEmpty ? countries : nil,
                    created_at: nil,
                    updated_at: now
                )
                
                try await client
                    .from("college_applications")
                    .update(updatePayload)
                    .eq("id", value: appId)
                    .execute()
            } else {
                // Insert new
                let insertPayload = CollegeAppPayload(
                    user_email: email,
                    grade_9: grade9,
                    grade_10: grade10?.isEmpty == false ? grade10 : nil,
                    grade_11: grade11?.isEmpty == false ? grade11 : nil,
                    grade_12: grade12?.isEmpty == false ? grade12 : nil,
                    extracurriculars: extracurriculars?.isEmpty == false ? extracurriculars : nil,
                    needs_aid: needsAid,
                    location: location.rawValue,
                    countries: location == .abroad && !countries.isEmpty ? countries : nil,
                    created_at: now,
                    updated_at: now
                )
                
                try await client
                    .from("college_applications")
                    .insert(insertPayload)
                    .execute()
            }
            
            print("✅ College application saved")
            return true
        } catch {
            print("❌ Save college application error: \(error)")
            return false
        }
    }
    
    func loadCollegeApplication() async -> CollegeApplication? {
        guard let email = UserDefaults.standard.string(forKey: "userEmail") else {
            return nil
        }
        
        do {
            let applications: [CollegeApplication] = try await client
                .from("college_applications")
                .select()
                .eq("user_email", value: email)
                .limit(1)
                .execute()
                .value
            
            return applications.first
        } catch {
            print("❌ Load college application error: \(error)")
            return nil
        }
    }
}
