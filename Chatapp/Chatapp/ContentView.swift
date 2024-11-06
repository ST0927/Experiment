//
//  ContentView.swift
//  Hello world
//
//  Created by Shigeyuki TAIRA on 2023/09/14.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @EnvironmentObject var userStore : UserStore
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: SaveData.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SaveData.timestamp, ascending: true)]
    ) var saveDataItems: FetchedResults<SaveData>
    
    func savePostSurveyData() {
        let newData = SaveData(context: context)
        newData.timestamp = Date()
        newData.userid = "test"
        
        do {
            try context.save()
            print("現在時刻が保存されました")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func printEntityNames() {
        let context = context
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print("Managed Object Model が見つかりません")
            return
        }
        
        let entityNames = model.entities.map { $0.name ?? "Unnamed Entity" }
        print("エンティティ一覧: \(entityNames)")
    }
    
    // 新しいtimestampを保存する関数
    func addTimestamp() {
        let newData = SaveData(context: context)
        newData.timestamp = Date()
        newData.userid = userStore.userID  // ユーザーIDを保存（適宜変更）
        
        do {
            try context.save()
            print("現在時刻が保存されました")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    // 日付フォーマッタ
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                        NavigationLink(destination: RegistrationView()){
                            Text("Sign up")
                            .padding()
                        }
    
                        NavigationLink(destination: LoginView()){
                            Text("Log in")
                        }
//                    Text("Saved Timestamps")
//                        .font(.headline)
//                    
//                    List(saveDataItems, id: \.self) { item in
//                        if let timestamp = item.timestamp {
//                            Text("\(timestamp, formatter: dateFormatter)")
//                        }
//                    }
//                    
//                    // 現在のtimestampを保存するボタン
//                    Button(action: {
//                        addTimestamp()
//                    }) {
//                        Text("Add Current Timestamp")
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                    }
//                    
                    
                }.onAppear {
                    Auth.auth().addStateDidChangeListener { (auth, user) in
                        if user != nil {
                            self.userStore.isAuthenticated = true
                            userStore.userID = user?.uid ?? ""
                            userStore.email = user?.email ?? ""
                        } else {
                            self.userStore.isAuthenticated = false
                        }
                    }
                    //            savePostSurveyData()
                    printEntityNames()
                }
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .environmentObject(UserStore())
//    }
//}
