//
//  SendData.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2024/05/07.
//

import Foundation

class DataStatus : ObservableObject {
    @Published var task_isActive:Bool = true
    @Published var task_progress:Int = 1
}

class SensorDataSender: ObservableObject {
    private var timer: Timer?
//    private var dataBuffer: [[String: Any]] = [] // データを蓄積するためのバッファ
//    private let bufferLimit = 10 // バッファ上限（送信トリガーの設定）
    private let url = URL(string: "https://datalake.iopt.jp/v1/sensor_data")!
    
    // タイマーを開始して、指定間隔でデータを送信
    func startCollectingDataRegularly(interval: TimeInterval = 0.01, sendData: @escaping () -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            sendData()
//            print("startSendingDataRegularlyは正常")
        }
    }
    
    // タイマーを停止
    func stopSendingData() {
        timer?.invalidate()
        timer = nil
    }

    // データ送信
    func sendLogData(event: String, screenWidth: Int, screenHeight: Int, viewPosition: CGFloat, taskNum: Int, questionNum: Int, tapNum: Int, timeCount: Double, tapPositionX: Double, tapPositionY: Double, leftChoice: Int, rightChoice: Int, isAnswerCorrect: Bool, responseTimeCount: Double, responseTimeAve: Double, scrollCount: Int, scrollLength: Double, scrollingTime: Double, scrollSpeed: Double, userStoreEmail: String) {
        
        // UNIXタイムスタンプで現在の時間を取得
        let now = Date()
        let dateUnix: TimeInterval = now.timeIntervalSince1970

        // 送信する内容のリストを作成
        let sendData = [
            "key": "t9eX8tyr7G_ZQk-2",
            "meta": [
                "area": 1127,
                "type": 1127,
                "sensor_id": userStoreEmail,
                "data_time": dateUnix
            ],
            "body": [
                "event": event,
                "screen_width": screenWidth,
                "screen_height": screenHeight,
                "view_position": abs(viewPosition),
                "taskNum": taskNum,
                "QuestionNum": questionNum,
                "tap_count": tapNum,
                "tap_interval": timeCount,
                "tap_position_x": tapPositionX,
                "tap_position_y": tapPositionY,
                "choice_left": leftChoice,
                "choice_right": rightChoice,
                "isAnswerCorrect": isAnswerCorrect,
                "response_time": responseTimeCount,
                "response_time_ave": responseTimeAve,
                "scroll_count": scrollCount,
                "scroll_length": abs(scrollLength),
                "scroll_time": scrollingTime,
                "scroll_speed": abs(scrollSpeed)
            ]
        ] as [String: Any]
        
//        // バッファにデータを追加
//        dataBuffer.append(sendData)
//        
//        // バッファ上限に達したらバッチ送信を行う
//        if dataBuffer.count >= bufferLimit {
//            sendBatchData()
//            dataBuffer.removeAll() // バッファをクリア
//        }
        sendSingleData(sendData)
//        print("バッファの中身：\(dataBuffer)")
    }
    
    // Send a single data entry
        private func sendSingleData(_ data: [String: Any]) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                request.httpBody = jsonData
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("JSON data to send: \(jsonString)")
                }
            } catch {
                print("JSON conversion error: \(error)")
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Send error: \(error)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Status code: \(httpResponse.statusCode)")
                }
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        print("Server response: \(responseString)")
                    }
                }
            }.resume()
    
//    // バッファ内のデータを一括送信する関数
//    private func sendBatchData() {
//        guard !dataBuffer.isEmpty else { return } // バッファが空なら送信しない
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        // バッファのデータをまとめてJSON形式に変換
//        let batchData = dataBuffer
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: batchData)
//            request.httpBody = jsonData
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                    print("送信するJSONデータ: \(jsonString)")
//                }
//        } catch {
//            print("JSON変換エラー: \(error)")
//            return
//        }
//        
//        // 非同期でHTTPリクエストの実行
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("送信エラー: \(error)")
//                return
//            }
//            
//            if let httpResponse = response as? HTTPURLResponse {
//                print("ステータスコード: \(httpResponse.statusCode)")
//            }
//            
//            if let data = data, let responseString = String(data: data, encoding: .utf8) {
//                DispatchQueue.main.async {
//                    print("サーバーからの応答: \(responseString)")
//                }
//            }
//        }.resume()

    }
}
//
//class BufferSendData : ObservableObject {
//    private var dataBuffer: [[String: Any]] = [] // データを蓄積するためのバッファ
//        private let bufferLimit = 10 // バッファ上限（送信トリガーの設定）
//        private let url = URL(string: "https://datalake.iopt.jp/v1/sensor_data")!
//        
//        // バッファにデータを追加し、上限に達したら送信する
//        func bufferAndSendData(event: String, screenWidth: Int, screenHeight: Int, viewPosition: CGFloat, taskNum: Int, questionNum: Int, tapNum: Int, timeCount: Double, tapPositionX: Double, tapPositionY: Double, leftChoice: Int, rightChoice: Int, isAnswerCorrect: Bool, responseTimeCount: Double, responseTimeAve: Double, scrollCount: Int, scrollLength: Double, scrollingTime: Double, scrollSpeed: Double, userStoreEmail: String) {
//            
//            // UNIXタイムスタンプで現在の時間を取得
//            let now = Date()
//            let dateUnix: TimeInterval = now.timeIntervalSince1970
//
//            // 送信する内容のリストを作成
//            let sendData = [
//                "key": "t9eX8tyr7G_ZQk-2",
//                "meta": [
//                    "area": 1127,
//                    "type": 1127,
//                    "sensor_id": userStoreEmail,
//                    "data_time": dateUnix
//                ],
//                "body": [
//                    "event": event,
//                    "screen_width": screenWidth,
//                    "screen_height": screenHeight,
//                    "view_position": abs(viewPosition),
//                    "taskNum": taskNum,
//                    "QuestionNum": questionNum,
//                    "tap_count": tapNum,
//                    "tap_interval": timeCount,
//                    "tap_position_x": tapPositionX,
//                    "tap_position_y": tapPositionY,
//                    "choice_left": leftChoice,
//                    "choice_right": rightChoice,
//                    "isAnswerCorrect": isAnswerCorrect,
//                    "response_time": responseTimeCount,
//                    "response_time_ave": responseTimeAve,
//                    "scroll_count": scrollCount,
//                    "scroll_length": abs(scrollLength),
//                    "scroll_time": scrollingTime,
//                    "scroll_speed": abs(scrollSpeed)
//                ]
//            ] as [String: Any]
//            
//            // バッファにデータを追加
//            dataBuffer.append(sendData)
//            
//            // バッファ上限に達したらバッチ送信を行う
//            if dataBuffer.count >= bufferLimit {
//                sendBatchData()
//                print("バッファの送信")
//                dataBuffer.removeAll() // バッファをクリア
//            }
//        }
//        
//        // バッファ内のデータを一括送信する関数
//        private func sendBatchData() {
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            
//            // バッファのデータをまとめてJSON形式に変換
//            let batchData = ["sensor_data": dataBuffer]
//            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: batchData)
//                request.httpBody = jsonData
//            } catch {
//                print("JSON変換エラー: \(error)")
//                return
//            }
//            
//            // 非同期でHTTPリクエストの実行
//            URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    print("送信エラー: \(error)")
//                    return
//                }
//                
//                if let data = data, let responseString = String(data: data, encoding: .utf8) {
//                    DispatchQueue.main.async {
//                        print("サーバーからの応答: \(responseString)")
//                    }
//                }
//            }.resume()
//        }
//}
