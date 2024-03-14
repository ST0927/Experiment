//
//  SwiftUIView.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2024/01/11.
//

import SwiftUI

//struct ScrollOffsetYPreferenceKey: PreferenceKey {
//    static var defaultValue: [CGFloat] = [0]
//    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
//        value.append(contentsOf: nextValue())
//    }
//}
//
//struct ContentsView: View {
//    @State  private var offsetY: CGFloat = 0
//    @State  private var initOffsetY: CGFloat = 0
//    @State  private var result: CGFloat = 0
//    
//    var body: some View {
//        ZStack {
//            ScrollView {
//                VStack {
//                    ForEach(1...100, id: \.self) {
//                        Text("Item \($0)")
//                            .padding()
//                    }
//                }.background(
//                    GeometryReader { geometry in
//                        Color.clear
//                            .preference(
//                                key: ScrollOffsetYPreferenceKey.self,
//                                value: [geometry.frame(in: .global).minY]
//                            ).onAppear {
//                                initOffsetY = geometry.frame(in: .global).minY
//                            }
//                    }
//                )
//            }
//            .onPreferenceChange(ScrollOffsetYPreferenceKey.self) { value in
//                offsetY = value[0]
//                print(offsetY - initOffsetY)
//                result = offsetY - initOffsetY
//            
//        }
//            Text("\(offsetY - initOffsetY)")
//        }
//    }
//}

//#Preview {
//    ContentsView()
//}
