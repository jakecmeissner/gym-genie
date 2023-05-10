//
//  SplashScreenView.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/3/23.
//

import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var userAuthViewModel: UserAuthViewModel
    @State private var isActive = false

    var body: some View {
        VStack {
            Text("Welcome to GymGenie!")
                .font(Font.custom("Poppins-Regular", size: 24))
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                userAuthViewModel.checkUserAuthentication()
                isActive = true
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            if userAuthViewModel.isUserAuthenticated {
                GreetingView(userName: "Donna")
            } else {
                SignUpView()
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}




