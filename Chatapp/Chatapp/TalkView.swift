//
//  TalkView.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/11/25.
//

import SwiftUI
import FirebaseFirestore
import KeyboardObserving
import Combine
import UIKit
import Combine

struct Talk: View {
    @EnvironmentObject var Q: QuestionList
    @EnvironmentObject var userStore: UserStore
//    @ObservedObject var dataset = Dataset()
    @EnvironmentObject var dataset: Dataset
    @EnvironmentObject var dataStatus:DataStatus
    @State var message = ""
    @State var chatType = ""
    @State var key_message:[String] = []
    @State var key_history:[String] = []
    @State var message_len:[String] = []
    @State var history:[Message] = []
    @State var offsetY:CGFloat = 0
    @State var initOffsetY:CGFloat = 0
    @State var pre:CGFloat = 0
    @State var current:CGFloat = 0
    @State var scroll:Bool = false
    @State var Time:AnyCancellable?
    @State var ResponseTime:AnyCancellable?
    @State var ResponseTimeCount:Double = 0
    @State var ResponseTimeCounts:[Double] = []
    @State var startposition:CGFloat = 0
    @State var endposition:CGFloat = 0
    @State var ScrollTime:AnyCancellable?
    @State var ScrollTimeCount:Double = 0
    @State var ScrollingTime:Double = 0
    @State var ScrollSpeed:Double = 0
    @State var unScrollTime:AnyCancellable?
    @State var unScrollTimeCount:Double = 0
    @State var UnScrollTimeCount:Double = 0
    @State var Delete:Int = 0
    @State var ButtonDisabled:Bool = false
    @State var TextfieldDisabled:Bool = true
    @State var ScrollCount: Int = 0
    @State var response_time_ave:Double = 0
    @State var event: String = ""
    @State var screenWidth:CGFloat = 0
    @State var screenHeight:CGFloat = 0
    @State var tapPosition_x:CGFloat = 0
    @State var tapPosition_y:CGFloat = 0
    @State var isAnswerCorrect: Bool = true
    @State var taskNum: Int = 1
    @State var tapNum:Int = 0
    @State var LeftChoice:Int = 0
    @State var RightChoice:Int = 0
    @State var TimeCount:Double = 0
    @State var responseData: String = ""
    @State var timelimit: Bool = false
    @Binding var QuestionNum:Int

