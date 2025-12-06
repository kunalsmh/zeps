import SwiftUI

struct PYQsListView: View {
    @ObservedObject var subjectsManager: SubjectsManager
    let subject: Subject
    @Environment(\.dismiss) var dismiss
    @State private var selectedPYQ: PYQ?
    @State private var showPYQDetail = false
    
    var currentSubject: Subject? {
        subjectsManager.subjects.first(where: { $0.id == subject.id })
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.98)
                .ignoresSafeArea()
            
            if let currentSubject = currentSubject {
                if !currentSubject.pyqsText.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(currentSubject.pyqsText)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .padding()
                        }
                    }
                } else if !currentSubject.pyqs.isEmpty {
                    List {
                        ForEach(currentSubject.pyqs) { pyq in
                            Button(action: {
                                selectedPYQ = pyq
                                showPYQDetail = true
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("\(pyq.year)")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.orange)
                                        
                                        if let examType = pyq.examType {
                                            Text("• \(examType)")
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        if let marks = pyq.marks {
                                            Text("\(marks) marks")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    Text(pyq.questionText)
                                        .font(.system(size: 15))
                                        .foregroundColor(.black)
                                        .lineLimit(3)
                                    
                                    if !pyq.tags.isEmpty {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 6) {
                                                ForEach(pyq.tags, id: \.self) { tag in
                                                    Text(tag)
                                                        .font(.system(size: 11))
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .background(Color.orange.opacity(0.1))
                                                        .foregroundColor(.orange)
                                                        .cornerRadius(8)
                                                }
                                            }
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
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 64))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No PYQs")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.black)
                        Text("Previous year questions will appear here")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 50)
                    }
                }
            }
        }
        .navigationTitle("PYQs")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $showPYQDetail) {
            if let pyq = selectedPYQ {
                NavigationView {
                    PYQDetailView(pyq: pyq)
                }
            }
        }
    }
}

struct PYQDetailView: View {
    let pyq: PYQ
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(pyq.year)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.orange)
                        
                        if let examType = pyq.examType {
                            Text(examType)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    if let marks = pyq.marks {
                        VStack {
                            Text("\(marks)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.orange)
                            Text("marks")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Divider()
                
                // Question
                VStack(alignment: .leading, spacing: 12) {
                    Text("Question")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(pyq.questionText)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 20)
                
                // Answer
                if let answerText = pyq.answerText, !answerText.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Answer")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text(answerText)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Tags
                if !pyq.tags.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(pyq.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.system(size: 13))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.orange.opacity(0.1))
                                        .foregroundColor(.orange)
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
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
