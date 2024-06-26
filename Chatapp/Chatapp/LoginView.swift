//
//  LoginView.swift
//  Hello world
//
//  Created by Shigeyuki TAIRA on 2023/09/18.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    @State var showingError = false
    @State var error : Error?
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userStore : UserStore
    
    var body: some View {
        if userStore.isAuthenticated {
//            QuestionListView()
            TaskListView()
            } else {
            VStack {
                Text("Email address")
                TextField("Email address",text: $email).padding(.leading)
                Divider().padding()

                Text("Password")
                SecureField("Password",text: $password).padding(.leading)
                Divider().padding()

                Button("Log in"){
                    Auth.auth().signIn(withEmail: self.email, password: self.password) { (result, error) in
                        if let e = error {
                            self.showingError = true
                            self.error = e
                            return
                        }
                        if let user = result?.user {
                            userStore.email = user.email ?? ""
                            userStore.userID = user.uid 
                        }
                        //画面を閉じて直前のViewに戻る
//                        self.presentationMode.wrappedValue.dismiss()
                        userStore.isAuthenticated = true
                    }
                }.alert(isPresented: $showingError) {
                    Alert.init(title: Text("Error"),message: Text(self.error!.localizedDescription),dismissButton: .default(Text("OK")))
                }
                .padding()
                
                NavigationLink(destination:PasswordResetView()){
                    Text("If you forgot your password")
                }
                .padding()

            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(UserStore())
    }
}
