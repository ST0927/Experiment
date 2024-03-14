//
//  LoggerView.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2024/03/13.
//

import SwiftUI
import Combine

class FeatureStore : ObservableObject {
    @Published var tapCount:Int = 0
    @Published var userID = ""
    @Published var email = ""
}

struct Logger : View {
    @EnvironmentObject var timerController: TimerCount
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var dataControl: DataControl
    
    @State var tapNum:Int = 0
    @State var LeftChoice:Int = 0
    @State var RightChoice:Int = 0
    @State var TimeCount:Double = 0
    @State var time: AnyCancellable?
    
    @Binding var offsetY:CGFloat
    @Binding var initOffsetY:CGFloat
    @Binding var pre: CGFloat
    @Binding var current: CGFloat
    @Binding var scroll: Bool
    @Binding var startposition: CGFloat
    @Binding var endposition: CGFloat
    @Binding var ScrollingTime:Double
    @Binding var ScrollSpeed:Double
    @Binding var UnScrollTimeCount:Double
    @Binding var key_message:[String]
    @Binding var key_history:[String]
    @Binding var message_len:[String]
    @Binding var Delete:Int
    @Binding var ResponseTimeCount:Double
    @Binding var ResponseTimeCounts:[Double]
    
    func restartTime(c: Binding<Double>) {
        if let _timer = time{
            _timer.cancel()
        }
        time = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                c.wrappedValue += 0.1
            }
    }

    var body: some View {
        //透明なビューを設置してタップ回数のカウント
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                tapNum += 1
                TimeCount = 0
                restartTime(c: $TimeCount)
                dataControl.sendData(user : userStore.email,sensor_id: "tap", value: tapNum)
                //画面タップでキーボードを閉じる
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        //動作確認用
        HStack {
            VStack {
                Text("ユーザー:\(userStore.userID)")
                Text("ユーザー:\(userStore.email)")
                if !message_len.isEmpty {
                    Text("文字数：\(message_len[message_len.count - 1].count)")
                    Text("文字数平均：\(Double(message_len.joined().count)/Double(message_len.count))")
                }
                Text("テキスト削除回数：\(Delete)")
                Text("回答時間：\(ResponseTimeCount)")
                if !ResponseTimeCounts.isEmpty {
                    Text("回答時間平均：\(Double(ResponseTimeCounts.reduce(0, +))/Double(ResponseTimeCounts.count))")
                }
                
//                Text("非操作時間")
                Text("タップ回数：\(tapNum)")
                Text("タップ間隔：\(TimeCount)")
                Text("左を選んだ回数：\(LeftChoice)")
                Text("右を選んだ回数：\(RightChoice)")
                Text("画面位置：\(abs(offsetY - initOffsetY))")
                Text("スクロール長さ：\(abs(endposition - startposition))")
                Text("スクロール時間：\(ScrollingTime)")
                Text("スクロール速度：\(abs(ScrollSpeed))")
                
            }
        }
        Choice(tapNum: $tapNum, LeftChoice: $LeftChoice, RightChoice: $RightChoice,TimeCount: $TimeCount,time: $time,ResponseTimeCount: $ResponseTimeCount,ResponseTimeCounts: $ResponseTimeCounts)
    }
}

//#Preview {
//    Logger(offsetY: $offsetY, initOffsetY: $initOffsetY, pre: $pre, current: $current, scroll: $scroll, startposition: $startposition, endposition: $endposition, ScrollingTime: $ScrollingTime, ScrollSpeed: $ScrollSpeed, UnScrollTimeCount: $UnScrollTimeCount,key_message: $key_message,key_history: $key_history,message_len: $message_len,Delete: $Delete,ResponseTimeCount: $ResponseTimeCount,ResponseTimeCounts: $ResponseTimeCounts)
//        .environmentObject(TimerCount()).environmentObject(DataControl())
//}
