import Foundation

struct Chapter: Identifiable, Codable {
    var id: UUID
    var subjectTable: String
    var chapterNumber: Int?
    var title: String
    var description: String?
    var createdDate: Date
    var updatedDate: Date
    
    init(id: UUID = UUID(), subjectTable: String, chapterNumber: Int? = nil, title: String, description: String? = nil, createdDate: Date = Date(), updatedDate: Date = Date()) {
        self.id = id
        self.subjectTable = subjectTable
        self.chapterNumber = chapterNumber
        self.title = title
        self.description = description
        self.createdDate = createdDate
        self.updatedDate = updatedDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case subjectTable = "subject_table"
        case chapterNumber = "chapter_number"
        case title
        case description
        case createdDate = "created_at"
        case updatedDate = "updated_at"
    }
}

