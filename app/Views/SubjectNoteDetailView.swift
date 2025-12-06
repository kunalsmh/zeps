import SwiftUI

struct SubjectNoteDetailView: View {
    @ObservedObject var subjectsManager: SubjectsManager
    let subject: Subject
    @State var note: SubjectNote
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Note Title
            HStack {
                Text(note.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            // Date
            HStack {
                Text(note.createdDate, style: .date)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 15)
            
            // Description Editor
            TextEditor(text: $note.description)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .focused($isFocused)
                .scrollContentBackground(.hidden)
                .background(Color.white)
                .onChange(of: note.description) {
                    subjectsManager.updateNote(note, in: subject)
                }
            
            Spacer()
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive, action: {
                        subjectsManager.deleteNote(note, from: subject)
                        dismiss()
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.blue)
                }
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isFocused = false
                }
                .foregroundColor(.blue)
            }
        }
    }
}
