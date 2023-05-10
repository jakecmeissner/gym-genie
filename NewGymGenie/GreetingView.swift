//
//  GreetingView.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/3/23.
//

// GreetingView.swift
import SwiftUI
import FirebaseStorage

struct GreetingView: View {
    @StateObject var profileViewModel = ProfileViewModel()
    @StateObject var workoutData = WorkoutData() // Add this line
    @ObservedObject var videoData = VideoData() // Replace @StateObject with @ObservedObject
    @State private var isVideoPickerPresented = false
    @State private var selectedVideoURL: URL?
    let userName: String
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = 0
    let appAccentColor = Color(red: 255/255, green: 8/255, blue: 120/255)
    let appAccentColorLighter = Color(red: 255/255, green: 105/255, blue: 140/255)

    let color1 = Color(hex: "#604573")
    let color2 = Color(hex: "#6258A6")
    let color3 = Color(hex: "#4E8BBF")
    let color4 = Color(hex: "#55B3D9")
    let color5 = Color(hex: "#3FBFB2")

    var body: some View {
        VStack {
            VStack {
                switch selectedTab {
                case 0:
                    VStack {
                        HStack {
                            Image("placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                                .padding(.trailing, 20)

                            Text("Hello, \(userName)!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.top)
                        .padding(.horizontal)
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [color4, color5]), startPoint: .top, endPoint: .bottom))
                        
                        HomeView()
                            .padding(.top, -8) // Update this line
                            .padding(.bottom)
                            .background(Color.clear)
                            .environmentObject(workoutData)
                            .environmentObject(videoData)
                    }
                case 1:
                    FeedView()
                case 2:
                    WorkoutsView()
                case 3:
                    ProfileView()
                        .navigationViewStyle(.stack)
                        .environmentObject(workoutData)
                        .environmentObject(videoData)
                        .environmentObject(profileViewModel)
                        .onAppear {
                            profileViewModel.fetchUserData()
                            videoData.fetchRecentVideos()
                        }
                default:
                    Text("Invalid Selection")
                }
            }
            .padding(.top)

            Spacer()
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .edgesIgnoringSafeArea(.all)
        .overlay(CustomTabBar(selectedTab: $selectedTab), alignment: .bottom)
        .sheet(isPresented: $isVideoPickerPresented) {
            ImagePicker(sourceType: .photoLibrary, mediaTypes: [.video], onPickedMedia: { media in
                selectedVideoURL = media.url
                uploadVideo()
            }, onDismiss: {})
        }
    }

    func uploadVideo() {
        guard let videoURL = selectedVideoURL else { return }

        let storage = Storage.storage()
        let storageRef = storage.reference()
        let videoRef = storageRef.child("videos/\(UUID().uuidString).mp4")

        let uploadTask = videoRef.putFile(from: videoURL, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading video: \(error.localizedDescription)")
            } else {
                print("Video uploaded successfully")
            }
        }

        uploadTask.observe(.progress) { snapshot in
            print("Upload progress: \(snapshot.progress?.fractionCompleted ?? 0)")
        }
    }
}

struct GreetingView_Previews: PreviewProvider {
    static var previews: some View {
        GreetingView(userName: "Donna")
    }
}


