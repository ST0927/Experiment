//
//  QuestionListView.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/12/14.
//

import SwiftUI

struct QuestionListView: View {
    var body: some View {
        NavigationLink(destination: Talk().environmentObject(QuestionList())){
            Text("4/20~ プレ実験")
        }
    }
}

#Preview {
    QuestionListView()
}
