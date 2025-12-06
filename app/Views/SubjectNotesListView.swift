import SwiftUI

struct SubjectNotesListView: View {
    @ObservedObject var subjectsManager: SubjectsManager
    let subject: Subject
    @Environment(\.dismiss) var dismiss
    @State private var selectedNote: SubjectNote?
    @State private var showNoteDetail = false
    @State private var showNewNote = false
    
    var currentSubject: Subject? {
        subjectsManager.subjects.first(where: { $0.id == subject.id })
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.98)
                .ignoresSafeArea()
            
            if let currentSubject = currentSubject, !currentSubject.notes.isEmpty {
                List {
                    ForEach(currentSubject.notes) { note in
                        Button(action: {
                            selectedNote = note
                            showNoteDetail = true
                        }) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(note.title.isEmpty ? "New Note" : note.title)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.black)
                                
                                if !note.mainContent.isEmpty {
                                    Text(note.mainContent)
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                                
                                HStack {
                                    Text(note.modifiedDate, style: .relative)
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray.opacity(0.6))
                                    
                                    if !note.attachments.isEmpty {
                                        Spacer()
                                        HStack(spacing: 4) {
                                            Image(systemName: "paperclip")
                                                .font(.system(size: 11))
                                            Text("\(note.attachments.count)")
                                                .font(.system(size: 11))
                                        }
                                        .foregroundColor(.gray.opacity(0.6))
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listRowBackground(Color.white)
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
                .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "note.text")
                        .font(.system(size: 64))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No Notes")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black)
                    Text("Tap + to create your first note")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 50)
                }
            }
        }
        .navigationTitle("Notes")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    createNewNote()
                }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showNoteDetail) {
            if let note = selectedNote {
                NavigationView {
                    NoteEditorView(
                        subjectsManager: subjectsManager,
                        subject: subject,
                        note: note
                    )
                }
            }
        }
        .sheet(isPresented: $showNewNote) {
            if let note = selectedNote {
                NavigationView {
                    NoteEditorView(
                        subjectsManager: subjectsManager,
                        subject: subject,
                        note: note
                    )
                }
            }
        }
    }
    
    private func createNewNote() {
        let newNote = SubjectNote(title: "New Note", content: "")
        selectedNote = subjectsManager.addNote(to: subject, note: newNote)
        showNewNote = true
    }
}
