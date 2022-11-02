//
//  SceneViewContainer.swift
//  Draw3D
//
//  Created by Johannes Brands on 27/10/2022.
//

import SwiftUI
import SceneKit

struct SceneViewRepresentatable: UIViewRepresentable {
    var scene: SCNScene?
    var view = SCNView()
    
    @Binding var showTechnical: Bool
    
    func makeUIView(context: Context) -> SCNView {
        view.scene = scene
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true        
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = scene
        if showTechnical {
            uiView.showsStatistics = true
            uiView.debugOptions = [.renderAsWireframe]
            emitWhite(from: mainNode(in: uiView.scene))
            uiView.backgroundColor = UIColor.black
        } else {
            uiView.showsStatistics = false
            uiView.debugOptions = []
            emitClear(from: mainNode(in: uiView.scene))
            uiView.backgroundColor = UIColor.white
        }

        let pov = uiView.pointOfView
        let camera = pov?.camera
        let pt = camera?.projectionTransform
        debugPrint("camera pt \(String(describing: pt))")
    }
    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(view)
//    }
//
//    class Coordinator: NSObject {
//        private let view: SCNView
//        init(_ view: SCNView) {
//            self.view = view
//            super.init()
//        }
//    }
}
