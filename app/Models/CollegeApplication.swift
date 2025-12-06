import Foundation

struct CollegeApplication: Identifiable, Codable {
    var id: UUID
    var userEmail: String
    var grade9: String?
    var grade10: String?
    var grade11: String?
    var grade12: String?
    var extracurriculars: String?
    var needsAid: Bool
    var location: Location
    var countries: [String]
    var createdAt: Date
    var updatedAt: Date
    
    enum Location: String, Codable {
        case india = "india"
        case abroad = "abroad"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userEmail = "user_email"
        case grade9 = "grade_9"
        case grade10 = "grade_10"
        case grade11 = "grade_11"
        case grade12 = "grade_12"
        case extracurriculars
        case needsAid = "needs_aid"
        case location
        case countries
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(
        id: UUID = UUID(),
        userEmail: String,
        grade9: String? = nil,
        grade10: String? = nil,
        grade11: String? = nil,
        grade12: String? = nil,
        extracurriculars: String? = nil,
        needsAid: Bool = false,
        location: Location = .india,
        countries: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userEmail = userEmail
        self.grade9 = grade9
        self.grade10 = grade10
        self.grade11 = grade11
        self.grade12 = grade12
        self.extracurriculars = extracurriculars
        self.needsAid = needsAid
        self.location = location
        self.countries = countries
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userEmail = try container.decode(String.self, forKey: .userEmail)
        grade9 = try container.decodeIfPresent(String.self, forKey: .grade9)
        grade10 = try container.decodeIfPresent(String.self, forKey: .grade10)
        grade11 = try container.decodeIfPresent(String.self, forKey: .grade11)
        grade12 = try container.decodeIfPresent(String.self, forKey: .grade12)
        extracurriculars = try container.decodeIfPresent(String.self, forKey: .extracurriculars)
        needsAid = try container.decodeIfPresent(Bool.self, forKey: .needsAid) ?? false
        location = try container.decode(Location.self, forKey: .location)
        countries = try container.decodeIfPresent([String].self, forKey: .countries) ?? []
        
        // Handle date decoding
        if let date = try? container.decodeIfPresent(Date.self, forKey: .createdAt) {
            createdAt = date
        } else if let dateString = try? container.decodeIfPresent(String.self, forKey: .createdAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            createdAt = formatter.date(from: dateString) ?? Date()
        } else {
            createdAt = Date()
        }
        
        if let date = try? container.decodeIfPresent(Date.self, forKey: .updatedAt) {
            updatedAt = date
        } else if let dateString = try? container.decodeIfPresent(String.self, forKey: .updatedAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            updatedAt = formatter.date(from: dateString) ?? Date()
        } else {
            updatedAt = Date()
        }
    }
}

