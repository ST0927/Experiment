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
    @Binding var ButtonDisabled:Bool
    @Binding var TextfieldDisabled:Bool
    @Binding var response_time_ave:Double
    @Binding var event:String
    @Binding var screenWidth:CGFloat
    @Binding var screenHeight:CGFloat
    @Binding var tapPosition_x:CGFloat
    @Binding var tapPosition_y:CGFloat
    @Binding var isAnswerCorrect: Bool
    @Binding var taskNum:Int
    @Binding var tapNum:Int
    @Binding var LeftChoice:Int
    @Binding var RightChoice:Int
    @Binding var TimeCount:Double
    @Binding var responseData:String
    @Binding var ScrollCount:Int
    
    @State var text_len:Int = 0
    @State var text_len_ave:Double = 0
    
    
    @ObservedObject var dataset = Dataset()
    @Binding var timelimit:Bool
    
    @Binding var taskisActive:Bool
    
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
                                 //端末サイズ、表示中の画面の位置、表示中のタスク番号
                                 "screen_width":screenWidth,
                                 "screen_height":screenHeight,
                                 "view_position":abs(offsetY - initOffsetY),
                                 "taskNum":taskNum,
                                 //タップ：カウント、頻度、場所
                                 "tap_count":tapNum,
                                 "tap_interval":TimeCount,
                                 "tap_position_x":tapPosition_x,
                                 "tap_position_y":tapPosition_y,
                                 //回答：回数、正誤、かけた時間、
                                 "choice_left":LeftChoice,
                                 "choice_right":RightChoice,
                                 "isAnswerCorrect":isAnswerCorrect,
                                 "response_time":ResponseTimeCount,
                                 "response_time_ave":response_time_ave,
                                 //テキスト入力：長さ、平均長さ、削除回数、
