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
    private var dataQueue: [[Any]] = []  // データを一時的に保持する配列
//    private var dataQueue: [[String: Any]] = []
    private let sendInterval: TimeInterval = 3.0  // n秒ごとにデータを送信
    
    private let entry_queue: [String] = []
    private let dateUnix_queue: [String] = []
    
    // タイマーを開始して、指定間隔でデータを送信
    func startCollectingDataRegularly(interval: TimeInterval = 0.1, sendData: @escaping () -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            sendData()
        }
        // 10秒ごとにデータを送信
        Timer.scheduledTimer(withTimeInterval: sendInterval, repeats: true) { _ in
            self.sendAccumulatedData()
            print("3秒経過")
        }
        
    }
    
    // タイマーを停止
    func stopSendingData() {
        timer?.invalidate()
        timer = nil
    }
    
    // データをすぐに送信せず、配列に貯めていく
    func accumulateData(event: String, screenW: Int, screenH: Int, viewPos: CGFloat, task: Int, question: Int, taps: Int, tapTime: Double, tapX: Double, tapY: Double, leftCount: Int, rightCount: Int, isCorrect: Bool, idleTime: Double, idleTimeAve: Double, scrolls: Int, scrollLen: Double, scrollTime: Double, scrollSpeed: Double, userEmail: String, attX: Double, attY: Double, attZ: Double, gyroX: Double, gyroY: Double, gyroZ: Double, gravX: Double, gravY: Double, gravZ: Double, accX: Double, accY: Double, accZ: Double) {
        
        let now = Date()
        let dateUnix: TimeInterval = now.timeIntervalSince1970
        let entry: [Any] = [
                event,
                screenW,
                screenH,
                abs(viewPos),
                task,
                question,
                taps,
                tapTime,
                tapX,
                tapY,
                leftCount,
                rightCount,
                isCorrect,
                idleTime,
                idleTimeAve,
                scrolls,
                abs(scrollLen),
                scrollTime,
                abs(scrollSpeed),
                userEmail,
                attX,
                attY,
                attZ,
                gyroX,
                gyroY,
                gyroZ,
                gravX,
                gravY,
                gravZ,
                accX,
                accY,
                accZ,
                dateUnix // UNIXタイムスタンプを含める
            ]

            // データをキューに追加
        dataQueue.append(entry)//        print("データを追加しました")
//        print(dataQueue)
    }
    
    // Send a single data entry
    private func sendSingleData(_ data: [String: Any]) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            request.httpBody = jsonData
            print(jsonData)
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
        
        // まとめたデータを一度に送信
    private func sendAccumulatedData() {
        let now = Date()
        let dateUnix: TimeInterval = now.timeIntervalSince1970
        guard !dataQueue.isEmpty else { print("空っぽ")
            return }
        
        let sendData = [
            "key": "t9eX8tyr7G_ZQk-2",
            "meta": [
                "area": 1127,
                "type": 1127,
                "sensor_id": "taira",
                "data_time": dateUnix
            ],
            "body": ["data":dataQueue].description // まとめて送信するデータ
        ] as [String: Any]
            
            // データを送信し、キューをクリア
        sendSingleData(sendData)
        print(sendData)
        
        dataQueue.removeAll()
    }
    
}
