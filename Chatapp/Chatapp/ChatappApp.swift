//
//  ChatappApp.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/09/28.
//

import SwiftUI
import FirebaseCore
import CoreData


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
    
    lazy var persistentContainer: NSPersistentContainer = {
            
              let container = NSPersistentContainer(name: "SaveData")
              container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                  if let error = error as NSError? {
                      fatalError("Unresolved error \(error), \(error.userInfo)")
                  }
              })
              return container
          }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
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
                .environmentObject(SaveData())
//                .environment(\.managedObjectContext, persistentContainer.container.viewContext)
////        //                .environmentObject(BufferSendData())
//            TEST_UsedCoreData()
            //アプリ内全てで共有したいならここでenvironmentObjectとして宣言する?
        }
      }
    }
  }


