//
//  PasswirdResetView.swift
//  Hello world
//
//  Created by Shigeyuki TAIRA on 2023/09/18.
//

import SwiftUI

struct PasswordResetView: View {
    @State var email = ""
    var body: some View {
        VStack {
            Text("Email address")
            TextField("Email address", text: $email).padding(.leading)
            Button("Send password reset email") {

            }
        }
    }
}

struct PasswirdResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView()
    }
}
