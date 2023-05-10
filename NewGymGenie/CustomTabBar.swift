//
//  CustomTabBar.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/3/23.
//

// CustomTabBar.swift
import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import Photos
import PhotosUI

protocol CustomPHPickerViewControllerDelegate: AnyObject {
    func uploadButtonTapped()
}

class CustomPHPickerViewController: UIViewController {
    weak var customDelegate: CustomPHPickerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(uploadButtonAction))
    }
    
    @objc func uploadButtonAction() {
        customDelegate?.uploadButtonTapped()
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) var colorScheme
    @State private var isMediaPickerPresented = false
    @State private var mediaURL: URL?
    @State private var isActionSheetPresented = false
    @State private var isWorkoutFormPresented = false
    @State private var showMediaAccessAlert = false
    @State private var isUploadSuccessful = false
    
    let appAccentColor = Color(red: 255/255, green: 8/255, blue: 120/255)
    let appAccentColorLighter = Color(red: 255/255, green: 105/255, blue: 140/255)
    
    let color1 = Color(hex: "#604573")
    let color2 = Color(hex: "#6258A6")
    let color3 = Color(hex: "#4E8BBF")
    let color4 = Color(hex: "#55B3D9")
    let color5 = Color(hex: "#3FBFB2")
    
    var body: some View {
        ZStack {
            HStack {
                tabBarButton(selectedTab: $selectedTab, tab: 0, systemImageName: "house", tabName: "Home")
                tabBarButton(selectedTab: $selectedTab, tab: 1, systemImageName: "text.bubble", tabName: "Feed")
                Button(action: {
                    isActionSheetPresented = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(color3)
                }
                .offset(y: -30)
                .actionSheet(isPresented: $isActionSheetPresented) {
                    ActionSheet(title: Text("Choose an option"), buttons: [
                        .default(Text("Upload Workout")) {
                            isWorkoutFormPresented = true
                        },
                        .default(Text("Upload Media")) {
                            requestVideoAccess { granted in
                                if granted {
                                    isMediaPickerPresented = true
                                } else {
                                    showMediaAccessAlert = true
                                }
                            }
                        },
                        .cancel()
                    ])
                }
                .sheet(isPresented: $isWorkoutFormPresented) {
                    WorkoutForm()
                        .environmentObject(WorkoutData())
                        .environmentObject(RecentWorkoutsData())
                }
                .sheet(isPresented: $isMediaPickerPresented) {
                    MediaPickerView(isPresented: $isMediaPickerPresented, mediaURL: $mediaURL) { url, isVideo in
                        if let url = url {
                            uploadMediaToFirebase(url: url, isVideo: isVideo)
                        } else {
                            print("URL is nil")
                        }
                    }
                }
                
                tabBarButton(selectedTab: $selectedTab, tab: 2, systemImageName: "hare", tabName: "Workouts")
                tabBarButton(selectedTab: $selectedTab, tab: 3, systemImageName: "person", tabName: "Account")
            }
            .padding()
            .background(colorScheme == .dark ? Color.black : Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 0)
        }
    }
    
    private func tabBarButton(selectedTab: Binding<Int>, tab: Int, systemImageName: String, tabName: String) -> some View {
        return Button(action: {
            selectedTab.wrappedValue = tab
        }) {
            VStack {
                Image(systemName: systemImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(selectedTab.wrappedValue == tab ? color2 : Color.black)
                Text(tabName)
                    .font(.caption)
                    .foregroundColor(selectedTab.wrappedValue == tab ? color2 : Color.black)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    func requestVideoAccess(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    completion(true)
                case .limited:
                    completion(true)
                default:
                    completion(false)
                }
            }
        }
    }
    
    struct MediaPickerView: UIViewControllerRepresentable {
        @Binding var isPresented: Bool
        @Binding var mediaURL: URL?
        let uploadMedia: (URL?, Bool) -> Void
        
        func makeUIViewController(context: Context) -> some UIViewController {
            let controller = PHPickerViewController(configuration: makePickerConfiguration())
            controller.delegate = context.coordinator
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            // No update needed
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, PHPickerViewControllerDelegate, UINavigationControllerDelegate {
            let parent: MediaPickerView
            
            init(_ parent: MediaPickerView) {
                self.parent = parent
            }
            
            func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                guard let result = results.first else {
                    return
                }
                
                let itemProvider = result.itemProvider
                
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let image = image as? UIImage {
                            let imageData = image.jpegData(compressionQuality: 1.0)
                            DispatchQueue.main.async {
                                self.parent.mediaURL = imageData.flatMap { URL(dataRepresentation: $0, relativeTo: nil) }
                                self.parent.uploadMedia(self.parent.mediaURL, false)
                            }
                        }
                    }
                } else if itemProvider.canLoadObject(ofClass: AVURLAsset.self) {
                    itemProvider.loadObject(ofClass: AVURLAsset.self) { asset, error in
                        if let asset = asset as? AVURLAsset {
                            DispatchQueue.main.async {
                                self.parent.mediaURL = asset.url
                                self.parent.uploadMedia(self.parent.mediaURL, true)
                            }
                        }
                    }
                }
                
                parent.isPresented = false
            }
        }
        
        func makePickerConfiguration() -> PHPickerConfiguration {
            var configuration = PHPickerConfiguration()
            configuration.filter = .any(of: [.images, .videos])
            configuration.selectionLimit = 1
            configuration.preferredAssetRepresentationMode = .current
            return configuration
        }
    }
    
    func uploadMediaToFirebase(url: URL, isVideo: Bool) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let mediaType = isVideo ? "videos" : "images"
        let uniqueID = UUID().uuidString
        let mediaRef = storageRef.child("\(mediaType)/\(uniqueID)")
        
        let metadata = StorageMetadata()
        metadata.contentType = isVideo ? "video/mp4" : "image/jpeg"
        
        mediaRef.putFile(from: url, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading media: \(error)")
                return
            }
            
            mediaRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error)")
                } else {
                    print("Media uploaded successfully, download URL: \(url?.absoluteString ?? "None")")
                }
            }
        }
    }
    
    struct CustomTabBar_Previews: PreviewProvider {
        static var previews: some View {
            CustomTabBar(selectedTab: .constant(0))
        }
    }
}


