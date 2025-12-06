import SwiftUI

struct ExemplarsListView: View {
    @ObservedObject var subjectsManager: SubjectsManager
    let subject: Subject
    @Environment(\.dismiss) var dismiss
    @State private var selectedExemplar: Exemplar?
    @State private var showExemplarDetail = false
    
    var currentSubject: Subject? {
        subjectsManager.subjects.first(where: { $0.id == subject.id })
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.98)
                .ignoresSafeArea()
            
            if let currentSubject = currentSubject {
                if !currentSubject.exemplarsText.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(currentSubject.exemplarsText)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .padding()
                        }
                    }
                } else if !currentSubject.exemplars.isEmpty {
                    List {
                        ForEach(currentSubject.exemplars) { exemplar in
                            Button(action: {
                                selectedExemplar = exemplar
                                showExemplarDetail = true
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(exemplar.title)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.black)
                                    
                                    Text(exemplar.problemText)
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                        .lineLimit(3)
                                    
                                    if !exemplar.tags.isEmpty {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 6) {
                                                ForEach(exemplar.tags, id: \.self) { tag in
                                                    Text(tag)
                                                        .font(.system(size: 11))
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .background(Color.green.opacity(0.1))
                                                        .foregroundColor(.green)
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
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 64))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No Exemplars")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.black)
                        Text("Exemplar problems will appear here")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 50)
                    }
                }
            } else {
                // Fallback if subject not found
                 VStack(spacing: 16) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 64))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("Subject Not Found")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .navigationTitle("Exemplars")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $showExemplarDetail) {
            if let exemplar = selectedExemplar {
                NavigationView {
                    ExemplarDetailView(exemplar: exemplar)
                }
            }
        }
    }
}

struct ExemplarDetailView: View {
    let exemplar: Exemplar
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(exemplar.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                Divider()
                
                // Problem
                VStack(alignment: .leading, spacing: 12) {
                    Text("Problem")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(exemplar.problemText)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 20)
                
                // Solution
                if let solutionText = exemplar.solutionText, !solutionText.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Solution")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text(solutionText)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Tags
                if !exemplar.tags.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(exemplar.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 13))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.green.opacity(0.1))
                                    .foregroundColor(.green)
                                    .cornerRadius(12)
                            }
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

// Helper view for flow layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}
