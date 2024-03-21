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
    @State var message = ""
    @State var key_message:[String] = []
    @State var key_history:[String] = []
    @State var message_len:[String] = []
    @State var history: [Message] = []
    @State var start:Bool = true
    @State var offsetY: CGFloat = 0
    @State var initOffsetY: CGFloat = 0
    @State var pre: CGFloat = 0
    @State var current: CGFloat = 0
    @State var scroll: Bool = false
    @State var Time: AnyCancellable?
    @State var ResponseTime: AnyCancellable?
    @State var ResponseTimeCount:Double = 0
    @State var ResponseTimeCounts:[Double] = []
    @State var startposition: CGFloat = 0
    @State var endposition: CGFloat = 0
    @State var ScrollTime: AnyCancellable?
    @State var ScrollTimeCount:Double = 0
    @State var ScrollingTime:Double = 0
    @State var ScrollSpeed:Double = 0
    @State var unScrollTime: AnyCancellable?
    @State var unScrollTimeCount:Double = 0
    @State var UnScrollTimeCount:Double = 0
    @State var Delete: Int = 0
    @State var ButtonDisabled: Bool = false
    @State var TextfieldDisabled: Bool = true
    
    func choiceQuestion() -> some View {
        HStack(alignment: .top) {
            AvatarView()
            Text("魅力的だと思う画像を選んでください").font(.system(size: 14)).padding(10).background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1))).cornerRadius(10)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }.padding(.horizontal, 10)
    }
    
    func textQuestion() -> some View {
        HStack(alignment: .top) {
            AvatarView()
            Text("その画像を選んだ理由を教えてください").font(.system(size: 14)).padding(10).background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1))).cornerRadius(10)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }.padding(.horizontal, 10)
    }
    
    func userChoice(s: String) -> some View {
        HStack {
            Spacer()
            Text(s).font(.system(size: 14)).padding(10).background(Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1))).cornerRadius(10)
        }.padding(.horizontal, 10)
    }
    
    func userText(s: String) -> some View {
        HStack {
            Spacer()
            Text(s).font(.system(size: 14)).padding(10).background(Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1))).cornerRadius(10)
        }.padding(.horizontal, 10)
    }
    
    func imageFrame(i: String) -> some View {
            Image(i)
                .resizable()
                .frame(width: 200, height: 200)
                .border(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)), width: 1)
                .background(Color.white)
    }
    
    var body: some View {
        ZStack {
            Color(red:1.0,green:0.98,blue:0.94)
            VStack(alignment: .leading) {
                ScrollViewReader { proxy in
                    ScrollView {
                        if start == false {
                            HStack(alignment: .top) {
                                AvatarView().padding()
                                VStack(spacing: 0) {
                                    Text("アンケートを始めますか？").frame(width: 200).font(.system(size: 14)).padding(10).background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                                    Button(action: {
                                        start = true
                                        let db = Firestore.firestore()
                                        db.collection("messages").addDocument(data: ["text": "始める"]) { err in
                                            if let e = err {
                                                print(e)
                                            } else {
                                                print("sent")
                                            }
                                        }
                                    })
                                    {
                                        Text("はい").frame(width: 200).padding(10).background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                                    }
                                }
                                Spacer()
                            }.padding(.top, 10)
                        } else {
                            ForEach(history.indices, id: \.self) { index in
                                let Num = index+1 //indexがIntじゃないから数字を足す
                                userChoice(s:" \(history[index].text)")
                                VStack(spacing: 0) {
                                    choiceQuestion()
                                    HStack(spacing: 0) {
                                        if Num/2 <= (Q.ImageName.count/4) {
                                            imageFrame(i:Q.ImageName[Num*2 - 2])
                                            imageFrame(i:Q.ImageName[Num*2 - 1])
                                        }
                                    }
                                }
                                userText(s:" \(history[index].text)")
                                textQuestion()
                            }.padding(.vertical, 5)
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
                        }
                        Spacer(minLength: 50).id("footer")
                    }.padding(.bottom, 55)
                        .onChange(of: history.indices) {
                                    withAnimation {
                                        proxy.scrollTo("footer")
                                    }
                                }
                        .onPreferenceChange(ScrollOffsetYPreferenceKey.self) { value in
                            offsetY = value[0]
                            if scroll == false {
                                print("start")
                                startposition = offsetY - initOffsetY
                                UnScrollTimeCount = unScrollTimeCount
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
                                        } else {
                                            print("スクロール中")
                                        }
                                    }
                                    else if pre == current {
                                        unScrollTimeCount = 0
                                        if let _timer = unScrollTime{
                                            _timer.cancel()
                                        }
                                        unScrollTime = Timer.publish(every: 0.1, on: .main, in: .common)
                                            .autoconnect()
                                            .receive(on: DispatchQueue.main)
                                            .sink { _ in
                                                unScrollTimeCount += 0.1
                                            }
                                    }
                                }
                            pre = offsetY - initOffsetY
                        }
                }
            }.keyboardObserving().onAppear  {
                let db = Firestore.firestore()
                db.collection("messages").addSnapshotListener {
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
            //Logger
            if start == true {
                Logger(offsetY: $offsetY, initOffsetY: $initOffsetY, pre: $pre, current: $current, scroll: $scroll, startposition: $startposition, endposition: $endposition, ScrollingTime: $ScrollingTime, ScrollSpeed: $ScrollSpeed, UnScrollTimeCount: $UnScrollTimeCount,key_message: $key_message,key_history: $key_history,message_len: $message_len,Delete: $Delete,ResponseTimeCount: $ResponseTimeCount,ResponseTimeCounts: $ResponseTimeCounts, ButtonDisabled: $ButtonDisabled,TextfieldDisabled: $TextfieldDisabled)
                    .environmentObject(TimerCount()).environmentObject(DataControl())
            }
            
            VStack {
                Spacer()
                HStack(spacing:0) {
                    TextField("　メッセージ", text: $message)
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
                        let db = Firestore.firestore()
                        db.collection("messages").addDocument(data: ["text":self.message]) { err in
                            if let e = err {
                                print(e)
                            } else {
                                print("sent")
                            }
                        }
                        message_len.append("\(message)")
                        self.message = ""
                        ButtonDisabled = false
                        TextfieldDisabled = true
                        //送信したらキーボードを閉じる
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }) {
                        Image(systemName:"paperplane.fill")
                            .frame(width: 55,height: 55)
                            .background(Color.white)
                    }.disabled(TextfieldDisabled)
                }
            }
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
    init(data: [String: Any]) {
        self.text = data["text"] as! String
    }
}

struct AvatarView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle").resizable().frame(width: 30, height: 30).clipShape(Circle())
        }
    }
}

#Preview {
    Talk()
        .environmentObject(QuestionList())
        .environmentObject(UserStore())
}