    func sendLoggerData() {
        
        //日付の設定
        let now = Date()
        let dateUnix: TimeInterval = now.timeIntervalSince1970

        //HTTPPOSTの形式を指定
        let url = URL(string: "https://datalake.iopt.jp/v1/sensor_data")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
                                 "QuestionNum":QuestionNum,
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
                                 
                                 //スクロール：長さ、時間、速さ、回数
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
        ZStack {
            Color(red:1.0,green:0.98,blue:0.94)
            VStack(alignment: .leading) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack {
                            VStack(spacing: 0) {
                                AvatarMessageView(text: "Q1: "+dataset.csvArray[1][3])
                                ImageFromGitLinkView(filePath: "\(dataset.csvArray[1][4])")
                            }
                            ForEach(history.indices, id: \.self) { index in
                                let Num = index+1 //indexがIntじゃないから数字を足す
                                let num_of_task = 149//１問目は別で用意
                                UserResponseView(text: "\(history[index].text)")
                                VStack(spacing: 0) {
                                    if Num <= num_of_task  {
                                        if !dataset.csvArray[Num+1][3].isEmpty && !dataset.csvArray[Num+1][4].isEmpty {
                                            AvatarMessageView(text: "Q\(Num+1): "+dataset.csvArray[Num+1][3])
                                            ImageFromGitLinkView(filePath: "\(dataset.csvArray[Num+1][4])")
                                                .onAppear {
                                                    QuestionNum = Int(dataset.csvArray[Num+1][0]) ?? 1
                                                }
                                        } else {
                                            Text("Question not found")
                                        }
                                    } else {
                                        //タスクの終了処理
                                        AvatarMessageView(text: "This concludes the questions. Thank you for your cooperation!")
                                            .onAppear {
                                                ButtonDisabled = true
                                                dataStatus.task_isActive = false
                                            }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 5)
                        .onChange(of: history.indices) {
                            if let _timer = ResponseTime{
                                _timer.cancel()
                            }
                            ResponseTime = Timer.publish(every: 0.1, on: .main, in: .common)
                                .autoconnect()
                                .receive(on: DispatchQueue.main)
                                .sink { _ in
                                    ResponseTimeCount += 0.1
                                }
                        }
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .preference(
                                        key: ScrollOffsetYPreferenceKey.self,
                                        value: [geometry.frame(in: .global).minY]
                                    ).onAppear {
                                        initOffsetY = geometry.frame(in: .global).minY
                                    }
                            }
                        )
                        Spacer(minLength: 50).id("footer")
                    }.padding(.bottom, 55)
                        .alert(isPresented: $timelimit) {
                            Alert(title: Text("Finish!"), message: Text("Your work time has been adjusted to 30 minutes. Thank you for your cooperation!"), dismissButton: .default(Text("OK")))
                        }
                        .onChange(of: history.indices) {
                                    withAnimation {
                                        proxy.scrollTo("footer")
                                    }
                                }
                        .onPreferenceChange(ScrollOffsetYPreferenceKey.self) { value in
                            offsetY = value[0]
                            if scroll == false {
                                print("start")
                                event = "scroll"
                                startposition = offsetY - initOffsetY
//                                UnScrollTimeCount = unScrollTimeCount
                                if let _timer = ScrollTime{
                                    _timer.cancel()
                                }
                                ScrollTime = Timer.publish(every: 0.1, on: .main, in: .common)
                                    .autoconnect()
                                    .receive(on: DispatchQueue.main)
                                    .sink { _ in
                                        ScrollTimeCount += 0.1
                                    }
                            }
                            scroll = true
                            current = offsetY - initOffsetY
                            print(offsetY - initOffsetY)
                            
                            if let _timer = Time{
                                _timer.cancel()
                            }
                            Time = Timer.publish(every: 0.1, on: .main, in: .common)
                                .autoconnect()
                                .receive(on: DispatchQueue.main)
                                .sink { _ in
                                    if scroll == true {
                                        if pre == current {
                                            print("end")
                                            endposition = offsetY - initOffsetY
                                            ScrollingTime = ScrollTimeCount
                                            ScrollSpeed = (endposition - startposition)/ScrollingTime
                                            ScrollTimeCount = 0
                                            scroll = false
                                            ScrollCount += 1
                                            sendLoggerData()
                                            if let _timer = ScrollTime
                                            {
                                                _timer.cancel()
                                            }
                                        } else {
                                            print("スクロール中")
                                        }
                                    }
//                                    else if pre == current {
//                                        unScrollTimeCount = 0
//                                        if let _timer = unScrollTime{
//                                            _timer.cancel()
//                                        }
//                                        unScrollTime = Timer.publish(every: 0.1, on: .main, in: .common)
//                                            .autoconnect()
//                                            .receive(on: DispatchQueue.main)
//                                            .sink { _ in
//                                                unScrollTimeCount += 0.1
//                                            }
//                                    }
                                }
                            pre = offsetY - initOffsetY
                        }
                }
            }.keyboardObserving().onAppear  {
                let db = Firestore.firestore()
                db.collection(userStore.email).addSnapshotListener {
                    (snapshot, err) in
                    if err != nil {
                        print("error")
                    } else {
                        snapshot?.documentChanges.forEach({(diff) in
                            if diff.type == .added {
                                let m = Message(data: diff.document.data())
                                self.history.append(m)
                            }
                        })
                    }
                }
            }
            Logger(offsetY: $offsetY, initOffsetY: $initOffsetY, pre: $pre, current: $current, scroll: $scroll, startposition: $startposition, endposition: $endposition, ScrollingTime: $ScrollingTime, ScrollSpeed: $ScrollSpeed, UnScrollTimeCount: $UnScrollTimeCount,key_message: $key_message,key_history: $key_history,message_len: $message_len,Delete: $Delete,ResponseTimeCount: $ResponseTimeCount,ResponseTimeCounts: $ResponseTimeCounts, ButtonDisabled: $ButtonDisabled,TextfieldDisabled: $TextfieldDisabled,response_time_ave:$response_time_ave,event:$event,screenWidth:$screenWidth,screenHeight:$screenHeight,tapPosition_x:$tapPosition_x,tapPosition_y:$tapPosition_y,isAnswerCorrect:$isAnswerCorrect,taskNum:$taskNum,tapNum:$tapNum,LeftChoice:$LeftChoice,RightChoice:$RightChoice,TimeCount:$TimeCount, responseData:$responseData, ScrollCount: $ScrollCount, timelimit: $timelimit, QuestionNum: $QuestionNum)
                .environmentObject(TimerCount())
            
