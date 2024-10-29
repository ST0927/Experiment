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
    private let url = URL(string: "https://datalake.iopt.jp/v1/sensor_data")!
    private var dataQueue: [[String: Any]] = []  // データを一時的に保持する配列
    private let sendInterval: TimeInterval = 5.0  // 10秒ごとにデータを送信
    
    // タイマーを開始して、指定間隔でデータを送信
    func startCollectingDataRegularly(interval: TimeInterval = 0.01, sendData: @escaping () -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            sendData()
//            print("データを収集")
        }
//        // 10秒ごとにデータを送信
//        Timer.scheduledTimer(withTimeInterval: sendInterval, repeats: true) { _ in
//            self.sendAccumulatedData()
//        }
        
    }
    
    // タイマーを停止
    func stopSendingData() {
        timer?.invalidate()
        timer = nil
    }

    // データ送信
    func sendLogData(event: String, screenWidth: Int, screenHeight: Int, viewPosition: CGFloat, taskNum: Int, questionNum: Int, tapNum: Int, timeCount: Double, tapPositionX: Double, tapPositionY: Double, leftChoice: Int, rightChoice: Int, isAnswerCorrect: Bool, responseTimeCount: Double, responseTimeAve: Double, scrollCount: Int, scrollLength: Double, scrollingTime: Double, scrollSpeed: Double, userStoreEmail: String,attitudeX: String,attitudeY: String,attitudeZ: String,gyroX: String, gyroY: String, gyroZ: String, gravityX: String, gravityY: String, gravityZ: String, userAccX: String, userAccY: String, userAccZ: String) {
        
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
                "scroll_speed": abs(scrollSpeed),
                "attitude_x": attitudeX,
                "attitude_y": attitudeY,
                "attitude_z": attitudeZ,
                "gyro_x": gyroX,
                "gyro_y": gyroY,
                "gyro_z": gyroZ,
                "gravity_x": gravityX,
                "gravity_y": gravityY,
                "gravity_z": gravityZ,
                "userAcc_x": userAccX,
                "userAcc_y": userAccY,
                "userAcc_z": userAccZ,
                
                
            ]
        ] as [String: Any]
        
        sendSingleData(sendData)
    }
    
    // Send a single data entry
        private func sendSingleData(_ data: [String: Any]) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                request.httpBody = jsonData
                print("データを送信しました２")
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
    }
    
//    // データをすぐに送信せず、配列に貯めていく
//    func accumulateData(event: String, screenWidth: Int, screenHeight: Int, viewPosition: CGFloat, taskNum: Int, questionNum: Int, tapNum: Int, timeCount: Double, tapPositionX: Double, tapPositionY: Double, leftChoice: Int, rightChoice: Int, isAnswerCorrect: Bool, responseTimeCount: Double, responseTimeAve: Double, scrollCount: Int, scrollLength: Double, scrollingTime: Double, scrollSpeed: Double, userStoreEmail: String, attitudeX: String, attitudeY: String, attitudeZ: String, gyroX: String, gyroY: String, gyroZ: String, gravityX: String, gravityY: String, gravityZ: String, userAccX: String, userAccY: String, userAccZ: String) {
//        
//        let time = Date().timeIntervalSince1970
//        let entry = [
//            "event": event,
//            "screen_width": screenWidth,
//            "screen_height": screenHeight,
//            "view_position": abs(viewPosition),
//            "taskNum": taskNum,
//            "QuestionNum": questionNum,
//            "tap_count": tapNum,
//            "tap_interval": timeCount,
//            "tap_position_x": tapPositionX,
//            "tap_position_y": tapPositionY,
//            "choice_left": leftChoice,
//            "choice_right": rightChoice,
//            "isAnswerCorrect": isAnswerCorrect,
//            "response_time": responseTimeCount,
//            "response_time_ave": responseTimeAve,
//            "scroll_count": scrollCount,
//            "scroll_length": abs(scrollLength),
//            "scroll_time": scrollingTime,
//            "scroll_speed": abs(scrollSpeed),
//            "attitude_x": attitudeX,
//            "attitude_y": attitudeY,
//            "attitude_z": attitudeZ,
//            "gyro_x": gyroX,
//            "gyro_y": gyroY,
//            "gyro_z": gyroZ,
//            "gravity_x": gravityX,
//            "gravity_y": gravityY,
//            "gravity_z": gravityZ,
//            "userAcc_x": userAccX,
//            "userAcc_y": userAccY,
//            "userAcc_z": userAccZ,
//            "data_time": time
//        ] as [String: Any]
//
//            // データをキューに追加
//        dataQueue.append(entry)
////        print("データを追加しました")
//        print(dataQueue)
//    }
//        
//        // まとめたデータを一度に送信
//    private func sendAccumulatedData() {
//        let now = Date()
//        let dateUnix: TimeInterval = now.timeIntervalSince1970
//        guard !dataQueue.isEmpty else { print("空っぽ")
//            return }
//            
//        let sendData = [
//            "key": "t9eX8tyr7G_ZQk-2",
//            "meta": [
//                "area": 1127,
//                "type": 1127,
//                "sensor_id": dataQueue.first?["userStoreEmail"] as? String ?? "",
//                "data_time": dateUnix
//            ],
//            "body": dataQueue  // まとめて送信するデータ
//        ] as [String: Any]
//            
//            // データを送信し、キューをクリア
//        sendSingleData(sendData)
//        print(sendData)
//        dataQueue.removeAll()
//    }
}
