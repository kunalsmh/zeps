import SwiftUI

struct FlashcardsListView: View {
    @ObservedObject var subjectsManager: SubjectsManager
    let subject: Subject
    @Environment(\.dismiss) var dismiss
    @State private var currentFlashcardIndex: Int = 0
    @State private var showAnswer: Bool = false
    
    var currentSubject: Subject? {
        subjectsManager.subjects.first(where: { $0.id == subject.id })
    }
    
    var currentFlashcards: [Flashcard] {
        currentSubject?.flashcards ?? []
    }
    
    var currentFlashcard: Flashcard? {
        guard currentFlashcardIndex >= 0 && currentFlashcardIndex < currentFlashcards.count else {
            return nil
        }
        return currentFlashcards[currentFlashcardIndex]
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.98)
                .ignoresSafeArea()
            
            if let currentSubject = currentSubject {
                if !currentSubject.flashcardsText.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(currentSubject.flashcardsText)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .padding()
                        }
                    }
                } else if !currentSubject.flashcards.isEmpty, let flashcard = currentFlashcard {
                    VStack(spacing: 20) {
                        // Progress indicator
                        HStack {
                            Text("\(currentFlashcardIndex + 1) / \(currentFlashcards.count)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Flashcard
                        VStack(spacing: 0) {
                            // Front/Back content
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                                
                                VStack(spacing: 20) {
                                    Text(showAnswer ? "Answer" : "Question")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                        .textCase(.uppercase)
                                    
                                    Text(showAnswer ? flashcard.backText : flashcard.frontText)
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 30)
                                        .frame(minHeight: 200)
                                }
                                .padding(30)
                            }
                            .frame(height: 350)
                            .padding(.horizontal, 20)
                            .rotation3DEffect(
                                .degrees(showAnswer ? 180 : 0),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showAnswer)
                            .onTapGesture {
                                withAnimation {
                                    showAnswer.toggle()
                                }
                            }
                            
                            // Tap to flip hint
                            Text("Tap to flip")
                                .font(.system(size: 12))
                                .foregroundColor(.gray.opacity(0.6))
                                .padding(.top, 12)
                        }
                        
                        // Navigation buttons
                        HStack(spacing: 20) {
                            Button(action: {
                                withAnimation {
                                    showAnswer = false
                                    if currentFlashcardIndex > 0 {
                                        currentFlashcardIndex -= 1
                                    }
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(currentFlashcardIndex > 0 ? Color.purple : Color.gray)
                                    .cornerRadius(25)
                            }
                            .disabled(currentFlashcardIndex == 0)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    showAnswer = false
                                    if currentFlashcardIndex < currentFlashcards.count - 1 {
                                        currentFlashcardIndex += 1
                                    }
                                }
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(currentFlashcardIndex < currentFlashcards.count - 1 ? Color.purple : Color.gray)
                                    .cornerRadius(25)
                            }
                            .disabled(currentFlashcardIndex == currentFlashcards.count - 1)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                } else {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "rectangle.stack")
                            .font(.system(size: 64))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No Flashcards")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.black)
                        Text("Flashcards will appear here")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 50)
                    }
                }
            } else {
                // Subject not found / Fallback
                VStack(spacing: 16) {
                    Image(systemName: "rectangle.stack")
                        .font(.system(size: 64))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("Subject Not Found")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .navigationTitle("Flashcards")
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
