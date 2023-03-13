//
//  Utilities.swift
//  Draw3D
//
//  Created by Johannes Brands on 27/10/2022.
//

import SwiftUI
import SceneKit

// TODO: only emit white from the original geometry node, not from anything else.
// TODO: give the original and paintnodes a "name" !!!
func mainNode(in scene: SCNScene?) -> SCNNode? {
    return scene?.rootNode.childNode(withName: "g0", recursively: true)
//    return scene?.rootNode.childNode(withName: "copynode", recursively: true)
}

public var vertices: [SCNVector3] = []
public var normals: [SCNVector3] = []
public var vertexColor: [SCNVector4] = []
public var indices: [Int32] = []

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
