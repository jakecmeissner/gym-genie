//
//  WorkoutsView.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/3/23.
//

// WorkoutsView.swift
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct WorkoutsView: View {
    @State private var workoutTagsByBodyPart: [String: (tags: [String], documentId: String)] = [:]

    func fetchWorkoutTags() {
        let db = Firestore.firestore()
        db.collection("workout_presets").getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                var fetchedWorkoutTags: [String: (tags: [String], documentId: String)] = [:]
                for document in querySnapshot.documents {
                    if let bodyPart = document.data()["body_part"] as? String,
                       let tags = document.data()["workouts"] as? [String] {
                        fetchedWorkoutTags[bodyPart] = (tags: tags, documentId: document.documentID)
                    }
                }
                self.workoutTagsByBodyPart = fetchedWorkoutTags
            } else {
                print("Error fetching workout tags: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        ForEach(workoutTagsByBodyPart.sorted(by: { $0.key < $1.key }), id: \.key) { bodyPart, value in
                            let workoutTags = value.tags
                            let documentId = value.documentId
                            Text("\(bodyPart) Workouts")
                                .font(.title3)
                                .padding(.vertical)
                                .foregroundColor(color2)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                                ForEach(workoutTags, id: \.self) { workoutTag in
                                    NavigationLink(destination: WorkoutDescriptionView(workoutName: workoutTag, documentId: documentId)) {
                                        VStack(alignment: .leading) {
                                            Text(workoutTag)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                        }
                                        .frame(width: 120)
                                        .padding()
                                        .background(Color(.systemGroupedBackground))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(LinearGradient(gradient: Gradient(colors: [color1, color3]), startPoint: .top, endPoint: .bottom), lineWidth: 2)
                                        )
                                        .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 4)
                                    }
                                }
                            }
                            .padding(.bottom)
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .padding(.bottom, 100)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Spacer()
                        Text("Workouts")
                            .font(.title)
                            .foregroundColor(color4)
                        Spacer()
                    }
                }
            }
            .onAppear {
                fetchWorkoutTags()
            }
        }
    }

}

struct WorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsView()
    }
}




