//
//  LoggerView.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2024/03/13.
//

import SwiftUI
import Combine
import FirebaseFirestore

struct Logger : View {
    @EnvironmentObject var timerController: TimerCount
    @EnvironmentObject var userStore: UserStore
    
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
    
    @Binding var ButtonDisabled: Bool
    @Binding var TextfieldDisabled: Bool
    
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
    
    @State var event: String = ""
    @State var responseData: String = ""
    @State var screenWidth:CGFloat = 0
    @State var screenHeight:CGFloat = 0
    @State var tapPosition_x:CGFloat = 0
    @State var tapPosition_y:CGFloat = 0
    @State var text_len:Int = 0
    @State var text_len_ave:Double = 0
    @State var response_time_ave:Double = 0
    func sendLoggerData() {
        
        //日付の設定
        let now = Date()
        let dateUnix: TimeInterval = now.timeIntervalSince1970

        //HTTPPOSTの形式を指定
        let url = URL(string: "https://datalake.iopt.jp/v1/sensor_data")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if !message_len.isEmpty {
            text_len = message_len[message_len.count - 1].count
            text_len_ave = Double(message_len.joined().count)/Double(message_len.count)
        }
        if !ResponseTimeCounts.isEmpty {
            response_time_ave = Double(ResponseTimeCounts.reduce(0, +))/Double(ResponseTimeCounts.count)
        }
        
        //送信する内容のリスト
        let sendData = ["key": "t9eX8tyr7G_ZQk-2",
                        "meta": ["area": 1927,
                                 "type": 1927,
                                 "sensor_id": userStore.email,
                                 "data_time": dateUnix,
                                ],
                        "body": ["event": event,//イベント名
                                 //端末サイズ
                                 "screen_width":screenWidth,
                                 "screen_height":screenHeight,
                                 //タップ：カウント、頻度、場所
                                 "tap_count":tapNum,
                                 "tap_interval":TimeCount,
                                 "tap_position_x":tapPosition_x,
                                 "tap_position_y":tapPosition_y,
                                 //選択ボタン
                                 "choice_left":LeftChoice,
                                 "choice_right":RightChoice,
                                 //テキスト入力：長さ、平均長さ、削除回数、回答にかけた時間、
                                 "text_len":text_len,
                                 "text_len_ave":text_len_ave,
                                 "text_delete_count":Delete,
                                 "response_time":ResponseTimeCount,
                                 "response_time_ave":response_time_ave,
                                 //スクロール：発生位置（Y軸）、長さ、時間、速さ
                                 "view_position":abs(offsetY - initOffsetY),
                                 "scroll_length":abs(endposition - startposition),
                                 "scroll_time":ScrollingTime,
                                 "scroll_speed":abs(ScrollSpeed)
                                 ]
                        ] as [String: Any]
        
        //送信する内容をJSON形式に変更してHTTPリクエストのボディに設定
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sendData)
            request.httpBody = jsonData
        } catch {
            print("Error: \(error)")
        }
        
        //HTTPリクエストの実行
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.responseData = responseString
                    }
                }
            } else if let error = error {
                print("Error: \(error)")
            }
        }.resume()
        
        
    }

    var body: some View {
        
        //透明なビューを設置してタップ回数のカウント
        GeometryReader { geometry in
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { tap in
                    event = "tapCount"
                    screenWidth = geometry.size.width
                    screenHeight = geometry.size.height
                    tapPosition_x = tap.x
                    tapPosition_y = tap.y
                    tapNum += 1
                    TimeCount = 0
                    restartTime(c: $TimeCount)
                    sendLoggerData()
                    //画面タップでキーボードを閉じる
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
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
                
                //Text("非操作時間")
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
        Choice(tapNum: $tapNum, LeftChoice: $LeftChoice, RightChoice: $RightChoice,TimeCount: $TimeCount,time: $time,ResponseTimeCount: $ResponseTimeCount,ResponseTimeCounts: $ResponseTimeCounts,ButtonDisabled: $ButtonDisabled,TextfieldDisabled: $TextfieldDisabled)
    }
}

struct Choice : View {
    @EnvironmentObject var timerController: TimerCount
    @Binding var tapNum:Int
    @Binding var LeftChoice:Int
    @Binding var RightChoice:Int
    @Binding var TimeCount:Double
    @Binding var time: AnyCancellable?
    @Binding var ResponseTimeCount:Double
    @Binding var ResponseTimeCounts:[Double]
    
    @Binding var ButtonDisabled: Bool
    @Binding var TextfieldDisabled: Bool
    
    func B_text(s: String) -> some View {
        Text(s)
            .padding(30)
            .background(
                Circle()
                    .foregroundColor(Color(#colorLiteral(red: Float(0.9098039216), green: Float(0.9098039216), blue: Float(0.9176470588), alpha: Float(1))))).padding(.trailing, 10)
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    ResponseTimeCounts.append(ResponseTimeCount)
                    ResponseTimeCount = 0
                    tapNum += 1
                    LeftChoice += 1
                    TimeCount = 0
                    if let _timer = time{
                        _timer.cancel()
                    }
                    time = Timer.publish(every: 0.1, on: .main, in: .common)
                        .autoconnect()
                        .receive(on: DispatchQueue.main)
                        .sink { _ in
                            TimeCount += 0.1
                        }
                    let db = Firestore.firestore()
                    db.collection("messages").addDocument(data: ["text": "左"]) { err in
                        if let e = err {
                            print(e)
                        } else {
                            print("sent")
                        }
                    }
                    ButtonDisabled = true
                    TextfieldDisabled = false
                })
                {
                    B_text(s: "左")
                }.disabled(ButtonDisabled)
                Button(action: {
                    ResponseTimeCounts.append(ResponseTimeCount)
                    ResponseTimeCount = 0
                    tapNum += 1
                    RightChoice += 1
                    TimeCount = 0
                    if let _timer = time{
                        _timer.cancel()
                    }
                    time = Timer.publish(every: 0.1, on: .main, in: .common)
                        .autoconnect()
                        .receive(on: DispatchQueue.main)
                        .sink { _ in
                            TimeCount += 0.1
                        }
                    let db = Firestore.firestore()
                    db.collection("messages").addDocument(data: ["text": "右"]) { err in
                        if let e = err {
                            print(e)
                        } else {
                            print("sent")
                        }
                    }
                    ButtonDisabled = true
                    TextfieldDisabled = false
                })
                {
                    B_text(s: "右")
                }.disabled(ButtonDisabled)
            }.padding(.bottom, 55)
        }.keyboardObserving()
    }
}


//#Preview {
//    Logger(offsetY: $offsetY, initOffsetY: $initOffsetY, pre: $pre, current: $current, scroll: $scroll, startposition: $startposition, endposition: $endposition, ScrollingTime: $ScrollingTime, ScrollSpeed: $ScrollSpeed, UnScrollTimeCount: $UnScrollTimeCount,key_message: $key_message,key_history: $key_history,message_len: $message_len,Delete: $Delete,ResponseTimeCount: $ResponseTimeCount,ResponseTimeCounts: $ResponseTimeCounts)
//        .environmentObject(TimerCount()).environmentObject(DataControl())
//}
