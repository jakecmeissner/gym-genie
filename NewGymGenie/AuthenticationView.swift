//
//  AuthenticationView.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/3/23.
//

import SwiftUI

struct AuthenticationView: View {
    @State private var isUserAuthenticated: Bool = false

    var body: some View {
        VStack {
            if isUserAuthenticated {
                GreetingView(userName: "User")
            } else {
                SignUpView()
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
