import SwiftUI

struct SideMenuView: View {
    @Binding var isShowing: Bool
    var onSelectSubject: () -> Void
    var onSelectStudyPlan: () -> Void
    
    var body: some View {
        ZStack {
            if isShowing {
                VStack(spacing: 0) {
                    // Close Button Area
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation { isShowing = false }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.black.opacity(0.6))
                                .padding(20)
                        }
                    }
                    .padding(.top, 40)
                    
                    ScrollView {
                        VStack(alignment: .center, spacing: 40) {
                            // Header
                            VStack(spacing: 12) {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.black.opacity(0.8))
                                
                                Text("Welcome back")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black.opacity(0.8))
                            }
                            .padding(.top, 20)
                            
                            // Menu Items
                            VStack(spacing: 20) {
                                FullScreenMenuRow(icon: "book.fill", text: "Subjects", color: .blue) {
                                    withAnimation { isShowing = false }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        onSelectSubject()
                                    }
                                }
                                
                                FullScreenMenuRow(icon: "calendar", text: "Study Plan", color: .orange) {
                                    withAnimation { isShowing = false }
                                    onSelectStudyPlan()
                                }
                                
                                FullScreenMenuRow(icon: "star.fill", text: "Achievements", color: .yellow) {
                                    // Placeholder
                                }
                                
                                FullScreenMenuRow(icon: "gearshape.fill", text: "Settings", color: .gray) {
                                    // Placeholder
                                }
                            }
                            .padding(.horizontal, 40)
                            
                            Spacer(minLength: 50)
                            
                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(.black.opacity(0.4))
                        }
                        .padding(.bottom, 40)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(GrainBackground())
                .transition(.move(edge: .top))
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0), value: isShowing)
        .ignoresSafeArea()
    }
}

struct FullScreenMenuRow: View {
    let icon: String
    let text: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                
                Text(text)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.black.opacity(0.8))
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black.opacity(0.3))
            }
            .padding(20)
            .background(Color.white.opacity(0.5))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

struct GrainBackground: View {
    var body: some View {
        ZStack {
            // Gradient Base
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.95, blue: 1.0),
                    Color(red: 0.90, green: 0.92, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Grain Effect (Simulated with Canvas)
            Canvas { context, size in
                let rect = CGRect(origin: .zero, size: size)
                context.fill(Path(rect), with: .color(.white.opacity(0.3)))
                
                // Draw simplified noise points
                // Reduced density for performance
                let width = Int(size.width)
                let height = Int(size.height)
                let stride = 4 // Skip pixels for performance
                
                for y in Swift.stride(from: 0, to: height, by: stride) {
                    for x in Swift.stride(from: 0, to: width, by: stride) {
                        if Bool.random() {
                            let pointRect = CGRect(x: x, y: y, width: 1, height: 1)
                            context.fill(Path(pointRect), with: .color(.black.opacity(0.03)))
                        }
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }
}
