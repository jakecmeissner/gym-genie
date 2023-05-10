//
//  User.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/8/23.
//

import FirebaseFirestoreSwift

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var username: String
    var country: String
    var following: Int
    var followers: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case username
        case country
        case following
        case followers
    }
}


