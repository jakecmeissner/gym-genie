//
//  VideoPlayerView.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/3/23.
//

// VideoPlayerView.swift
import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL: URL?
    @Binding var currentVideoIndex: Int?
    let index: Int?
    
    @State private var player: AVPlayer?

    var body: some View {
        if let videoURL = videoURL {
            VideoPlayer(player: player)
                .edgesIgnoringSafeArea(.all)
                .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime), perform: { _ in
                    player?.seek(to: .zero)
                    player?.play()
                })
                .onAppear {
                    player = AVPlayer(url: videoURL)
                    if currentVideoIndex == index {
                        player?.play()
                    }
                }
                .onChange(of: currentVideoIndex) { newIndex in
                    if newIndex == index {
                        player?.play()
                    } else {
                        player?.pause()
                    }
                }
                .onDisappear {
                    player?.pause()
                    player = nil
                }
        } else {
            Text("Video not available")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static let videoURL = URL(string: "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")

    static var previews: some View {
        VideoPlayerView(videoURL: videoURL, currentVideoIndex: .constant(0), index: 0)
    }
}


