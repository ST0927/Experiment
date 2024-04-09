//
//  DataControl.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2024/02/21.
//

//import Foundation
//
////データレイクに送信
//class DataControl: ObservableObject {
//    @Published var responseData: String = ""
//    func sendData<T: Numeric>(user: String, event: String, value: T,x: T?,y: T?,width: T?,height: T?) {
//        //日付をjsonで使える形に変換
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        formatter.timeStyle = .medium
//        formatter.dateStyle = .medium
//        formatter.locale = Locale(identifier: "ja_JP")
//        let now = Date()
//        let nowstr: String = formatter.string(from: now)
//        let date: NSDate? = formatter.date(from: nowstr) as NSDate?
//        // NSDate型 "date" をUNIX時間 "dateUnix" に変換
//        let dateUnix: TimeInterval? = date?.timeIntervalSince1970
//        
//        let url = URL(string: "https://datalake.iopt.jp/v1/sensor_data")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        let sendData = ["key": "t9eX8tyr7G_ZQk-2",
//                        "meta": ["area": 1927,
//                                 "type": 1927,
//                                 "sensor_id": user ,
//                                 "data_time": dateUnix ?? 0,
//                                ],
//                        "body": ["event": event,
//                                 "value": value,
//                                 "eventPosition_x": x ?? "",
//                                 "eventPosition_y": y ?? "",
//                                 "window_w": width ?? "",
//                                 "window_h": height ?? "",]
////                        "body": [sensor_id: value]
//                        ] as [String: Any]
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: sendData)
//            request.httpBody = jsonData
//        } catch {
//            print("Error: \(error)")
//        }
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data {
//                if let responseString = String(data: data, encoding: .utf8) {
//                    DispatchQueue.main.async {
//                        self.responseData = responseString
//                    }
//                }
//            } else if let error = error {
//                print("Error: \(error)")
//            }
//        }.resume()
//    }
//}
