//
//  EditProfileViewModel.swift
//  NewGymGenie
//
//  Created by Jake Meissner on 4/17/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class EditProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var country: String = ""
    
    private var db = Firestore.firestore()
    
    func fetchUserData() {
        if let user = Auth.auth().currentUser {
            let docRef = db.collection("users").document(user.uid)
            
            docRef.getDocument { document, error in
                if let document = document, document.exists {
                    let result = Result {
                        try document.data(as: User.self)
                    }
                    
                    switch result {
                    case .success(let user):
                        // No need for conditional binding here
                        self.name = user.name
                        self.username = user.username
                        self.country = user.country
                    case .failure(let error):
                        print("Error decoding user: \(error)")
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func updateUserProfile(completion: @escaping (Bool) -> Void) {
        if let user = Auth.auth().currentUser {
            let docRef = db.collection("users").document(user.uid)
            
            docRef.getDocument { document, error in
                if let document = document, document.exists {
                    let result = Result {
                        try document.data(as: User.self)
                    }
                    
                    switch result {
                    case .success(let fetchedUser):
                        let updatedUser = User(id: fetchedUser.id, name: self.name, username: self.username, country: self.country, following: fetchedUser.following, followers: fetchedUser.followers)
                        
                        do {
                            try docRef.setData(from: updatedUser) { error in
                                if let error = error {
                                    print("Error updating user: \(error)")
                                    completion(false)
                                } else {
                                    completion(true)
                                }
                            }
                        } catch let error {
                            print("Error encoding user: \(error)")
                            completion(false)
                        }
                    case .failure(let error):
                        print("Error decoding user: \(error)")
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}



