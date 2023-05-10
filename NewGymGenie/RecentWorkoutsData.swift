//
//  RecentWorkouts.swift
//  NewGymGenie
//
//  Created by Jake Meissner on 4/13/23.
//

// RecentWorkoutsData.swift
import SwiftUI
import FirebaseFirestore

class RecentWorkoutsData: ObservableObject {
    @Published var recentWorkouts: [Workout] = []
    var workoutsGroupedByDate: [String: [Workout]] {
        Dictionary(grouping: recentWorkouts) { $0.formattedDate }
    }
}



