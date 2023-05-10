//
//  WorkoutDescriptions.swift
//  NewGymGenie
//
//  Created by Jake Meissner on 4/23/23.
//

// WorkoutDescriptions.swift
import SwiftUI
import FirebaseFirestore

struct WorkoutDescriptionView: View {
    let workoutName: String
    let documentId: String
    @State private var workoutDescription: String = ""

    func fetchWorkoutDescription() {
        let db = Firestore.firestore()
        db.collection("workout_presets").document(documentId).getDocument { (document, error) in
            if let document = document,
               let workoutDescriptions = document.data()?["workout_descriptions"] as? [String: String] {
                workoutDescription = workoutDescriptions[workoutName] ?? "No description available."
            } else {
                print("Error fetching workout description: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(workoutName)
                    .font(.custom("Poppins-Bold", size: 30))
                    .foregroundColor(color1)
                    .padding(.top)

                let steps = workoutDescription.split(separator: "\n")
                ForEach(steps.indices, id: \.self) { index in
                    Text(String(steps[index]))
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.primary)
                        .lineSpacing(6)
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationBarTitle("Workout Description", displayMode: .inline)
        .onAppear {
            fetchWorkoutDescription()
        }
    }
}

struct WorkoutDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDescriptionView(workoutName: "Barbell Curls", documentId: "arm_workouts")
    }
}



