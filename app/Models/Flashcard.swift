import Foundation

struct Flashcard: Identifiable, Codable {
    var id: UUID
    var subjectTable: String
    var chapterId: UUID?
    var frontText: String
    var backText: String
    var frontImageUrl: String?
    var backImageUrl: String?
    var difficulty: Int // 1=easy, 2=medium, 3=hard
    var timesStudied: Int
    var lastStudiedAt: Date?
    var createdDate: Date
    var updatedDate: Date
    
    init(id: UUID = UUID(), subjectTable: String, chapterId: UUID? = nil, frontText: String, backText: String, frontImageUrl: String? = nil, backImageUrl: String? = nil, difficulty: Int = 1, timesStudied: Int = 0, lastStudiedAt: Date? = nil, createdDate: Date = Date(), updatedDate: Date = Date()) {
        self.id = id
        self.subjectTable = subjectTable
        self.chapterId = chapterId
        self.frontText = frontText
        self.backText = backText
        self.frontImageUrl = frontImageUrl
        self.backImageUrl = backImageUrl
        self.difficulty = difficulty
        self.timesStudied = timesStudied
        self.lastStudiedAt = lastStudiedAt
        self.createdDate = createdDate
        self.updatedDate = updatedDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case subjectTable = "subject_table"
        case chapterId = "chapter_id"
        case frontText = "front_text"
        case backText = "back_text"
        case frontImageUrl = "front_image_url"
        case backImageUrl = "back_image_url"
        case difficulty
        case timesStudied = "times_studied"
        case lastStudiedAt = "last_studied_at"
        case createdDate = "created_at"
        case updatedDate = "updated_at"
    }
    
    var difficultyLevel: DifficultyLevel {
        switch difficulty {
        case 1: return .easy
        case 2: return .medium
        case 3: return .hard
        default: return .easy
        }
    }
}

enum DifficultyLevel: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var value: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}

