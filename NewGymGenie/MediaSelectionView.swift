//
//  MediaSelectionView.swift
//  NewGymGenie
//
//  Created by Jake Meissner on 4/27/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

struct MediaSelectionView: View {
    @State private var isMediaPickerPresented = false
    @State private var mediaURL: URL?
    @Binding var isUploadSuccessful: Bool

    // Pass this function to the MediaPickerView so it can upload the media
    func uploadMedia(with url: URL?, imageData: Data? = nil, isVideo: Bool) {
        guard let url = url else { return }
        
        // Determine if it's a photo or a video
        let isVideo = url.pathExtension.lowercased() == "mov" || url.pathExtension.lowercased() == "mp4"
        
        // Check if the user is currently signed in
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        
        let userID = user.uid
        
        if isVideo {
            guard let videoData = try? Data(contentsOf: url) else {
                print("Error reading video data")
                return
            }
            
            FirebaseManager.shared.uploadVideoAndSaveUrl(userId: userID, videoData: videoData) { error in
                if let error = error {
                    print("Error uploading video: \(error.localizedDescription)")
                } else {
                    print("Video uploaded and URL saved successfully.")
                    // Show the success message
                    withAnimation {
                        isUploadSuccessful = true
                    }
                    // Hide the success message after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            isUploadSuccessful = false
                        }
                    }
                }
            }
        } else {
            guard let imageData = try? Data(contentsOf: url) else {
                print("Error reading image data")
                return
            }
            
            // Upload imageData using your FirebaseManager code
            // Replace `uploadImageAndSaveUrl` with the name of your function
            FirebaseManager.shared.uploadImageAndSaveUrl(userId: userID, imageData: imageData) { error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                } else {
                    print("Image uploaded and URL saved successfully.")
                    // Show the success message
                    withAnimation {
                        isUploadSuccessful = true
                    }
                    // Hide the success message after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            isUploadSuccessful = false
                        }
                    }
                }
            }
        }
    }

    var body: some View {
        VStack {
            Button(action: {
                isMediaPickerPresented = true
            }) {
                Text("Select Media")
            }
            .sheet(isPresented: $isMediaPickerPresented) {
                MediaSelectionView(isUploadSuccessful: $isUploadSuccessful)
            }
        }
    }
}

struct MediaSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        MediaSelectionView(isUploadSuccessful: .constant(false))
    }
}


