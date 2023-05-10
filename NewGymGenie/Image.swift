//
//  Image.swift
//  NewGymGenie
//
//  Created by Jake Meissner on 4/26/23.
//

import Foundation

struct CustomImage {
    let id: String
    let title: String
    let description: String
    let uploadDate: Date
    let fileLocationURL: String
    let userID: String
}

extension CustomImage {
    var imageDictionary: [String: Any] {
        return [
            "title": title,
            "description": description,
            "uploadDate": uploadDate,
            "fileLocationURL": fileLocationURL,
            "userID": userID
        ]
    }
}


