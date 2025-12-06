import Foundation

struct Subject: Identifiable, Codable {
    var id: UUID
    var userId: String
    var name: String
    var qrCode: String
    var notes: [SubjectNote]
    var chapters: [Chapter]
    var flashcards: [Flashcard]
    var pyqs: [PYQ]
    var exemplars: [Exemplar]
    // Text content from database
    var chaptersText: String
    var flashcardsText: String
    var pyqsText: String
    var exemplarsText: String
    var createdDate: Date
    var updatedDate: Date
    
    init(id: UUID = UUID(), userId: String, name: String, qrCode: String, notes: [SubjectNote] = [], chapters: [Chapter] = [], flashcards: [Flashcard] = [], pyqs: [PYQ] = [], exemplars: [Exemplar] = [], chaptersText: String = "", flashcardsText: String = "", pyqsText: String = "", exemplarsText: String = "", createdDate: Date = Date(), updatedDate: Date = Date()) {
        self.id = id
        self.userId = userId
        self.name = name
        self.qrCode = qrCode
        self.notes = notes
        self.chapters = chapters
        self.flashcards = flashcards
        self.pyqs = pyqs
        self.exemplars = exemplars
        self.chaptersText = chaptersText
        self.flashcardsText = flashcardsText
        self.pyqsText = pyqsText
        self.exemplarsText = exemplarsText
        self.createdDate = createdDate
        self.updatedDate = updatedDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case qrCode = "qr_code"
        case notes
        case chaptersText = "chapters"
        case flashcardsText = "flashcards"
        case pyqsText = "pyqs"
        case exemplarsText = "exemplars"
        case createdDate = "created_at"
        case updatedDate = "updated_at"
    }
    
    // Custom decoding to handle text fields from database
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decodeIfPresent(String.self, forKey: .userId) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        qrCode = try container.decodeIfPresent(String.self, forKey: .qrCode) ?? ""
        
        // Handle notes which might be a JSON string or an array
        if let notesArray = try? container.decode([SubjectNote].self, forKey: .notes) {
            notes = notesArray
        } else if let notesString = try? container.decode(String.self, forKey: .notes),
                  let data = notesString.data(using: .utf8),
                  let notesArray = try? JSONDecoder().decode([SubjectNote].self, from: data) {
            notes = notesArray
        } else {
            notes = []
        }
        
        // Initialize arrays as empty since we are reading text
        chapters = []
        flashcards = []
        pyqs = []
        exemplars = []
        
        // Try to decode as text first, fallback to empty string
        if let text = try? container.decode(String.self, forKey: .chaptersText) {
            chaptersText = text
        } else {
            chaptersText = ""
        }
        
        if let text = try? container.decode(String.self, forKey: .flashcardsText) {
            flashcardsText = text
        } else {
            flashcardsText = ""
        }
        
        if let text = try? container.decode(String.self, forKey: .pyqsText) {
            pyqsText = text
        } else {
            pyqsText = ""
        }
        
        if let text = try? container.decode(String.self, forKey: .exemplarsText) {
            exemplarsText = text
        } else {
            exemplarsText = ""
        }
        
        // Handle date decoding robustly
        if let date = try? container.decodeIfPresent(Date.self, forKey: .createdDate) {
            createdDate = date
        } else if let dateString = try? container.decodeIfPresent(String.self, forKey: .createdDate) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateString) {
                createdDate = date
            } else {
                // Try without fractional seconds
                formatter.formatOptions = [.withInternetDateTime]
                createdDate = formatter.date(from: dateString) ?? Date()
            }
        } else {
            createdDate = Date()
        }
        
        if let date = try? container.decodeIfPresent(Date.self, forKey: .updatedDate) {
            updatedDate = date
        } else if let dateString = try? container.decodeIfPresent(String.self, forKey: .updatedDate) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateString) {
                updatedDate = date
            } else {
                // Try without fractional seconds
                formatter.formatOptions = [.withInternetDateTime]
                updatedDate = formatter.date(from: dateString) ?? Date()
            }
        } else {
            updatedDate = Date()
        }
    }
    
    // Get the subject table name for database queries
    // This maps the QR code to the corresponding table name
    // Uses the same mapping as SubjectsManager
    var subjectTableName: String? {
        let qrCodeMapping: [String: (name: String, table: String)] = [
            "http://epathshala.nic.in/QR/?id=11076": (name: "11th - Math", table: "11_math"),
            "google.com": (name: "12th - Physics", table: "12_physics")
        ]
        
        let lowercaseCode = qrCode.lowercased()
        
        // Try exact match first
        for (key, value) in qrCodeMapping {
            if lowercaseCode == key.lowercased() {
                return value.table
            }
        }
        
        // Try contains match
        for (key, value) in qrCodeMapping {
            if lowercaseCode.contains(key.lowercased()) {
                return value.table
            }
        }
        
        return nil
    }
}

struct NoteAttachment: Identifiable, Codable {
    var id: UUID
    var fileName: String
    var fileData: Data
    var mimeType: String
    var createdDate: Date
    
    init(id: UUID = UUID(), fileName: String, fileData: Data, mimeType: String, createdDate: Date = Date()) {
        self.id = id
        self.fileName = fileName
        self.fileData = fileData
        self.mimeType = mimeType
        self.createdDate = createdDate
    }
}

struct SubjectNote: Identifiable, Codable {
    var id: UUID
    var title: String
    var description: String // Keep for backward compatibility
    var content: String // Markdown content
    var attachments: [NoteAttachment]
    var createdDate: Date
    var modifiedDate: Date
    
    init(id: UUID = UUID(), title: String, description: String = "", content: String = "", attachments: [NoteAttachment] = [], createdDate: Date = Date(), modifiedDate: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.content = content.isEmpty ? description : content
        self.attachments = attachments
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
    }
    
    // Computed property to get the main content (prefer content over description)
    var mainContent: String {
        return content.isEmpty ? description : content
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case content
        case attachments
        case createdDate = "created_at"
        case modifiedDate = "modified_at"
    }
}
