import SwiftUI

struct SubjectsListView: View {
    @ObservedObject var subjectsManager: SubjectsManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                if subjectsManager.subjects.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 64))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No Subjects")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.black)
                        Text("Scan a QR code to add your first subject")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 50)
                    }
                } else {
                    List(subjectsManager.subjects) { subject in
                        NavigationLink(destination: SubjectDetailView(subjectsManager: subjectsManager, subject: subject)) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(subject.name)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.black)
                                
                                Text("\(subject.notes.count) notes")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                
                                Text(subject.createdDate, style: .date)
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray.opacity(0.6))
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(Color.white)
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                    .background(Color.white)
                }
            }
            .navigationTitle("Subjects")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}
