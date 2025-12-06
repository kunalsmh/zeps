import Foundation

struct Exemplar: Identifiable, Codable {
    var id: UUID
    var subjectTable: String
    var chapterId: UUID?
    var title: String
    var problemText: String
    var solutionText: String?
    var solutionImageUrl: String?
    var difficulty: Int // 1=easy, 2=medium, 3=hard
    var tags: [String]
    var createdDate: Date
    var updatedDate: Date
    
    init(id: UUID = UUID(), subjectTable: String, chapterId: UUID? = nil, title: String, problemText: String, solutionText: String? = nil, solutionImageUrl: String? = nil, difficulty: Int = 1, tags: [String] = [], createdDate: Date = Date(), updatedDate: Date = Date()) {
        self.id = id
        self.subjectTable = subjectTable
        self.chapterId = chapterId
        self.title = title
        self.problemText = problemText
        self.solutionText = solutionText
        self.solutionImageUrl = solutionImageUrl
        self.difficulty = difficulty
        self.tags = tags
        self.createdDate = createdDate
        self.updatedDate = updatedDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case subjectTable = "subject_table"
        case chapterId = "chapter_id"
        case title
        case problemText = "problem_text"
        case solutionText = "solution_text"
        case solutionImageUrl = "solution_image_url"
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

