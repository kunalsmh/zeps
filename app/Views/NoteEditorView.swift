import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct NoteEditorView: View {
    @ObservedObject var subjectsManager: SubjectsManager
    let subject: Subject
    @State var note: SubjectNote
    @Environment(\.dismiss) var dismiss
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isContentFocused: Bool
    @State private var showMarkdownPreview = false
    @State private var showAttachmentPicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var autosaveTask: Task<Void, Never>?
    @State private var lastSavedDate: Date?
    
    // Extract title from first line of content (iOS Notes style)
    private var noteTitle: Binding<String> {
        Binding(
            get: {
                if !note.title.isEmpty && note.title != "New Note" {
                    return note.title
                }
                let firstLine = note.mainContent.components(separatedBy: .newlines).first ?? ""
                return firstLine.isEmpty ? "New Note" : String(firstLine.prefix(50))
            },
            set: { newValue in
                note.title = newValue
            }
        )
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.98)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Title field (iOS Notes style - appears when focused)
                    if isTitleFocused || !noteTitle.wrappedValue.isEmpty {
                        TextField("", text: noteTitle, prompt: Text("Title").foregroundColor(.gray.opacity(0.5)))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .focused($isTitleFocused)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                            .onChange(of: noteTitle.wrappedValue) { _, _ in
                                triggerAutosave()
                            }
                    }
                    
                    // Content editor (iOS Notes style)
                    ZStack(alignment: .topLeading) {
                        if note.mainContent.isEmpty && !isContentFocused {
                            Text("Start writing...")
                                .font(.system(size: 17))
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                        }
                        
                        TextEditor(text: Binding(
                            get: { note.mainContent },
                            set: { newValue in
                                note.content = newValue
                                // Auto-update title from first line if title is empty
                                if note.title.isEmpty || note.title == "New Note" {
                                    let firstLine = newValue.components(separatedBy: .newlines).first ?? ""
                                    note.title = firstLine.isEmpty ? "New Note" : String(firstLine.prefix(50))
                                }
                                triggerAutosave()
                            }
                        ))
                        .font(.system(size: 17))
                        .foregroundColor(.black)
                        .focused($isContentFocused)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 400)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    
                    // Attachments section
                    if !note.attachments.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(note.attachments) { attachment in
                                AttachmentView(attachment: attachment) {
                                    deleteAttachment(attachment)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    
                    // Markdown preview
                    if showMarkdownPreview {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                if #available(iOS 15.0, *) {
                                    if let attributedString = try? AttributedString(markdown: note.mainContent) {
                                        Text(attributedString)
                                            .font(.system(size: 17))
                                            .foregroundColor(.black)
                                            .padding()
                                    } else {
                                        Text(note.mainContent)
                                            .font(.system(size: 17))
                                            .foregroundColor(.black)
                                            .padding()
                                    }
                                } else {
                                    Text(note.mainContent)
                                        .font(.system(size: 17))
                                        .foregroundColor(.black)
                                        .padding()
                                }
                            }
                        }
                        .frame(maxHeight: 400)
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    
                    // Spacer to allow scrolling past keyboard
                    Spacer()
                        .frame(height: 100)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    isContentFocused = false
                    isTitleFocused = false
                    saveNote()
                    dismiss()
                }
                .foregroundColor(.blue)
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Attachment button
                Button(action: {
                    showAttachmentPicker = true
                }) {
                    Image(systemName: "paperclip")
                        .foregroundColor(.blue)
                }
                
                // Markdown preview toggle
                Button(action: {
                    withAnimation {
                        showMarkdownPreview.toggle()
                    }
                }) {
                    Image(systemName: showMarkdownPreview ? "textformat" : "textformat.abc")
                        .foregroundColor(.blue)
                }
                
                // More options menu
                Menu {
                    Button(role: .destructive, action: {
                        subjectsManager.deleteNote(note, from: subject)
                        dismiss()
                    }) {
                        Label("Delete Note", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.blue)
                }
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isContentFocused = false
                    isTitleFocused = false
                }
                .foregroundColor(.blue)
            }
        }
        .photosPicker(isPresented: $showAttachmentPicker, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { _, newValue in
            if let newValue = newValue {
                loadPhoto(newValue)
            }
        }
        .onAppear {
            // Auto-focus content editor on appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isContentFocused = true
            }
        }
        .onDisappear {
            // Save when leaving
            saveNote()
            autosaveTask?.cancel()
        }
    }
    
    private func triggerAutosave() {
        // Cancel previous autosave task
        autosaveTask?.cancel()
        
        // Update modified date
        note.modifiedDate = Date()
        
        // Schedule new autosave after 1 second of inactivity
        autosaveTask = Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            if !Task.isCancelled {
                await MainActor.run {
                    saveNote()
                }
            }
        }
    }
    
    private func saveNote() {
        subjectsManager.updateNote(note, in: subject)
        lastSavedDate = Date()
    }
    
    private func loadPhoto(_ item: PhotosPickerItem) {
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                // Determine file name and mime type from content types
                let contentType = item.supportedContentTypes.first
                let mimeType = contentType?.preferredMIMEType ?? "image/jpeg"
                
                // Generate filename based on mime type and timestamp
                let fileExtension = contentType?.preferredFilenameExtension ?? "jpg"
                let fileName = "attachment_\(Date().timeIntervalSince1970).\(fileExtension)"
                
                let attachment = NoteAttachment(fileName: fileName, fileData: data, mimeType: mimeType)
                
                await MainActor.run {
                    note.attachments.append(attachment)
                    triggerAutosave()
                }
            }
        }
    }
    
    private func deleteAttachment(_ attachment: NoteAttachment) {
        note.attachments.removeAll { $0.id == attachment.id }
        triggerAutosave()
    }
}

struct AttachmentView: View {
    let attachment: NoteAttachment
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Preview thumbnail
            if attachment.mimeType.hasPrefix("image/"),
               let uiImage = UIImage(data: attachment.fileData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "doc.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(attachment.fileName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(formatFileSize(attachment.fileData.count))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                Text(attachment.createdDate, style: .relative)
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 20))
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

