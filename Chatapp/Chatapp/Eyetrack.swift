//
//  Eyetrack.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2024/10/21.
//

import UIKit
import ARKit
import SwiftUI

// ViewControllerクラス: UIViewControllerを継承し、画面の制御を行います。

struct EyetrackView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Eyetrack {
        return Eyetrack()
    }
    
    func updateUIViewController(_ uiViewController: Eyetrack, context: Context) {}
}

final class Eyetrack: UIViewController {
    
    // ARセッション: ARKitの機能を使用するためのセッションを管理します。
    private let session = ARSession()

    // 視線追跡点を表示するUIImageView: ここでは目のアイコンを使用しています。
    private var lookAtPointView: UIImageView = {
        let image = UIImageView(image: .init(systemName: "eye")) // アイコンの種類を変更する場合、"eye"を他のシステム名に変更します。
        image.frame = .init(origin: .zero, size: CGSize(width: 30, height: 30))
        // アイコンのサイズを変更する場合、ここのwidthとheightを調整します。
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    // 最後に追跡された視線のポイントを保持する変数。
    private var lastLookAtPoint: CGPoint?
    
    // 視線のドットの色: 初期値は赤色です。
    private var dotColor: UIColor = .red // ドットの色を変更する場合は、ここを任意のUIColorに変更します。
    
    // 最後に検出された顔のアンカーを保持する変数。
    private var lastFaceAnchor: ARFaceAnchor?
    
    // ビューがメモリにロードされた後に呼び出されるメソッド。
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(lookAtPointView) // 視線追跡点のビューを画面に追加します。
        session.delegate = self // ARセッションのデリゲートを自身に設定します。
    }
    
    // ビューが画面に表示される直前に呼び出されるメソッド。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let configuration = ARFaceTrackingConfiguration() // 顔追跡用のARセッション設定を作成します。
        configuration.isLightEstimationEnabled = true // 環境光の推定を有効にします（必要に応じて変更可能）。
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors]) // ARセッションを開始します。
    }
}

// ARSessionDelegateプロトコルに準拠する拡張部分。
extension Eyetrack: ARSessionDelegate {
    
    // ARセッションが新しいフレームを受け取るたびに呼ばれるメソッド。
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let faceAnchor = frame.anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor else {
            return // 顔のアンカーが検出されなかった場合、ここで処理を中断します。
        }
        lastFaceAnchor = faceAnchor // 検出された顔のアンカーを保存します。

        let orientation = currentDeviceOrientation() // デバイスの現在の向きを取得します。
        
        // 顔の視線ポイントをカメラ座標からビュー座標に変換します。
        let lookingPoint = frame.camera.projectPoint(faceAnchor.lookAtPoint,
                                                     orientation: orientation,
                                                     viewportSize: view.bounds.size)
        
        // 補間率を調整して視線の動きを滑らかにします。
        let interpolationRate: CGFloat = 0.95 // 補間率を高くすることで動きを滑らかにします（0.8から1.0の範囲で調整可能）。
        let smoothLookAtPoint = lastLookAtPoint.map { lerp(start: $0, end: lookingPoint, t: interpolationRate) } ?? lookingPoint
        lastLookAtPoint = smoothLookAtPoint // 新しい視線追跡点を保存します。
        
        DispatchQueue.main.async {
            // 視線追跡点をビューポート内に制限して、中心点を設定します。
            self.lookAtPointView.center = self.clampToViewport(point: smoothLookAtPoint)
        }
    }
    
    // 線形補間関数。2点間を滑らかに補間します。
    private func lerp(start: CGPoint, end: CGPoint, t: CGFloat) -> CGPoint {
        return CGPoint(x: start.x + (end.x - start.x) * t, y: start.y + (end.y - start.y) * t)
    }
    
    // ポイントをビューポート内に制限するための関数。
    private func clampToViewport(point: CGPoint) -> CGPoint {
        return CGPoint(
            x: min(max(point.x, 0), view.bounds.width),
            y: min(max(point.y, 0), view.bounds.height)
        )
    }

    
    // 現在のデバイスの向きを取得する関数。
    private func currentDeviceOrientation() -> UIInterfaceOrientation {
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        _ = windowScenes?.windows.first

        return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .unknown
    }
}


//#Preview {
//    Eyetrack()
//}
