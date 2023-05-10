//
//  UserAuthViewModel.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/3/23.
//

import SwiftUI
import FirebaseAuth

class UserAuthViewModel: ObservableObject {
    @Published var isUserAuthenticated: Bool = false

    func checkUserAuthentication() {
        isUserAuthenticated = Auth.auth().currentUser != nil
    }
}

