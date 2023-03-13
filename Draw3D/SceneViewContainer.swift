//
//  SceneViewContainer.swift
//  Draw3D
//
//  Created by Johannes Brands on 27/10/2022.
//

import SwiftUI
import SceneKit

struct SceneViewContainer: UIViewRepresentable {
    var view = SCNView()

    var scene: SCNScene?
    
    @Binding var renderer: SCNSceneRenderer?
    
    @Binding var showWireframe: Bool
    
    func makeUIView(context: Context) -> SCNView {
        view.scene = scene
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = scene
        if showWireframe {
            uiView.showsStatistics = true
            uiView.debugOptions = [.renderAsWireframe]
            
            // To avoid (un)coloring the axes and nozzle, we only change the mainnode.
            mainNode(in: uiView.scene)?.enumerateHierarchy { child, stop in
                child.geometry?.firstMaterial?.emission.contents = UIColor.white
            }
            uiView.backgroundColor = UIColor.black
        } else {
            uiView.showsStatistics = false
            uiView.debugOptions = []
            
            mainNode(in: uiView.scene)?.enumerateHierarchy { child, stop in
                child.geometry?.firstMaterial?.emission.contents = UIColor.clear
            }
            uiView.backgroundColor = UIColor.white
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, SCNSceneRendererDelegate {
        var parent: SceneViewContainer
        
        init(_ view: SceneViewContainer) {
            self.parent = view
            super.init()
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
            parent.renderer = renderer
        }
    }
}
