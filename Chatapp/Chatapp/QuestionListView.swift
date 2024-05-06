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
    @EnvironmentObject var dataStatus:DataStatus
//    @State var taskisActive = true
    @State var isActive = false
    @State var showAlert = false
    @State var QuestionNum:Int = 0
    
    var body: some View {
        VStack {
            Button("[5/7 ~ 5/12] Image Caption Evaluation") {
                if dataStatus.task_isActive == true {
                    isActive = true
                } else {
                    showAlert = true
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Attention"), message: Text("This experiment has concluded."), dismissButton: .default(Text("OK")))
            }
            NavigationLink(destination: Talk(QuestionNum: $QuestionNum).environmentObject(QuestionList()),isActive: $isActive) {
                EmptyView()
            }/*.disabled(TaskActivate.task1)*/
            
        }
//            .navigationTitle("実験一覧")
    }
}


//#Preview {
////    QuestionListView()
//    TaskListView(, TaskNum: <#Int#>)
//}
