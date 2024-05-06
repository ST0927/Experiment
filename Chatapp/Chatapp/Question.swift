//
//  Question.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/11/06.
//

import Foundation
import SwiftUI

class QuestionList : ObservableObject{
    @Published var ImageName = ["りんご１","りんご２","バナナ","みかん","スイカ","メロン"]
    @Published var Qcount: Int = 0
}


class Dataset : ObservableObject {
    @Published var csvArray: [[String]] = [[]]
    var csvBundle: String?
    var csvData: String?
    
    init() {
        csvBundle = Bundle.main.path(forResource:"GQA_dataset", ofType: "csv")
        
        if let csvBundle = csvBundle {
            do {
                csvData = try String(contentsOfFile: csvBundle, encoding: .utf8)
                if let csvData = csvData {
                    var rows = csvData.components(separatedBy: "\n")
                    rows.removeAll { $0.isEmpty }
                    rows.shuffle()
                    
                    self.csvArray = rows.map { row in
                        row.components(separatedBy: ",")
                    }
                    
//                    rows.removeAll { $0.isEmpty }
//                    rows.shuffle()
//                    self.csvArray = rows.map { row in
//                        row.components(separatedBy: ",")
//                    }
//                    
//                    if let index = rows.firstIndex(of: "") {
//                        let emptyRow = rows.remove(at: index)
//                        rows.insert(emptyRow, at: 0)
//                    }
                }
                print(csvArray)
            } catch {
                print("CSVファイルの読み込みに失敗：\(error)")
            }
        } else {
            print("csvファイルのパスが見つかりません")
        }
    }
}

//    let csvBundle = Bundle.main.path(forResource: "GQA_dataset", ofType: "csv")!
//    let csvData = try String(contentsOfFile: csvBundle, encoding: String.Encoding.utf8)
//    let csv: CSV = try EnumeratedCSV(url: URL(fileURLWithPath: path))
//    let rows = csv.rows
