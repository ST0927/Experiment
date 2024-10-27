//
//  ChatappApp.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/09/28.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct ChatappApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userStore = UserStore()
    
    var body: some Scene {
      WindowGroup {
        NavigationView {
          ContentView()
                .environmentObject(userStore) //これ冗長じゃない？上のuserStore = UserStore()消してUserStore()にしていい気がする
                .environmentObject(DataStatus())
                .environmentObject(Dataset())
                .environmentObject(MotionSensor())
                .environmentObject(SensorDataSender())
//                .environmentObject(BufferSendData())
            
            //アプリ内全てで共有したいならここでenvironmentObjectとして宣言する?
        }
      }
    }
  }


