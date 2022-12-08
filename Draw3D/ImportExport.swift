//
//  ImportExport.swift
//  Draw3D
//
//  Created by Johannes Brands on 27/10/2022.
//

import SceneKit
import SceneKit.ModelIO

// When this gets called the URL is assumed valid.
func getModelFrom(_ url: URL) -> (SCNScene?, UIImage?) {
    var scene: SCNScene?
    var texture: UIImage?
    
    scene = try? SCNScene(url: url, options: [.checkConsistency: true])
    
    let mdlAsset = MDLAsset(url: url)
    
    // Getting the texture requires first loading them.
    mdlAsset.loadTextures()
    
    // Alternatively:
    //    scene = SCNScene(mdlAsset: mdlAsset)
        
    let mdlMeshes = mdlAsset.childObjects(of: MDLMesh.self) as? [MDLMesh]
    let firstMesh = mdlMeshes?.first
    let firstSubmesh = firstMesh?.submeshes?.firstObject as? MDLSubmesh
    let mdlMaterial = firstSubmesh?.material
    let baseColor = mdlMaterial?.property(with: .baseColor)
    let textureSamplerValue = baseColor?.textureSamplerValue
    let mdlTexture = textureSamplerValue?.texture
    if let imageFromTexture = mdlTexture?.imageFromTexture()?.takeUnretainedValue() {
        texture = UIImage(cgImage: imageFromTexture)
    }
    
    // Alternatively:
//    let x = scene?.rootNode.childNodes.first?.geometry?.firstMaterial?.diffuse.contents as? UIImage
    
    return (scene, texture)
}

