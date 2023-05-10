//
//  VideoData.swift
//  NewGymGenie
//
//  Created by Jake Meissner on 4/18/23.
//

// VideoData.swift
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import AVKit

class VideoData: ObservableObject {
    @Published var recentVideos: [Video] = []

    func fetchRecentVideos() {
        print("Fetching user videos: ")
        let db = Firestore.firestore()

        db.collection("videos").order(by: "uploadDate", descending: true).limit(to: 10).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching recent videos: \(error)")
                DispatchQueue.main.async {
                    self.recentVideos = []
                }
                return
            }

            let group = DispatchGroup()

            var videos = [Video]()
            for document in snapshot!.documents {
                if var video = Video(document: document) {
                    if let videoURL = video.videoURL {
                        group.enter()
                        if let thumbnail = self.generateThumbnail(from: videoURL) {
                            video.thumbnail = thumbnail
                        }
                        videos.append(video)
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main) {
                self.recentVideos = videos
                print("Fetched recent videos: \(videos)")
            }
        }
    }
    
    func fetchUserVideos() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        db.collection("videos")
            .whereField("uid", isEqualTo: user.uid)
            .order(by: "uploadDate", descending: true)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching user videos: \(error)")
                    DispatchQueue.main.async {
                        self.recentVideos = []
                    }
                    return
                }

                let group = DispatchGroup()

                var videos = [Video]()
                for document in snapshot!.documents {
                    print("Processing video document: \(document.data())") // Add this line
                    if var video = Video(document: document) {
                        if let videoURL = video.videoURL {
                            group.enter()
                            if let thumbnail = self.generateThumbnail(from: videoURL) {
                                video.thumbnail = thumbnail
                            }
                            videos.append(video)
                            group.leave()
                        }
                    }
                }
                group.notify(queue: .main) {
                    self.recentVideos = videos
                    print("Fetched user videos: \(videos)")
                }
            }
    }

    func generateThumbnail(from url: URL) -> UIImage? {
        print("Generating thumbnail from URL: \(url)") // Add this line
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage
        } catch {
            print("Error generating thumbnail: \(error)")
            return nil
        }
    }
}







