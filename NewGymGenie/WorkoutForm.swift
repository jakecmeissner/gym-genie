//
//  WorkoutForm.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/4/23.
//

// WorkoutForm.swift
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct WorkoutForm: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedBodyPart = "arm_workouts"
    @State private var selectedWorkoutIndex: String?
    @State private var workouts: [String] = []
    @State private var weight: Int?
    @State private var sets: Int?
    @State private var reps: Int?
    @EnvironmentObject var recentWorkoutsData: RecentWorkoutsData
    
    @State private var availableWorkoutTags: [String] = ["Bench Press", "Squats", "Deadlifts", "Pull-ups"]
    @State private var selectedWorkoutTags: [String] = []

    let bodyParts = ["arm_workouts", "leg_workouts"]
    
    func displayName(for bodyPart: String) -> String {
            switch bodyPart {
            case "arm_workouts":
                return "Arms"
            case "leg_workouts":
                return "Legs"
            default:
                return bodyPart
            }
        }
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Body Part", selection: $selectedBodyPart) {
                        ForEach(bodyParts, id: \.self) { bodyPart in
                            Text(displayName(for: bodyPart)).tag(bodyPart)
                        }
                    }
                    .labelsHidden()
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .onChange(of: selectedBodyPart) { newValue in
                        loadWorkouts(for: newValue)
                    }
                
                Picker("Exercise Name", selection: $selectedWorkoutIndex) {
                    ForEach(workouts, id: \.self) { workout in
                        Text(workout).tag(workout as String?)
                    }
                }
                .labelsHidden()
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

                Section(header: Text("Workout Tags")) {
                    ForEach(availableWorkoutTags, id: \.self) { tag in
                        Toggle(tag, isOn: Binding(
                            get: { self.selectedWorkoutTags.contains(tag) },
                            set: { isSelected in
                                if isSelected {
                                    self.selectedWorkoutTags.append(tag)
                                } else {
                                    self.selectedWorkoutTags.removeAll(where: { $0 == tag })
                                }
                            }
                        ))
                    }
                }

                TextField("Weight", text: Binding(
                    get: { weight.map(String.init) ?? "" },
                    set: { weight = Int($0) }
                ))
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                TextField("Sets", text: Binding(
                    get: { sets.map(String.init) ?? "" },
                    set: { sets = Int($0) }
                ))
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                TextField("Reps", text: Binding(
                    get: { reps.map(String.init) ?? "" },
                    set: { reps = Int($0) }
                ))
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                Button("Submit", action: {
                    addWorkout()
                })
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            .navigationBarTitle("Add Workout", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss() // Add parentheses here
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.blue)
            })
            .onAppear {
                loadWorkouts(for: selectedBodyPart)
            }
        }
    }
    
    func loadWorkouts(for bodyPart: String) {
        let db = Firestore.firestore()
        db.collection("workout_presets").document(bodyPart).getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data(),
               let fetchedWorkouts = data["workouts"] as? [String] {
                self.workouts = fetchedWorkouts
                if !workouts.isEmpty {
                    self.selectedWorkoutIndex = workouts.first
                } else {
                    self.selectedWorkoutIndex = nil
                }
            } else {
                print("Document does not exist or error fetching workouts: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func addWorkout() {
        print("Attempting to add a workout")

        guard let weight = weight, let sets = sets, let reps = reps else {
            print("Please fill in all fields")
            return
        }

        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }
        let userID = user.uid

        let db = Firestore.firestore()

        if let workoutName = selectedWorkoutIndex {
            let workoutData: [String: Any] = [
                "userID": userID,
                "workoutName": workoutName,
                "preset": displayName(for: selectedBodyPart),
                "weight": weight,
                "sets": sets,
                "reps": reps,
                "date": Timestamp(date: Date()),
                "workout_tags": selectedWorkoutTags
            ]

            db.collection("workouts").addDocument(data: workoutData) { error in
                if let error = error {
                    print("Error adding workout: \(error.localizedDescription)")
                } else {
                    print("Workout added successfully")

                    var newWorkoutData = workoutData
                    newWorkoutData["id"] = workoutName
                    if let newWorkout = Workout(data: newWorkoutData) {
                        self.recentWorkoutsData.recentWorkouts.insert(newWorkout, at: 0)

                        if self.recentWorkoutsData.recentWorkouts.count > 5 {
                            self.recentWorkoutsData.recentWorkouts.removeLast()
                        }
                    }

                    presentationMode.wrappedValue.dismiss()
                }
            }
        } else {
            print("Workout name is not available.")
        }
    }
}

struct WorkoutForm_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutForm()
    }
}

