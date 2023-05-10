//
//  FeedView.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/3/23.
//

// FeedView.swift
import SwiftUI
import AVKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import SwiftUIPager

class FeedViewModel: ObservableObject {
    @Published var videos: [Video] = []
    @Published var currentVideoIndex: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchVideos() {
        let db = Firestore.firestore()
        db.collection("videos").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching videos: \(error.localizedDescription)")
            } else {
                if let documents = querySnapshot?.documents {
                    print("Fetched \(documents.count) videos")
                    
                    let group = DispatchGroup()
                    
                    for document in documents {
                        if let video = Video(document: document) {
                            print("Processing video: \(video.id)")
                            group.enter()
                            self.downloadVideoURL(for: video) { url in
                                if let url = url {
                                    let updatedVideo = Video(id: video.id, title: video.title, description: video.description, uploadDate: video.uploadDate, fileLocationURL: url.absoluteString, userID: video.userID)
                                    DispatchQueue.main.async {
                                        self.videos.append(updatedVideo)
                                    }
                                    print("Added video: \(updatedVideo.id)")
                                }
                                group.leave()
                            }
                        }
                    }
                    
                    group.notify(queue: .main) {
                        self.videos.sort(by: { $0.uploadDate > $1.uploadDate })
                        print("Sorted videos")
                    }
                } else {
                    print("No documents found in the videos collection")
                }
            }
        }
    }
    
    func downloadVideoURL(for video: Video, completion: @escaping (URL?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: video.fileLocationURL)
        storageRef.downloadURL(completion: { (url, error) in
            if let error = error {
                print("Error downloading video URL: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(url)
            }
        })
    }
}

struct FeedView: View {
    @StateObject private var feedViewModel = FeedViewModel()
    private let tabBarHeight: CGFloat = 30 // Replace this with your CustomTabBar height

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    if !feedViewModel.videos.isEmpty {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {
                                ForEach(Array(feedViewModel.videos.indices), id: \.self) { index in
                                    if let url = URL(string: feedViewModel.videos[index].fileLocationURL) {
                                        VideoPlayerView(videoURL: url, currentVideoIndex: .constant(feedViewModel.currentVideoIndex), index: index)
                                            .frame(width: geometry.size.width, height: geometry.size.height - tabBarHeight)
                                            .edgesIgnoringSafeArea(.all)
                                    } else {
                                        Text("Video not found")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    if value.translation.height < -100 {
                                        feedViewModel.currentVideoIndex = min(feedViewModel.currentVideoIndex + 1, feedViewModel.videos.count - 1)
                                    } else if value.translation.height > 100 {
                                        feedViewModel.currentVideoIndex = max(feedViewModel.currentVideoIndex - 1, 0)
                                    }
                                }
                        )
                    } else {
                        Text("No videos available")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                            .edgesIgnoringSafeArea(.all)
                    }
                }
                .onAppear {
                    feedViewModel.fetchVideos()
                }
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}







