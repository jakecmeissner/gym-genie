//
//  ProfileViewModel.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/7/23.
//

// ProfileViewModel.swift
import SwiftUI
import AVKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var userVideos: [Video] = [] // Use Video instead of UserVideo
    @Published var isCurrentUser: Bool = false
    
    private var db = Firestore.firestore()
    
    init() {
        user = User(id: "", name: "", username: "", country: "", following: 0, followers: 0)
        fetchUserData()
    }
    
    func fetchUserData() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }
        
        let userID = currentUser.uid
        isCurrentUser = true
        
        db.collection("users").document(userID).getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            } else {
                if let documentSnapshot = documentSnapshot, let data = documentSnapshot.data() {
                    self.user.id = documentSnapshot.documentID
                    self.user.name = data["name"] as? String ?? ""
                    self.user.username = data["username"] as? String ?? ""
                    self.user.country = data["country"] as? String ?? ""
                    self.user.following = data["following"] as? Int ?? 0
                    self.user.followers = data["followers"] as? Int ?? 0
                }
            }
        }
    }
    
    func fetchUserVideos() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }
        
        let userID = currentUser.uid
        
        db.collection("videos")
            .whereField("userID", isEqualTo: userID)
            .order(by: "date", descending: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching user videos: \(error.localizedDescription)")
                } else {
                    if let documents = querySnapshot?.documents {
                        self.userVideos = documents.compactMap { (queryDocumentSnapshot) -> Video? in
                            var data = queryDocumentSnapshot.data()
                            data["id"] = queryDocumentSnapshot.documentID
                            return Video(data: data)
                        }
                    }
                }
            }
    }
    
    struct User {
        var id: String
        var name: String
        var username: String
        var country: String
        var following: Int
        var followers: Int

        var countryCode: String {
            let locales: [String: String] = NSLocale.isoCountryCodes.reduce(into: [:]) { (result, countryCode) in
                if let country = Locale.current.localizedString(forRegionCode: countryCode) {
                    result[country] = countryCode
                }
            }

            return locales[country] ?? ""
        }
    }

    
    struct Video: Identifiable {
        var id: String
        var title: String
        var url: URL?
        
        init(data: [String: Any]) {
            id = data["id"] as? String ?? ""
            title = data["title"] as? String ?? ""
            
            if let urlString = data["url"] as? String {
                url = URL(string: urlString)
            }
        }
    }
    
    func downloadVideoURL(for video: Video, completion: @escaping (URL?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: video.url!.absoluteString)
        storageRef.downloadURL(completion: { (url, error) in
            if let error = error {
                print("Error downloading video URL: \(error.localizedDescription)")
                completion(nil)
            } else {
                if let unwrappedURL = url {
                    print("Downloaded video URL: \(unwrappedURL)")
                    completion(unwrappedURL)
                } else {
                    completion(nil)
                }
            }
        })
    }

    // Function to convert country name to country code
    func countryCode(for countryName: String) -> String {
        let locales: [String: String] = NSLocale.isoCountryCodes.reduce(into: [:]) { (result, countryCode) in
            if let country = Locale.current.localizedString(forRegionCode: countryCode) {
                result[country] = countryCode
            }
        }

        return locales[countryName] ?? ""
    }
}








