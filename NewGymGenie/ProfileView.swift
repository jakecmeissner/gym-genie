//
//  ProfileView.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/3/23.
//

// ProfileView.swift
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import AVKit
import AVFoundation
import Foundation

let color1 = Color(hex: "#604573")
let color2 = Color(hex: "#6258A6")
let color3 = Color(hex: "#4E8BBF")
let color4 = Color(hex: "#55B3D9")
let color5 = Color(hex: "#3FBFB2")

struct ProfileView: View {
    @EnvironmentObject var recentWorkoutsData: RecentWorkoutsData
    @EnvironmentObject var workoutData: WorkoutData
    @EnvironmentObject var videoData: VideoData // Add this line
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @State private var editMode = false
    @State private var userWorkouts: [Workout] = []
    @State private var selectedWorkout: Workout?
    @State private var showingWorkoutDetails = false
    @State private var isShowingWorkoutDetail = false // Add this line
    @State private var selectedView: Int = 1
    @State private var selectedVideo: Video? // Add this property
    @State private var isShowingVideoPlayer = false // Add this line
    @State private var isVideoPlayerPresented = false
    @State private var selectedVideoId: String? = nil
    @State private var selectedEditProfileView: EditProfileView?
    @State private var isEditProfilePresented = false

    private var groupedWorkouts: [Date: [Workout]] {
        Dictionary(grouping: workoutData.recentWorkouts, by: { $0.date.startOfDay })
    }
    
    private var groupedWorkoutsByBodyPart: [Date: [String: [Workout]]] {
        Dictionary(grouping: workoutData.recentWorkouts, by: { $0.date.startOfDay }).mapValues { workouts in
            Dictionary(grouping: workouts, by: { $0.preset })
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    header
                    picker
                    ZStack {
                        if selectedView == 0 {
                            workoutList
                                .opacity(selectedView == 0 ? 1 : 0)
                        }
                        
                        if selectedView == 1 {
                            videoSlider
                                .opacity(selectedView == 1 ? 1 : 0)
                        }
                    }
                }
                .padding(.horizontal, 5)
                .padding(.top, 30)
                .dragToChange(selectedView: $selectedView)
            }
            .padding(.bottom, 120)
            .edgesIgnoringSafeArea(.top)
            .onAppear {
                profileViewModel.fetchUserData()
                videoData.fetchUserVideos() // Add this line
            }
            
