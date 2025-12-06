import SwiftUI

struct CategoryPlaceholderView: View {
    let category: SubjectCategory
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: category.icon)
                        .font(.system(size: 80))
                        .foregroundColor(category.color)
                    
                    Text("Hello World")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("Coming Soon")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle(category.rawValue)
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
}
