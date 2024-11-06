//
//  RegistrationView.swift
//  Hello world
//
//  Created by Shigeyuki TAIRA on 2023/09/18.
//

import SwiftUI
import Firebase

struct RegistrationView: View {
    @State var email = ""
    @State var password = ""
    @State var showingError = false
    @State var error: Error?
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userStore : UserStore
    
    var body: some View {
        VStack {
            Text("Email address")
            TextField("Email address",text: $email).padding(.leading)
            Divider().padding()
            
            Text("Password")
            SecureField("Password",text: $password).padding(.leading)
            Divider().padding()
            
            Button("Register"){
                Auth.auth().createUser(withEmail:self.email, password:self.password){ (result, error) in
                    if let e = error {
                        self.showingError = true
                        self.error = e
                        return
                    }
                    if let user = result?.user {
                        print("ユーザーUID: \(user.uid)")
                        userStore.userID = user.uid
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }
            }.alert(isPresented: $showingError) {
                Alert.init(title: Text("Error"),message: Text(self.error!.localizedDescription),dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
