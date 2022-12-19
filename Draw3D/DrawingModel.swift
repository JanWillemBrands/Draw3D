//
//  DrawingModel.swift
//  Draw3D
//
//  Created by Johannes Brands on 08/12/2022.
//

//import SwiftUI
import SceneKit.ModelIO
//import ModelIO

class DrawingModel: ObservableObject {
    
    var asset: MDLAsset = MDLAsset()
    
    var scene: SCNScene = SCNScene()
    
    var mainNode: SCNNode = SCNNode()
    
    var texture: UIImage = UIImage(named: "KanaKanaTexture")!
    
    public var vertices: [SCNVector3] = []
    public var normals: [SCNVector3] = []
    public var colors: [SCNVector4] = []
    public var triangles: [(Int32, Int32, Int32)] = []
    
    public var vertexSources: [SCNGeometrySource] = []
    public var normalSources: [SCNGeometrySource] = []
    public var textureSources: [SCNGeometrySource] = []
    
    public var materials: [SCNMaterial] = []
    
    public var elements: [SCNGeometryElement] = []
    
    @Published var plasmaActive = false
    
    func getModelFrom(_ url: URL) {
        
        // The below approach is good for .usdz files that may become interleaved when initialized as SCNScene directly.
        // CAUTION: MAJOR HACK to deal with USDZ model that contains <SCNGeometryElement: 0x60000382b800 | 25000 x triangle, 2 channels, int indices>
        // Reading a .usdz file from SCNScene init will yield INTERLEAVED geometry elements.
        // Furtunately reading a .usdz file from MDLAsset init will not be interleaved.
        // MDLAsset can be easily converted into SCNScene.
        asset = MDLAsset(url: url)
        asset.loadTextures()
        scene = SCNScene(mdlAsset: asset)
        
        // TODO:
        // The below approach is good for .obj and .stl files that may not have the right units and may have the wrong axes orientation.
        //        scene = try! SCNScene(url: url, options: [
        //            .checkConsistency: true,
        //            .convertToYUp: true,
        //            .convertUnitsToMeters: true])
        
        let mdlMeshes = asset.childObjects(of: MDLMesh.self) as? [MDLMesh]
        let firstMesh = mdlMeshes?.first
        let firstSubmesh = firstMesh?.submeshes?.firstObject as? MDLSubmesh
        let mdlMaterial = firstSubmesh?.material
        let baseColor = mdlMaterial?.property(with: .baseColor)
        let textureSamplerValue = baseColor?.textureSamplerValue
        let mdlTexture = textureSamplerValue?.texture
        if let imageFromTexture = mdlTexture?.imageFromTexture()?.takeUnretainedValue() {
            texture = UIImage(cgImage: imageFromTexture)
        } else if let imageFromScene = scene.rootNode.childNodes.first?.geometry?.firstMaterial?.diffuse.contents as? UIImage {
            texture = imageFromScene
        }
        
        //        scene?.rootNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
        
        // Make the main node  the first node with a non-nil geometry.
        scene.rootNode.enumerateHierarchy { child, stop in
            print(child.debugDescription)
            if child.geometry != nil {
                mainNode = child
                stop.pointee = true
            }
        }

        // Create a new scene with just the main node.
        scene = SCNScene()
        scene.rootNode.addChildNode(mainNode)
        
        // Create a duplicate node that doesn't get altered by the painting.
//        let copy = mainNode.clone()
//        copy.position = SCNVector3(0.0001, 0.0001, 0.0001)
//        scene.rootNode.addChildNode(copy)
        
        if let geometry = scene.rootNode.childNodes.first?.geometry {
            vertexSources = geometry.sources(for: .vertex)
            normalSources = geometry.sources(for: .normal)
            textureSources = geometry.sources(for: .texcoord)
            
            materials = geometry.materials

            // let colorSources = geometry.sources(for: .color)             // there may be one or zero color source.
            elements = geometry.elements                             // there is always at least one element.

            // Get the vertices and normals as array of SCNVector3.
            vertices = geometry.vertices()
            normals = geometry.normals()
            
            // Create new vertex color data, overwriting any pre-existing vertex color data that might have been in the original data.
            colors = [SCNVector4](repeating: SCNVector4(1, 1, 1, 0), count: vertices.count)
            
            triangles = geometry.elements.first!.triangles
        }
    }
    
    func changeColorOfFaceRenderedAtScreenCoordinate(with renderer: SCNSceneRenderer?, of point: CGPoint) {
        
        guard let hit = renderer?.hitTest(point).first else { return }
        
        let hitTriangle = triangles[hit.faceIndex]
        
        // Color the vertices of the hit triangle red.
        colors[Int(hitTriangle.0)] = SCNVector4(1, 0, 0, 0)
        colors[Int(hitTriangle.1)] = SCNVector4(1, 0, 0, 0)
        colors[Int(hitTriangle.2)] = SCNVector4(1, 0, 0, 0)
        
        let colorSources = [SCNGeometrySource(colors: colors)]
        let coloredGeometry = SCNGeometry(
            sources: vertexSources + normalSources + textureSources + colorSources,
            elements: elements
        )
        coloredGeometry.materials = materials
        mainNode.geometry = coloredGeometry
    }
    
}
