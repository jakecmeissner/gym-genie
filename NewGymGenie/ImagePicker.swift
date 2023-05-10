//
//  ImagePicker.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/4/23.
//

import SwiftUI
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

struct ImagePicker: UIViewControllerRepresentable {
    enum MediaType {
        case image
        case video
    }

    let sourceType: UIImagePickerController.SourceType
    let mediaTypes: [MediaType]
    let onPickedMedia: (Media) -> Void
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        if mediaTypes.contains(.video) {
            picker.mediaTypes = mediaTypes.contains(.video) ? [UTType.movie.identifier] : [UTType.image.identifier]
        }
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let mediaURL = info[.mediaURL] as? URL {
                parent.onPickedMedia(Media(url: mediaURL))
            }
            parent.onDismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            parent.onDismiss()
        }


        // Add the handleCancel function here
        func handleCancel() {
            parent.onDismiss()
        }
    }
}

struct Media {
    let url: URL
}



