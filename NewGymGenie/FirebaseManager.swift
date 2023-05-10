//
//  FirebaseManager.swift
//  NewGymGenie
//
//  Created by Jake Meissner on 4/13/23.
//

// FirebaseManager.swift
import Foundation
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private init() {}
    
    func uploadVideoAndSaveUrl(userId: String, videoData: Data, completion: @escaping (Error?) -> Void) {
        // Create a unique filename based on the user's ID and the current timestamp
        let filename = "\(userId)-\(Date().timeIntervalSince1970).mp4"
        
        // Create a reference to the Firebase Storage location where the video will be uploaded
        let storageRef = Storage.storage().reference().child("videos").child(filename)
        
        // Upload the video data to Firebase Storage
        storageRef.putData(videoData, metadata: nil) { (_, error) in
            if let error = error {
                completion(error)
                return
            }
            
            // Get the video URL from Firebase Storage
            storageRef.downloadURL { (result) in
                switch result {
                    case .success(_):
                        // Save the video URL and other video data to Firestore
                        let video = Video(id: "", title: "Sample Title", description: "Sample Description", uploadDate: Date(), fileLocationURL: storageRef.fullPath, userID: userId)
                        let db = Firestore.firestore()
                        db.collection("videos").addDocument(data: video.dictionary) { error in
                            completion(error)
                        }

                    case .failure(let error):
                        completion(error)
                }
            }
        }
    }
    
    func uploadImageAndSaveUrl(userId: String, imageData: Data, completion: @escaping (Error?) -> Void) {
        // Create a unique filename based on the user's ID and the current timestamp
        let filename = "\(userId)-\(Date().timeIntervalSince1970).jpg"
        
        // Create a reference to the Firebase Storage location where the image will be uploaded
        let storageRef = Storage.storage().reference().child("images").child(filename)
        
        // Upload the image data to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { (_, error) in
            if let error = error {
                completion(error)
                return
            }
            
            // Get the image URL from Firebase Storage
            storageRef.downloadURL { (result) in
                switch result {
                case .success(_):
                    // Save the image URL and other image data to Firestore
                    let image = CustomImage(id: "", title: "Sample Title", description: "Sample Description", uploadDate: Date(), fileLocationURL: storageRef.fullPath, userID: userId)
                    let db = Firestore.firestore()
                    db.collection("images").addDocument(data: image.dictionary) { error in
                        completion(error)
                    }
                    
                case .failure(let error):
                    completion(error)
                }
            }
        }
    }
}

extension Video {
    var dictionary: [String: Any] {
        return [
            "title": title,
            "description": description,
            "uploadDate": uploadDate,
            "fileLocationURL": fileLocationURL,
            "userID": userID
        ]
    }
}

// New Image model extension for creating a dictionary of the image data
extension CustomImage {
    var dictionary: [String: Any] {
        return [
            "title": title,
            "description": description,
            "uploadDate": uploadDate,
            "fileLocationURL": fileLocationURL,
            "userID": userID
        ]
    }
}





