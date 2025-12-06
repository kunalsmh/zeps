import Foundation

struct PYQ: Identifiable, Codable {
    var id: UUID
    var subjectTable: String
    var chapterId: UUID?
    var year: Int
    var examType: String? // e.g., 'Board', 'JEE', 'NEET', etc.
    var questionText: String
    var answerText: String?
    var answerImageUrl: String?
    var marks: Int?
    var difficulty: Int // 1=easy, 2=medium, 3=hard
    var tags: [String]
    var createdDate: Date
    var updatedDate: Date
    
    init(id: UUID = UUID(), subjectTable: String, chapterId: UUID? = nil, year: Int, examType: String? = nil, questionText: String, answerText: String? = nil, answerImageUrl: String? = nil, marks: Int? = nil, difficulty: Int = 1, tags: [String] = [], createdDate: Date = Date(), updatedDate: Date = Date()) {
        self.id = id
        self.subjectTable = subjectTable
        self.chapterId = chapterId
        self.year = year
        self.examType = examType
        self.questionText = questionText
        self.answerText = answerText
        self.answerImageUrl = answerImageUrl
        self.marks = marks
        self.difficulty = difficulty
        self.tags = tags
        self.createdDate = createdDate
        self.updatedDate = updatedDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case subjectTable = "subject_table"
        case chapterId = "chapter_id"
        case year
        case examType = "exam_type"
        case questionText = "question_text"
        case answerText = "answer_text"
        case answerImageUrl = "answer_image_url"
        case marks
        case difficulty
        case tags
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

