//
//  StartupView.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/4/23.
//

// StartupView.swift
import SwiftUI
import FirebaseAuth

struct StartupView: View {
    @State private var showSplashScreen: Bool = true
    @State private var showSignUp = false
    @State private var showSignIn = false

    var body: some View {
        ZStack {
            if showSplashScreen {
                SplashScreenView()
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.easeInOut(duration: 1.5)) {
                                showSplashScreen = false
                            }
                        }
                    }
            } else {
                if Auth.auth().currentUser == nil {
                    VStack {
                        Button("Sign Up") {
                            showSignUp = true
                        }
                        .sheet(isPresented: $showSignUp) {
                            SignUpView()
                        }
                        
                        Button("Sign In") {
                            showSignIn = true
                        }
                        .sheet(isPresented: $showSignIn) {
                            SignInView()
                        }
                    }
                } else {
                    GreetingView(userName: Auth.auth().currentUser?.email ?? "")
                }
            }
        }
    }
}

struct StartupView_Previews: PreviewProvider {
    static var previews: some View {
        StartupView()
    }
}



