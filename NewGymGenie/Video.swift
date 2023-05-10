//
//  Video.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/6/23.
//

// Video.swift
import Foundation
import FirebaseFirestore
import UIKit // Import this for UIImage
import AVFoundation // Import this for AVAsset and AVAssetImageGenerator

struct Video: Identifiable, Equatable {
    var id: String
    var title: String
    var description: String
    var uploadDate: Date
    var fileLocationURL: String
    var userID: String
    var videoURL: URL?
    var thumbnailURL: String?
    var thumbnail: UIImage?
    var workoutTags: [String]? // Add this line

    init(id: String, title: String, description: String, uploadDate: Date, fileLocationURL: String, userID: String, thumbnailURL: String? = nil, workoutTags: [String]? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.uploadDate = uploadDate
        self.fileLocationURL = fileLocationURL
        self.userID = userID
        self.videoURL = nil
        self.thumbnailURL = thumbnailURL
        self.thumbnail = nil
        self.workoutTags = workoutTags // Add this line
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard let userID = data["userID"] as? String,
              let title = data["title"] as? String,
              let description = data["description"] as? String,
              let videoURLString = data["videoURL"] as? String,
              let videoURL = URL(string: videoURLString),
              let uploadDateTimestamp = data["uploadDate"] as? Timestamp
        else {
            print("Failed to parse video data: \(data)")
            return nil
        }

        self.id = document.documentID
        self.userID = userID
        self.title = title
        self.description = description
        self.videoURL = videoURL
        self.uploadDate = uploadDateTimestamp.dateValue()
        self.fileLocationURL = videoURLString
        self.thumbnail = nil
        self.workoutTags = data["workoutTags"] as? [String] // Add this line
    }
}
























