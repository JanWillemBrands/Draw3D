//
//  Utilities.swift
//  Draw3D
//
//  Created by Johannes Brands on 27/10/2022.
//

import SwiftUI
import SceneKit

func setFillMode(of node: SCNNode, to fillMode: SCNFillMode) {
    node.enumerateHierarchy { child, stop in
        child.geometry?.firstMaterial?.fillMode = fillMode
//        child.geometry?.firstMaterial?.lightingModel = .physicallyBased
    }
}

func emitWhite(from node: SCNNode?) {
    node?.enumerateHierarchy { child, stop in
        child.geometry?.firstMaterial?.emission.contents = UIColor.white
//        child.geometry?.firstMaterial?.lightingModel = .physicallyBased
    }
}

func emitClear(from node: SCNNode?) {
    node?.enumerateHierarchy { child, stop in
        child.geometry?.firstMaterial?.emission.contents = UIColor.clear
//        child.geometry?.firstMaterial?.lightingModel = .physicallyBased
    }
}

func mainNode(in scene: SCNScene?) -> SCNNode? {
    // Alternatively:
//    return scene?.rootNode.childNodes.first
    
    let node = scene?.rootNode.childNode(withName: "g0", recursively: true)
    //    debugPrint("mainNode 'g0': \(String(describing: node))")
    return node
}

func addAxes(to scene: SCNScene?) -> SCNNode? {
    let a = axes
    scene?.rootNode.addChildNode(a)
    return a
}

func removeAxes(node: SCNNode?) {
    node?.removeFromParentNode()
}

func addNozzle(to scene: SCNScene?) -> SCNNode? {
    let n = nozzle
    scene?.rootNode.addChildNode(n)
    return n
}

func removeNozzle(node: SCNNode?) {
    node?.removeFromParentNode()
}

struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
#if os(iOS)
        configuration.icon
#else
        Label(configuration.title, image: configuration.icon)
#endif
    }
}

func findTextureHits(with renderer: SCNSceneRenderer?, of point: CGPoint) -> [CGPoint]? {
    let hitOptions = [SCNHitTestOption.searchMode: SCNHitTestSearchMode.closest.rawValue]
    
    return renderer?.hitTest(point, options: hitOptions).map { hit in
        hit.textureCoordinates(withMappingChannel: 0)
    }
}

public var vertices: [SCNVector3] = []
public var normals: [SCNVector3] = []
public var vertexColor: [SCNVector4] = []
public var indices: [Int32] = []

//public var hexes: [(Int32, Int32, Int32, Int32, Int32, Int32)] = []
//public var triangles: [(Int32, Int32, Int32)] = []

func textureCoordinateFromScreenCoordinate(with renderer: SCNSceneRenderer?, of point: CGPoint) -> CGPoint? {
    
    let hitOptions = [SCNHitTestOption.searchMode: SCNHitTestSearchMode.closest.rawValue]
    
    guard let hit = renderer?.hitTest(point, options: hitOptions).first else { return nil }
    
    if let geometry = hit.node.geometry {

//        geometry.subdivisionLevel = 3

        // get the sources from the loaded .USDZ file as array of SCNVector3.
        vertices = geometry.vertices()
        print(vertices[...3])
        normals = geometry.normals()
        
        let vertexCount = geometry.sources(for: .vertex).first?.vectorCount ?? 0
        let transparent = SCNVector4(0, 0, 0, 0)
        let opaqueRed   = SCNVector4(1, 0, 0, 1)

        if vertexColor.isEmpty {
            vertexColor = Array(repeating: transparent, count: vertexCount)
        }

        // Ignore all gemetry elements except the first one.
        let firstElement = geometry.element(at: 0)
        
        // Geometry vertex 3D coordinates are Int32 indexes into the vertices array of SCNVector3.
        indices = firstElement.data.withUnsafeBytes { ptr in
            [Int32].init(ptr.bindMemory(to: Int32.self))
        }
        
        // Handle only geometries with triangle faces/primitives.
        guard firstElement.primitiveType == .triangles else { return nil }
        // CAUTION: MAJOR HACK using private methods to deal with USDZ model that contains <SCNGeometryElement: 0x60000382b800 | 25000 x triangle, 2 channels, int indices>
        var channelCount = 1
        if firstElement.hasInterleavedIndicesChannels() {
            channelCount = firstElement.indicesChannelCount()
        }
        let stepsize = 3 * channelCount
        
        let corner1 = hit.faceIndex * stepsize
        let corner2 = hit.faceIndex * stepsize + channelCount
        let corner3 = hit.faceIndex * stepsize + channelCount * 2
        
        // Color the vertices (corners) of the triangle face that was hit.
        vertexColor[Int(indices[corner1])] = opaqueRed
        vertexColor[Int(indices[corner2])] = opaqueRed
        vertexColor[Int(indices[corner3])] = opaqueRed

        // Convert the array of paint colors into a geometry color source.
        let paintSource = SCNGeometrySource(
            data: vertexColor.withUnsafeBytes { ptr in .init(ptr) },
            semantic: .color,
            vectorCount: vertexColor.count,
            usesFloatComponents: true,
            componentsPerVector: 4,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<SCNVector4>.size)

        let newGeometry = SCNGeometry(
            sources: geometry.sources + [paintSource],
            elements: geometry.elements
        )
//        hit.node.geometry = newGeometry
        
        // Assign the new geometry to a node that is above the node that contains the original materials.
        renderer?.scene?.rootNode.childNodes.first?.geometry = newGeometry
                
//        renderer?.scene?.rootNode.geometry = newGeometry
    }
    
    return hit.textureCoordinates(withMappingChannel: 0)
}

func apply(_ hits: [CGPoint]?, to texture: UIImage?) -> UIImage? {
    guard let hits else { return nil }
    
    var img: UIImage?
    if let texture {
        let size = texture.size
        let area = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(size)
        
        texture.draw(in: area)
        
        let ctx = UIGraphicsGetCurrentContext()!
        
        for hit in hits {
            //                    ctx.saveGState()
            let hitPoint = CGPoint(x: hit.x * size.width, y: hit.y * size.height)
            logger.debug("hitPoint at: \(hitPoint.debugDescription)")
            let rect = CGRect(x: hitPoint.x-10, y: hitPoint.y-10, width: 20, height: 20)
            ctx.setFillColor(UIColor.tintColor.cgColor)
            ctx.fillEllipse(in: rect)
            //                    ctx.restoreGState()
        }
        
        img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    return img
}

func blend(texture: UIImage?, with image: UIImage?) -> UIImage? {
    var img: UIImage?
    if let texture {
        let size = texture.size
        let area = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(size)
        
        texture.draw(in: area)
        
        image?.draw(in: area, blendMode: .normal, alpha: 1)
        
        //        let ctx = UIGraphicsGetCurrentContext()!
        //        ctx.saveGState()
        //        let rect = CGRect(x: 0, y: 0, width: 512, height: 512)
        //        ctx.setFillColor(UIColor.tintColor.cgColor)
        //        ctx.fillEllipse(in: rect)
        //        ctx.restoreGState()
        
        img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    return img
}

//func UItoCI() {
//    let ui = UIImage(named: "apple")
//    if let cg = ui?.cgImage {
//        let ci = CIImage(cgImage: cg)
//    }
//}
