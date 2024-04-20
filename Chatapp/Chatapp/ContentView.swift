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
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    NavigationLink(destination: RegistrationView()){
                        Text("新規登録")
                        .padding()
                    }
                    
                    NavigationLink(destination: LoginView()){
                        Text("ログイン")
                    }
                }
            }
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserStore())
    }
}
