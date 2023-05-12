//
//  compare.swift
//  Draw3D
//
//  Created by Johannes Brands on 02/03/2023.
//

import SwiftUI
import SceneKit
import SceneKit.ModelIO

struct CompareGeometries: View {
    
    let original = SCNScene(named: "SceneKit Asset Catalog.scnassets/cup.usdz")!
        
    var copy: SCNScene {
        var geometryCopy = SCNGeometry()
        original.rootNode.enumerateChildNodes { child, stop in
            if let geometry = child.geometry {
                stop.pointee = true
                geometryCopy = geometry.copy() as! SCNGeometry
                print(geometry.elements.first.debugDescription)
            }
        }
        let node = SCNNode(geometry: geometryCopy)
        let scene = SCNScene()
        scene.rootNode.addChildNode(node)
        return scene
    }
    
    var reconstructed: SCNScene {
        var geometryReconstruction = SCNGeometry()
        original.rootNode.enumerateChildNodes { child, stop in
            if let geometry = child.geometry {
                stop.pointee = true
                let vertexSources = geometry.sources(for: .vertex)
                let normalSources = geometry.sources(for: .normal)
                let colorSources = geometry.sources(for: .color)
                
                geometryReconstruction = SCNGeometry(
                    sources: vertexSources + normalSources + colorSources,
                    elements: geometry.elements)
                
                geometryReconstruction.firstMaterial?.lightingModel = .physicallyBased
            }
        }
        let node = SCNNode(geometry: geometryReconstruction)
        let scene = SCNScene()
        scene.rootNode.addChildNode(node)
        return scene
    }
    
    var thisIsTheWay: SCNScene {
        // Get the geometry of the first mesh in the scene.
        let mdlAsset = MDLAsset(scnScene: original)
        guard let firstMesh = mdlAsset.childObjects(of: MDLMesh.self).first as? MDLMesh else {
            return SCNScene()
        }
        let geometry = SCNGeometry(mdlMesh: firstMesh)

        let vertexSources = geometry.sources(for: .vertex)
        let normalSources = geometry.sources(for: .normal)
        let colorSources = geometry.sources(for: .color)
        
        let geometryReconstruction = SCNGeometry(
            sources: vertexSources + normalSources + colorSources,
            elements: geometry.elements)
        
        geometryReconstruction.firstMaterial?.lightingModel = .physicallyBased
        
        let node = SCNNode(geometry: geometryReconstruction)
        let scene = SCNScene()
        scene.rootNode.addChildNode(node)
        return scene
    }
    
    var body: some View {
        HStack {
            SceneView(scene: original, options: [.autoenablesDefaultLighting, .allowsCameraControl])
                .frame(width: 500, height: 500)
                .border(.black)
            SceneView(scene: copy, options: [.autoenablesDefaultLighting, .allowsCameraControl])
                .frame(width: 500, height: 500)
                .border(.black)
            SceneView(scene: reconstructed, options: [.autoenablesDefaultLighting, .allowsCameraControl])
                .frame(width: 500, height: 500)
                .border(.black)
            SceneView(scene: thisIsTheWay, options: [.autoenablesDefaultLighting, .allowsCameraControl])
                .frame(width: 500, height: 500)
                .border(.black)
        }
    }
}

struct CompareGeometries_Previews: PreviewProvider {
    static var previews: some View {
        CompareGeometries()
    }
}
