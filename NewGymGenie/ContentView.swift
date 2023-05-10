//
//  ContentView.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/3/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    @StateObject private var workoutData = WorkoutData()
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var videoData = VideoData()
    @State private var showSplashScreen: Bool = true
    
    init() {
            workoutData.fetchRecentWorkouts()
            profileViewModel.fetchUserData()
            videoData.fetchRecentVideos()
        }

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
                GreetingView(userName: "User")
                    .environmentObject(workoutData)
                    .environmentObject(profileViewModel)
                    .environmentObject(videoData)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
