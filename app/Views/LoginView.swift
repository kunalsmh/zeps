import SwiftUI
import GoogleSignIn
import Supabase

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var userName: String
    
    @State private var emoji1Offset: CGFloat = 0
    @State private var emoji2Offset: CGFloat = 0
    @State private var emoji3Offset: CGFloat = 0
    @State private var currentTaglineIndex: Int = 0
    @State private var taglineOpacity: Double = 0
    
    let emoji1: String
    let emoji2: String
    let emoji3: String
    
    let taglines = [
        "The only app you need for every study resource.",
        "Made by students for the students.",
        "Every study resource without 100s of ad popups."
    ]
    
    init(isLoggedIn: Binding<Bool>, userName: Binding<String>) {
        self._isLoggedIn = isLoggedIn
        self._userName = userName
        
        // Pick random emojis once on init
        self.emoji1 = ["🚀", "✨", "📚", "💡", "🎉"].randomElement()!
        self.emoji2 = ["👋", "❤️", "🔥", "✌️", "🫡"].randomElement()!
        self.emoji3 = ["😴", "🤓", "👀", "🙄", "🎨"].randomElement()!
        
        // Shuffle taglines
        _currentTaglineIndex = State(initialValue: Int.random(in: 0..<3))
    }
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                // Floating Emojis in Rainbow Curve
                VStack(spacing: 20) {
                    HStack(spacing: 40) {
                        Text(emoji1)
                            .font(.system(size: 80))
                            .offset(y: emoji1Offset - 20)
                        
                        Text(emoji2)
                            .font(.system(size: 80))
                            .offset(y: emoji2Offset - 40)
                        
                        Text(emoji3)
                            .font(.system(size: 80))
                            .offset(y: emoji3Offset - 20)
                    }
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                            emoji1Offset = 15
                        }
                        withAnimation(Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                            emoji2Offset = 20
                        }
                        withAnimation(Animation.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                            emoji3Offset = 15
                        }
                        
                        // Start tagline animation
                        withAnimation(.easeIn(duration: 0.8)) {
                            taglineOpacity = 1
                        }
                        
                        // Rotate taglines
                        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
                            withAnimation(.easeOut(duration: 0.5)) {
                                taglineOpacity = 0
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                currentTaglineIndex = (currentTaglineIndex + 1) % taglines.count
                                withAnimation(.easeIn(duration: 0.5)) {
                                    taglineOpacity = 1
                                }
                            }
                        }
                    }
                    
                    VStack(spacing: 10) {
                        Text("Welcome to Zeps")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text(taglines[currentTaglineIndex])
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .opacity(taglineOpacity)
                            .frame(height: 50)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    // Google Sign-In Button
                    Button(action: {
                        handleSignIn()
                    }) {
                        HStack(spacing: 12) {
                            // Google "G" Logo (Simulated with text/color for now)
                            Text("G")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                                .background(Color.white)
                                .clipShape(Circle())
                            
                            Text("Sign in with Google")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                    }
                    .padding(.horizontal, 40)
                    
                    // Terms & Conditions
                    Link("Terms & Conditions", destination: URL(string: "https://kunalsh.com/terms")!)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 60)
            }
        }
    }
    
    func handleSignIn() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Error: Root view controller not found")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }
            
            guard let user = signInResult?.user else {
                print("Error: No user found")
                return
            }
            
            // Get user's name
            userName = user.profile?.givenName ?? user.profile?.name ?? "User"
            
            // Save to UserDefaults
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(user.profile?.email, forKey: "userEmail")
            UserDefaults.standard.set(userName, forKey: "userName")
            UserDefaults.standard.set(user.userID, forKey: "userID")
            
            // Save user to Supabase
            Task {
                await saveUserToSupabase(
                    id: user.userID ?? "",
                    email: user.profile?.email ?? "",
                    name: user.profile?.name ?? ""
                )
            }
            
            // If sign in succeeded, display the main content View.
            withAnimation {
                isLoggedIn = true
            }
        }
    }
    
    @MainActor
    private func saveUserToSupabase(id: String, email: String, name: String) async {
        let supabase = SupabaseConfig.shared.client
        
        struct UserProfile: Encodable {
            let id: String
            let email: String
            let name: String
            let last_login: Date
        }
        
        let profile = UserProfile(id: id, email: email, name: name, last_login: Date())
        
        do {
            // Upsert user (insert or update if exists)
            try await supabase.database
                .from("users")
                .upsert(profile)
                .execute()
            print("User saved to Supabase successfully")
        } catch {
            print("Error saving user to Supabase: \(error)")
        }
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false), userName: .constant("User"))
}
