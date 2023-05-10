//
//  VideoThumbnail.swift
//  NewGymGenie
//
//  Created by Jake Meissner on 4/13/23.
//

// VideoThumbnail.swift
import SwiftUI
import AVFoundation

struct VideoThumbnail: View {
    let url: URL?
    
    @State private var thumbnail: UIImage?
    
    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            generateThumbnail()
        }
    }
    
    private func generateThumbnail() {
        guard let url = url else { return }
        
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        DispatchQueue.global(qos: .background).async {
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    self.thumbnail = uiImage
                }
            } catch {
                print("Error generating thumbnail: \(error)")
            }
        }
    }
}

struct VideoThumbnail_Previews: PreviewProvider {
    static let testURL = URL(string: "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    
    static var previews: some View {
        VideoThumbnail(url: testURL)
    }
}



