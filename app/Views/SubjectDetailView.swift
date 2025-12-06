import SwiftUI

struct SubjectDetailView: View {
    @ObservedObject var subjectsManager: SubjectsManager
    let subject: Subject
    @State private var selectedCategory: SubjectCategory?
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Subject name header
                HStack {
                    Text(subject.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Categories grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(SubjectCategory.allCases) { category in
                        CategoryCard(category: category) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedCategory) { category in
                NavigationView {
                switch category {
                case .notes:
                    SubjectNotesListView(subjectsManager: subjectsManager, subject: subject)
                case .pyqs:
                    PYQsListView(subjectsManager: subjectsManager, subject: subject)
                case .exemplars:
                    ExemplarsListView(subjectsManager: subjectsManager, subject: subject)
                case .flashcards:
                    FlashcardsListView(subjectsManager: subjectsManager, subject: subject)
                case .aiSummary:
                CategoryPlaceholderView(category: category)
                }
            }
        }
    }
}

struct CategoryCard: View {
    let category: SubjectCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 40))
                    .foregroundColor(category.color)
                
                Text(category.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}
