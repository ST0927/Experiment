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
            Text("メールアドレス")
            TextField("メールアドレス", text: $email).padding(.leading)
            Button("パスワード再設定メールを送信") {

            }
        }
    }
}

struct PasswirdResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView()
    }
}
