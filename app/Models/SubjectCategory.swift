import SwiftUI

enum SubjectCategory: String, CaseIterable, Identifiable {
    case notes = "Notes"
    case pyqs = "PYQs"
    case exemplars = "Exemplars"
    case flashcards = "Flashcards"
    case aiSummary = "AI Summary"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .notes: return "note.text"
        case .pyqs: return "doc.text"
        case .exemplars: return "book.closed"
        case .flashcards: return "rectangle.stack"
        case .aiSummary: return "sparkles"
        }
    }
    
    var color: Color {
        switch self {
        case .notes: return .blue
        case .pyqs: return .orange
        case .exemplars: return .green
        case .flashcards: return .purple
        case .aiSummary: return .pink
        }
    }
}
