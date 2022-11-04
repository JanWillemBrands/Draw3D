//
//  ImportExport.swift
//  Draw3D
//
//  Created by Johannes Brands on 27/10/2022.
//

import SceneKit

func getModelFrom(_ url: URL) -> (SCNScene?, UIImage?) {
    var scene: SCNScene?
    var texture: UIImage?
    
    // getting the scene is straighforward.
    scene = try? SCNScene(url: url, options: [.checkConsistency: true])
    
    // getting the texture requires first loading them.
    let mdlAsset = MDLAsset(url: url)
    mdlAsset.loadTextures()
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

    return (scene, texture)
}

