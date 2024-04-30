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
    @State var taskisActive = true
    @State var isActive = false
    @State var showAlert = false
    
    var body: some View {
        VStack {
            Button("[5/7 ~ 5/12] Image Caption Evaluation") {
                if taskisActive == true {
                    isActive = true
                } else {
                    showAlert = true
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Attention"), message: Text("This experiment has concluded."), dismissButton: .default(Text("OK")))
            }
            NavigationLink(destination: Talk(taskisActive: $taskisActive).environmentObject(QuestionList()),isActive: $isActive) {
                EmptyView()
            }/*.disabled(TaskActivate.task1)*/
            
        }
//            .navigationTitle("実験一覧")
    }
}


#Preview {
//    QuestionListView()
    TaskListView()
}