            if isShowingWorkoutDetail, let selectedWorkout = selectedWorkout {
                WorkoutDetailCard(workout: selectedWorkout, isShowingWorkoutDetail: $isShowingWorkoutDetail)
                    .onTapGesture {
                        withAnimation {
                            isShowingWorkoutDetail = false
                        }
                    }
            }
        }
    }

    var header: some View {
        let buttonGradient = LinearGradient(gradient: Gradient(colors: [color1, color2, color3]), startPoint: .leading, endPoint: .trailing)
        let headerGradient = LinearGradient(gradient: Gradient(colors: [color2, color5]), startPoint: .topLeading, endPoint: .bottomTrailing)

        return VStack {
            ZStack {
                headerGradient
                    .edgesIgnoringSafeArea(.top)
                    .clipShape(RoundedRectangle(cornerRadius: 40
                                               )) // Add this line for slightly rounded corners

                VStack {

                    HStack {
                        Image(systemName: "gear")
                            .foregroundColor(.white)

                        Spacer()

                        Image("placeholder")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())

                        Spacer()

                        Image(systemName: "bell")
                            .foregroundColor(.white)
                    }
                    .padding(.top, 13)
                    .padding(.horizontal)

                    Text(profileViewModel.user.name)
                        .font(Font.custom("Poppins-Regular", size: 24))
                        .foregroundColor(.white)
                        .padding(.top, 3)

                    Text("@" + profileViewModel.user.username.lowercased())
                        .font(Font.custom("Poppins-Light", size: 18))
                        .foregroundColor(.white)

                    HStack {
                        Text(flag(countryCode: profileViewModel.user.countryCode))
                            .font(.system(size: 14))
                        Text(profileViewModel.user.country)
                            .font(Font.custom("Poppins-Light", size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 0)

                    HStack {
                        VStack {
                            Text("Following")
                                .font(Font.custom("Poppins-Light", size: 14))
                                .foregroundColor(.white)

                            Text("\(profileViewModel.user.following)")
                                .font(Font.custom("Poppins-Light", size: 18))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        if profileViewModel.isCurrentUser {
                            Button(action: {
                                isEditProfilePresented = true
                            }) {
                                Text("EDIT PROFILE")
                                    .font(Font.custom("Poppins-Bold", size: 14))
                                    .foregroundColor(color3)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 10)))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(buttonGradient, lineWidth: 2)
                                    )
                            }
                            .sheet(isPresented: $isEditProfilePresented) {
                                EditProfileView()
                            }
                        }
                        Spacer()

                        VStack {
                            Text("Followers")
                                .font(Font.custom("Poppins-Light", size: 14))
                                .foregroundColor(.white)

                            Text("\(profileViewModel.user.followers)")
                                .font(Font.custom("Poppins-Light", size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 0)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 23)
    }
    
    var picker: some View {
        Picker("", selection: $selectedView) {
            Text("Videos")
                .tag(1)
            Text("Workouts")
                .tag(0)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .onAppear {
            self.selectedView = 1 // Add this line to set the initial value
        }
    }
    
    func flag(countryCode: String) -> String {
        var string = ""
        countryCode.uppercased().unicodeScalars.forEach {
            if let scalar = UnicodeScalar(127397 + $0.value) {
                string.unicodeScalars.append(scalar)
            }
        }
        return string
    }
    func getStatusBarHeight() -> CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            return windowScene.statusBarManager?.statusBarFrame.height ?? 0
        }
        return 0
    }
    var workoutList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 44) {
                let groupedWorkoutsByBodyPart: [Date: [String: [Workout]]] = Dictionary(grouping: workoutData.recentWorkouts, by: { $0.date.startOfDay }).mapValues { workouts in
                    Dictionary(grouping: workouts, by: { $0.preset })
                }

                ForEach(groupedWorkoutsByBodyPart.keys.sorted(by: >), id: \.self) { date in
                    let columns: [GridItem] = [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ]

                    VStack(alignment: .leading) {
                        Text(date.dateString)
                            .font(Font.custom("Poppins-Regular", size: 18))
                            .foregroundColor(color3)
                            .padding(.bottom, 5)

                        if let workoutsForDate = groupedWorkoutsByBodyPart[date] {
                            ForEach(workoutsForDate.keys.sorted(), id: \.self) { key in
                                let workouts = workoutsForDate[key]!

                                Text("Body Part: \(key)")
                                    .font(Font.custom("Poppins-Light", size: 14))
                                    .foregroundColor(.gray)

                                LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                                    ForEach(workouts, id: \.id) { workout in
                                        WorkoutCard(workout: workout, selectedWorkout: $selectedWorkout, isShowingWorkoutDetail: $isShowingWorkoutDetail)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    var videoSlider: some View {
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
        
        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(videoData.recentVideos) { video in
                NavigationLink(destination: VideoPlayerView(videoURL: video.videoURL, currentVideoIndex: .constant(nil), index: nil)) {
                    VStack(alignment: .leading, spacing: 10) {
                        // Display the thumbnail
                        if let thumbnail = video.thumbnail {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: UIScreen.main.bounds.width / 3 - 20, minHeight: UIScreen.main.bounds.height / 6 - 20)
                                .clipped()
                        } else {
                            // Fallback to placeholder image if the thumbnail is missing
                            Image("placeholder")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: UIScreen.main.bounds.width / 3 - 20, minHeight: UIScreen.main.bounds.height / 6 - 20)
                                .clipped()
                        }
                    }
                    .padding(.bottom, 10)
                }
            }
        }
    }
    struct WorkoutCard: View {
        let workout: Workout
        @Binding var selectedWorkout: Workout?
        @Binding var isShowingWorkoutDetail: Bool

        var body: some View {
            Button(action: {
                withAnimation {
                    selectedWorkout = workout
                    isShowingWorkoutDetail = true
                }
            }) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(
                        VStack(alignment: .leading) {
                            Text(workout.workoutName)
                                .font(.headline)
                        }
                        .padding()
                    )
                    .frame(width: 110, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(LinearGradient(gradient: Gradient(colors: [color2, color5]), startPoint: .top, endPoint: .bottom), lineWidth: 2)
                    )
            }
            .buttonStyle(PlainButtonStyle()) // Add this line to remove default button styling
        }
    }
    struct WorkoutDetailCard: View {
        let workout: Workout
        @Binding var isShowingWorkoutDetail: Bool

        var body: some View {
            VStack {
                VStack(alignment: .leading) {
                    Text(workout.workoutName)
                        .font(.system(size: 48)) // Increased font size
                        .padding(.bottom, 10) // Increased spacing
                    Text("Weight: \(workout.weight) lbs")
                        .font(.system(size: 24)) // Increased font size
                    Text("Sets: \(workout.sets)")
                        .font(.system(size: 24)) // Increased font size
                    Text("Reps: \(workout.reps)")
                        .font(.system(size: 24)) // Increased font size
                }
                .padding()
            }
            .frame(width: 350, height: 250) // Increased height
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
        }
    }
    func playVideo(videoURL: String) {
        guard let url = URL(string: videoURL) else { return }
        let player = AVPlayer(url: url)
        let playerController = AVPlayerViewController()
        playerController.player = player

        if let topViewController = UIApplication.shared.topViewController() {
            topViewController.present(playerController, animated: true) {
                player.play()
            }
        }
    }
}
extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: self)
    }
}
// Add this extension outside the ProfileView struct
extension UIApplication {
    func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
                                .compactMap { $0 as? UIWindowScene }
                                .first?.windows.first?.rootViewController) -> UIViewController? {
        if let navigationController = base as? UINavigationController {
            return topViewController(base: navigationController.visibleViewController)
        }
        if let tabBar = base as? UITabBarController, let selected = tabBar.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
struct DragToChange: ViewModifier {
    @Binding var selectedView: Int
    let threshold: CGFloat

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: threshold)
                    .onEnded { value in
                        if value.translation.width < -threshold {
                            selectedView = (selectedView + 1) % 2
                        } else if value.translation.width > threshold {
                            selectedView = (selectedView - 1 + 2) % 2
                        }
                    }
            )
    }
}
extension View {
    func dragToChange(selectedView: Binding<Int>, threshold: CGFloat = 50) -> some View {
        self.modifier(DragToChange(selectedView: selectedView, threshold: threshold))
    }
}
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(RecentWorkoutsData())
            .environmentObject(WorkoutData()) // Add this line
            .environmentObject(VideoData()) // Add this line
    }
}


