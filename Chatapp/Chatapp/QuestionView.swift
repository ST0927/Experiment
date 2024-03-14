//
//  QuestionView.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/11/02.
//

//import SwiftUI
//import OpenAIKit
//
//// チャット表示用のメインビュー
//struct Question: View {
//
//    // 現在のチャットが完了しているかどうかを示す変数
//    @State private var isCompleting: Bool = false
//    
//    // ユーザーが入力するテキストを保存する変数
//    @State private var text: String = ""
//    
//    @State var imagename: String = ""
//    // チャットメッセージの配列
//    @State  var chat: [ChatMessage] = [
//        ChatMessage(role: .system, content:"あなたは、ユーザーの質問や会話に回答するロボットです。"),
//        ChatMessage(role: .system, content:"こんにちは。何かお困りのことがあればおっしゃってください。")
//    ]
//    
//    @EnvironmentObject var Q: QuestionList
//    
//    // チャット画面のビューレイアウト
//    var body: some View {
//        ZStack {
//            VStack {
//                // スクロール可能なメッセージリストの表示
//                ScrollView {
//                    VStack(alignment: .leading) {
//                        ForEach(chat.indices, id: \.self) { index in
//                            // 最初のメッセージ以外を表示
//                            if index > 1 {
//                                if index % 2 == 0 {
//                                }
//                                MessageView(message: chat[index])
//                            }
//                        }
//                    }
//                }
//                .padding(.top)
//                
//                // 画面をタップしたときにキーボードを閉じる
//                .onTapGesture {
//                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                }
//
//                // テキスト入力フィールドと送信ボタンの表示
//                HStack {
//                    // テキスト入力フィールド
//                    TextField("メッセージを入力", text: $text)
//                        .disabled(isCompleting) // チャットが完了するまで入力を無効化
//                        .font(.system(size: 15)) // フォントサイズを調整
//                        .padding(8)
//                        .padding(.horizontal, 10)
//                        .background(Color.white) // 入力フィールドの背景色を白に設定
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 20)
//                                .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
//                        )
//                    
//                    // 送信ボタン
//                    Button(action: {
//                        isCompleting = true
//                        // ユーザーのメッセージをチャットに追加
//                        chat.append(ChatMessage(role: .user, content: text))
//                        text = "" // テキストフィールドをクリア
//                        Task {
//                            do {
//                                chat.append(ChatMessage(role: .assistant, content: Q.Q1))
//                                isCompleting = false
//
//                            }
//                        }
//                    }) {
//                        // 送信ボタンのデザイン
//                        Image(systemName: "arrow.up.circle.fill")
//                            .font(.system(size: 30))
//                            .foregroundColor(self.text == "" ? Color(#colorLiteral(red: 0.75, green: 0.95, blue: 0.8, alpha: 1)) : Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1)))
//                    }
//                    // テキストが空またはチャットが完了していない場合はボタンを無効化
//                    .disabled(self.text == "" || isCompleting)
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 8) // 下部のパディングを調整
//            }
//        }
//    }
//}
//
//// メッセージのビュー
//struct MessageView: View {
//    var message: ChatMessage
//    @EnvironmentObject var Q: QuestionList
//    
//    var body: some View {
//        HStack {
//            if message.role.rawValue == "user" {
//                Spacer()
//            } else {
//                // ユーザーでない場合はアバターを表示
//                AvatarView(imageName: "avatar")
//                    .padding(.trailing, 8)
//            }
//            VStack(alignment: .leading, spacing: 0) {
//                if message.role.rawValue == "user" {
//                    Text(message.content)
//                        .font(.system(size: 14))
//                        .padding(10)
//                        .background(Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1)))
//                        .cornerRadius(10)
//                } else {
//                
//                    HStack(spacing: 0) {
//
//                    }
//                    Text(message.content)
//                        .frame(width: 100)
//                        .font(.system(size: 14))
//                        .padding(10)
//                        .background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
//                    Button(action: {
//                        Q.Qcount += 1
//                    }){
//                        Text("Qnum")
//                            .frame(width: 100)
//                            .padding(10)
//                            .background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
//                    }
//                    Button(action: {
//
//                    }){
//                        Text("B")
//                            .frame(width: 100)
//                            .padding(10)
//                            .background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
//                    }
//                }
//            }
//            .padding(.vertical, 5)
//        }
//        .padding(.horizontal)
//    }
//}
//
//#Preview {
//    Question()
//        .environmentObject(QuestionList())
//}

