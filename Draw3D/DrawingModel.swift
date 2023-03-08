//
//  DrawingModel.swift
//  Draw3D
//
//  Created by Johannes Brands on 08/12/2022.
//

//import SwiftUI
import SceneKit
import SceneKit.ModelIO
//import ModelIO

class DrawingModel: ObservableObject {
    
    var mdlAsset: MDLAsset = MDLAsset()
    
    @Published var plasmaActive = false
    
    func getModelFrom(_ url: URL) -> (SCNScene?, UIImage?) {
        var scene: SCNScene?
        var texture: UIImage?
        
        // Load the SCNScene directly, which works for .usdz files.
        scene = try? SCNScene(url: url, options: [.checkConsistency: true])
        
        // Load the MDLAsset and the textures.
        mdlAsset = MDLAsset(url: url)
        mdlAsset.loadTextures()
        
        // Alternatively:
//            scene = SCNScene(mdlAsset: mdlAsset)
            
        let mdlMeshes = mdlAsset.childObjects(of: MDLMesh.self) as? [MDLMesh]
        let firstMesh = mdlMeshes?.first
        let firstSubmesh = firstMesh?.submeshes?.firstObject as? MDLSubmesh
        let mdlMaterial = firstSubmesh?.material
        let baseColor = mdlMaterial?.property(with: .baseColor)
        let textureSamplerValue = baseColor?.textureSamplerValue
        let mdlTexture = textureSamplerValue?.texture
        if let imageFromTexture = mdlTexture?.imageFromTexture()?.takeUnretainedValue() {
            texture = UIImage(cgImage: imageFromTexture)
        } else {
            texture = scene?.rootNode.childNodes.first?.geometry?.firstMaterial?.diffuse.contents as? UIImage
        }
        
//        scene?.rootNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
        
        // TODO: why is this necessary to remove flickering when rotating model?
        let material = SCNMaterial()
        material.diffuse.contents = texture
                
        print("dump bl")
        scene?.rootNode.enumerateHierarchy { child, stop in
            print("dump bl", child.debugDescription)
            if let geometry = child.geometry {
                print("dump bl", geometry.materials)
            }
        }

        mainNode(in: scene)?.geometry?.materials = [material]
        
//        mainNode(in: scene)?.geometry?.firstMaterial?.lightingModel = .physicallyBased

        print("dump m", mainNode(in: scene)!.geometry!)
        
        print("dump al")
        scene?.rootNode.enumerateHierarchy { child, stop in
            print("dump al", child.debugDescription)
            if let geometry = child.geometry {
                print("dump al", geometry.materials)
            }
        }


        return (scene, texture)
    }

    
}
