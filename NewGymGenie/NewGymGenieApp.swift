//
//  GymGenieApp.swift
//  GymGenie
//
//  Created by Jake Meissner on 4/3/23.
//

import SwiftUI
import Firebase

@main
struct GymGenieApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var userAuthViewModel = UserAuthViewModel()

    var body: some Scene {
        WindowGroup {
            StartupView()
                .environmentObject(userAuthViewModel)
        }
    }
}








//import SwiftUI
//import FirebaseCore
//
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//
//    return true
//  }
//}
//
//@main
//struct YourApp: App {
//  // register app delegate for Firebase setup
//  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//
//
//  var body: some Scene {
//    WindowGroup {
//      NavigationView {
//        ContentView()
//      }
//    }
//  }
//}
