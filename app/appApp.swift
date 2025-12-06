//
//  appApp.swift
//  app
//
//  Created by Kunal Sharma on 05/12/25.
//

import SwiftUI
import SwiftData
import GoogleSignIn

@main
struct appApp: App {
    @State private var isLoggedIn: Bool = false
    @State private var userName: String = "User"
    @StateObject private var subjectsManager = SubjectsManager()
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView(isLoggedIn: $isLoggedIn, subjectsManager: subjectsManager, userName: userName)
                    .transition(.opacity)
            } else {
                LoginView(isLoggedIn: $isLoggedIn, userName: $userName)
                    .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                    }
                    .onAppear {
                        restorePreviousSignIn()
                    }
            }
        }
    }
    
    func restorePreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let user = user {
                // User is already signed in
                userName = user.profile?.givenName ?? user.profile?.name ?? "User"
                isLoggedIn = true
            }
        }
    }
}
