//
//  SpiralApp.swift
//  Spiral
//
//  Created by Alan Grissette on 10/2/25.
//

import SwiftUI
import FirebaseCore

@main
struct SpiralApp: App {
    @StateObject private var authModel = AuthModel()

    
    @StateObject var launchScreenState = LaunchScreenStateManager()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        
        WindowGroup {
            Group{
                if authModel.currentUser == nil || authModel.userSession == nil{
                    ZStack{
                        
                        EnterUser()
                        if launchScreenState.state != .finished {
                            LaunchScreenView()
                        }
                    } .environmentObject(launchScreenState)
                }
                    
                else{
                    Home()
                }
                
                
            }
            .environmentObject(authModel)
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
//make the launch screen normally (using stateobject to observe the observable object and then inject it as an environment object


