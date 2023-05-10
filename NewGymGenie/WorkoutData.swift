//
//  WorkoutData.swift
//  NewGymGenie
//
//  Created by Jake Meissner on 4/15/23.
//

// WorkoutData.swift
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class WorkoutData: ObservableObject {
    @Published var recentWorkouts: [Workout] = []

    func fetchRecentWorkouts() {
        print("Starting to fetch recent workouts")
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }
        let userID = user.uid

        let db = Firestore.firestore()
        db.collection("workouts")
            .whereField("userID", isEqualTo: userID)
            .order(by: "date", descending: true)
//            .limit(to: )
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching recent workouts: \(error.localizedDescription)")
                } else {
                    self.recentWorkouts = querySnapshot?.documents.compactMap { document in
                        var data = document.data()
                        data["id"] = document.documentID
                        return Workout(data: data)
                    }.compactMap { $0 } ?? []

                    // Add print statement here to check fetched data
                    print("Fetched recent workouts: \(self.recentWorkouts)")
                }
            }
    }
}




