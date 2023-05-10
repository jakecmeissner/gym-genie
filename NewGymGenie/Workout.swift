//
//  Workout.swift
//  NewGymGenie
//
//  Created by Jake Meissner on 4/13/23.
//

// Workout.swift
import FirebaseFirestore

struct Workout: Identifiable {
    var id: String
    var workoutName: String
    var weight: Int
    var sets: Int
    var reps: Int
    var date: Date
    var preset: String // Add this line

    init?(data: [String: Any]) {
        guard let id = data["id"] as? String,
              let workoutName = data["workoutName"] as? String,
              let weight = data["weight"] as? Int,
              let sets = data["sets"] as? Int,
              let reps = data["reps"] as? Int,
              let date = (data["date"] as? Timestamp)?.dateValue(),
              let preset = data["preset"] as? String else { return nil } // Add this line

        self.id = id
        self.workoutName = workoutName
        self.weight = weight
        self.sets = sets
        self.reps = reps
        self.date = date
        self.preset = preset // Add this line
    }

    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
}




