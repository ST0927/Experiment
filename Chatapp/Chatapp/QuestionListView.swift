//
//  QuestionListView.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/12/14.
//

import SwiftUI

//struct QuestionListView: View {
//    var body: some View {
//        NavigationLink(destination: Talk().environmentObject(QuestionList())){
//            Text("4/20~ プレ実験")
//        }
//    }
//}

struct TaskListView: View {
    @State private var taskActive = false
    @State private var isActive = false
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: Talk().environmentObject(QuestionList()), isActive: $isActive) {
                    Button("4/20~ プレ実験") {
                        if taskActive {
                            isActive = true
                        } else {
                            showAlert = true
                        }
                    }
                }
            }
            .navigationTitle("実験リスト")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("注意"), message: Text("このタスクは終了しました"), dismissButton: .default(Text("OK")))
            }
        }
    }
}


#Preview {
//    QuestionListView()
    TaskListView()
}