            VStack {
                Spacer()
                HStack(spacing:0) {
                    TextField("  Not used in this experiment", text: $message)
                        .frame(height: 55)
                        .background(Color.white)
                        .onChange(of: message) {
                                key_message.append("\(message)")
                                key_history.append("\(message.replacingOccurrences(of:" ",with: "[空白]"))")
                            if key_message.count > 1 {
                                if key_message[key_message.count-1].count < key_message[key_message.count-2].count {
                                    key_history.append("\(key_message[key_message.count - 1])[削除]")
                                    Delete += 1
                                }
                            }
                        }
                        
                    Button(action: {
                        chatType = "user"
                        let db = Firestore.firestore()
                        db.collection("messages").addDocument(data: ["text":self.message, "type":self.chatType]) { err in
                            if let e = err {
                                print(e)
                            } else {
                                print("sent")
                            }
                        }
                        message_len.append("\(message)")
                        self.message = ""
//                        ButtonDisabled = false
//                        TextfieldDisabled = true
                        //送信したらキーボードを閉じる
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }) {
                        Image(systemName:"paperplane.fill")
                            .frame(width: 55,height: 55)
                            .background(Color.white)
                    }.disabled(TextfieldDisabled)
                }
            }
            
            EyetrackView()
            
        }
    }
}

struct ScrollOffsetYPreferenceKey: PreferenceKey {
    static var defaultValue: [CGFloat] = [0]
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

struct Message : Identifiable {
    var id = UUID()
    var text: String
    var type: String
    init(data: [String: Any]) {
        self.text = data["text"] as! String
        self.type = data["type"] as? String ?? ""
    }
}

struct AvatarView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle")
                .resizable()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
        }
    }
}

struct ImageFromGitLinkView: View {
    let filePath: String
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: filePath)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .border(Color.white, width: 5)
                case .failure(_):
                    Text("画像の取得に失敗しました")
                case .empty:
                    ProgressView()
                @unknown default:
                    Text("未知のエラーが発生しました")
                }
            }
        }
    }
}


struct UserResponseView: View {
    let text: String
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .font(.system(size: 14)).padding(10)
                .background(Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1)))
                .cornerRadius(10)
        }.padding(.horizontal, 10)
    }
}

struct AvatarMessageView: View {
    let text: String
    var body: some View {
        HStack(alignment: .top) {
            AvatarView()
            Text(text)
                .font(.system(size: 14))
                .padding(10)
                .background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                .cornerRadius(10)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }.padding(.horizontal, 10)
    }
}



//#Preview {
//    Talk(/*response_time_ave: $response_time_ave, event: $event, screenWidth: $screenWidth, screenHeight: $screenHeight, tapPosition_x: $tapPosition_x, tapPosition_y: $tapPosition_y, isAnswerCorrect: $isAnswerCorrect, taskNum: $taskNum, tapNum: $tapNum, LeftChoice: $LeftChoice, RightChoice: $RightChoice, TimeCount: $TimeCount, responseData: $responseData*/, taskisActive: )
//        .environmentObject(QuestionList())
//        .environmentObject(UserStore())
//}
//