//                                 "text_len":text_len,
//                                 "text_len_ave":text_len_ave,
//                                 "text_delete_count":Delete,
                                 
                                 //スクロール：長さ、時間、速さ
                                 "scroll_count":ScrollCount,
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
                    tapPosition_x = tap.x
                    tapPosition_y = tap.y
                    tapNum += 1
                    
                    sendLoggerData()
                    
                    //以下の処理は一番下
                    TimeCount = 0
                    restartTime(c: $TimeCount)
                    
                    //画面タップでキーボードを閉じる
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .onAppear {
                    screenWidth = geometry.size.width
                    screenHeight = geometry.size.height
                }
        }
       
        
        //動作確認用
        HStack {
            VStack {
                Text("イベント:\(event)")
                Text("スクリーン幅:\(screenWidth)")
                Text("スクリーン高さ:\(screenHeight)")
                Text("ユーザー:\(userStore.userID)")
                Text("ユーザー:\(userStore.email)")
                Text("タスク:\(taskNum)")
                if !message_len.isEmpty {
                    Text("文字数：\(message_len[message_len.count - 1].count)")
                    Text("文字数平均：\(Double(message_len.joined().count)/Double(message_len.count))")
                }
                Text("テキスト削除回数：\(Delete)")
                Text("回答時間：\(ResponseTimeCount)")
                if !ResponseTimeCounts.isEmpty {
                    Text("回答時間平均：\(Double(ResponseTimeCounts.reduce(0, +))/Double(ResponseTimeCounts.count))")
                    Text("合計回答時間：\(Double(ResponseTimeCounts.reduce(0, +)))")
                }
                
                //Text("非操作時間")
                Text("タップ回数：\(tapNum)")
                Text("タップ間隔：\(TimeCount)")
                Text("タップ座標x：\(tapPosition_x)")
                Text("タップ座標y：\(tapPosition_y)")
                Text("左を選んだ回数：\(LeftChoice)")
                Text("右を選んだ回数：\(RightChoice)")
                if isAnswerCorrect == true {
                    Text("回答の正誤：正)")
                } else {
                    Text("回答の正誤：誤)")
                }
                Text("画面位置：\(abs(offsetY - initOffsetY))")
                Text("スクロール回数：\(ScrollCount)")
                Text("スクロール長さ：\(abs(endposition - startposition))")
                Text("スクロール時間：\(ScrollingTime)")
                Text("スクロール速度：\(abs(ScrollSpeed))")
                
            }
        }
        Choice(tapNum: $tapNum, LeftChoice: $LeftChoice, RightChoice: $RightChoice,TimeCount: $TimeCount,time: $time,ResponseTimeCount: $ResponseTimeCount,ResponseTimeCounts: $ResponseTimeCounts,ButtonDisabled: $ButtonDisabled,TextfieldDisabled: $TextfieldDisabled, message_len: $message_len,  text_len:$text_len,text_len_ave:$text_len_ave,response_time_ave:$response_time_ave,event:$event,screenWidth:$screenWidth,screenHeight:$screenHeight,tapPosition_x:$tapPosition_x,tapPosition_y:$tapPosition_y,Delete:$Delete,offsetY:$offsetY,initOffsetY:$initOffsetY,startposition:$startposition,endposition:$endposition,ScrollCount: $ScrollCount, ScrollingTime:$ScrollingTime,ScrollSpeed:$ScrollSpeed, responseData: $responseData,isAnswerCorrect: $isAnswerCorrect,taskNum: $taskNum, timelimit: $timelimit, taskisActive: $taskisActive)
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
    
    @EnvironmentObject var userStore: UserStore
    @Binding var message_len:[String]
    @Binding var text_len:Int
    @Binding var text_len_ave:Double
    @Binding var response_time_ave:Double
    @Binding var event: String
    @Binding var screenWidth:CGFloat
    @Binding var screenHeight:CGFloat
    @Binding var tapPosition_x:CGFloat
    @Binding var tapPosition_y:CGFloat
    @Binding var Delete:Int
    @Binding var offsetY:CGFloat
    @Binding var initOffsetY:CGFloat
    @Binding var startposition: CGFloat
    @Binding var endposition: CGFloat
    @Binding var ScrollCount: Int
    @Binding var ScrollingTime:Double
    @Binding var ScrollSpeed:Double
    @Binding var responseData: String
    
    @ObservedObject var dataset = Dataset()
    @Binding var isAnswerCorrect: Bool
    @Binding var taskNum: Int
    @Binding var timelimit:Bool
    
    @Binding var taskisActive:Bool
    
    func B_text(s: String) -> some View {
        Text(s)
            .padding(30)
            .background(
                Circle()
                    .foregroundColor(Color(#colorLiteral(red: Float(0.9098039216), green: Float(0.9098039216), blue: Float(0.9176470588), alpha: Float(1))))).padding(.trailing, 10)
    }
    
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
                                 //端末サイズ、表示中の画面の位置、表示中のタスク番号
                                 "screen_width":screenWidth,
                                 "screen_height":screenHeight,
                                 "view_position":abs(offsetY - initOffsetY),
                                 "taskNum":taskNum,
                                 //タップ：カウント、頻度、場所
                                 "tap_count":tapNum,
                                 "tap_interval":TimeCount,
                                 "tap_position_x":tapPosition_x,
                                 "tap_position_y":tapPosition_y,
                                 //回答：回数、正誤、かけた時間、
                                 "choice_left":LeftChoice,
                                 "choice_right":RightChoice,
                                 "isAnswerCorrect":isAnswerCorrect,
                                 "response_time":ResponseTimeCount,
                                 "response_time_ave":response_time_ave,
                                 //テキスト入力：長さ、平均長さ、削除回数、
//                                 "text_len":text_len,
//                                 "text_len_ave":text_len_ave,
//                                 "text_delete_count":Delete,
                                 //スクロール：長さ、時間、速さ
                                 "scroll_count":ScrollCount,
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
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    event = "response"
                    ResponseTimeCounts.append(ResponseTimeCount)
                    if ResponseTimeCounts.reduce(0, +) > 60 {
                        timelimit = true
                        ButtonDisabled = true
                        taskisActive = false
                    }
                    tapNum += 1
                    LeftChoice += 1
                    
                    if dataset.csvArray[taskNum][2] == "TRUE" {
                        isAnswerCorrect = true
                    } else {
                        isAnswerCorrect = false
                    }
                    
                    sendLoggerData()
                    
                    taskNum += 1
                    ResponseTimeCount = 0
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
                    db.collection(userStore.email).addDocument(data: ["text": "Yes"]) { err in
                        if let e = err {
                            print(e)
                        } else {
                            print("sent")
                        }
                    }
                    
//                    ButtonDisabled = true
//                    TextfieldDisabled = false
                })
                {
                    ButtonView(text: "YES")
                }.disabled(ButtonDisabled)
                Button(action: {
                    event = "response"
                    ResponseTimeCounts.append(ResponseTimeCount)
                    if ResponseTimeCounts.reduce(0, +) > 60 {
                        timelimit = true
                        ButtonDisabled = true
                        taskisActive = false
                    }
                    tapNum += 1
                    RightChoice += 1
                    
                    if dataset.csvArray[taskNum][2] == "False" {
                        isAnswerCorrect = true
                    } else {
                        isAnswerCorrect = false
                    }
                    
                    sendLoggerData()
                    
                    taskNum += 1
                    ResponseTimeCount = 0
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
                    db.collection(userStore.email).addDocument(data: ["text": "No"]) { err in
                        if let e = err {
                            print(e)
                        } else {
                            print("sent")
                        }
                    }
//                    ButtonDisabled = true
//                    TextfieldDisabled = false
                })
                {
                    ButtonView(text: "NO")
                }.disabled(ButtonDisabled)
            }.padding(.bottom, 55)
        }.keyboardObserving()
    }
}

struct ButtonView: View {
    let text: String
    var body: some View {
        Text(text)
            .padding(30)
            .background(
                Circle()
                    .foregroundColor(Color(#colorLiteral(red: Float(0.9098039216), green: Float(0.9098039216), blue: Float(0.9176470588), alpha: Float(1))))
            )
            .padding(.trailing, 10)
    }
}

//#Preview {
//    Logger(offsetY: $offsetY, initOffsetY: $initOffsetY, pre: $pre, current: $current, scroll: $scroll, startposition: $startposition, endposition: $endposition, ScrollingTime: $ScrollingTime, ScrollSpeed: $ScrollSpeed, UnScrollTimeCount: $UnScrollTimeCount,key_message: $key_message,key_history: $key_history,message_len: $message_len,Delete: $Delete,ResponseTimeCount: $ResponseTimeCount,ResponseTimeCounts: $ResponseTimeCounts)
//        .environmentObject(TimerCount()).environmentObject(DataControl())
//}
