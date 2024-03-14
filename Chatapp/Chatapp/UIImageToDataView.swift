//
//  UIImageToDataView.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/11/11.
//

//import SwiftUI
//
//struct DataToUIImageView: View {
//    
//    let imageData: Data?
//    
//    var body: some View {
//        if let imageData, let uiImage = UIImage(data: imageData) {
//            Image(uiImage: uiImage)
//        }
//    }
//}
//
//struct UIImageToDataView: View {
//    @AppStorage("imageData") var imageData: Data?
//    let uiImage: UIImage?
//    
//    var body: some View {
//        Button("保存") {
//            guard let uiImage = uiImage else { return }
//            imageData = uiImage.pngData()
//        }
//    }
//}
//
//#Preview {
//    UIImageToDataView()
//}
