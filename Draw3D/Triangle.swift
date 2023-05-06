//
//  PrefabNodes.swift
//  Draw3D
//
//  Created by Johannes Brands on 08/11/2022.
//

import SceneKit

// a triangle in the XY plane

var triangleScene: SCNScene {
    let scene = SCNScene()
    
    scene.rootNode.addChildNode(triangleNode)
    
    return scene
}

var triangleNode: SCNNode {
    let vertices: [SCNVector3] = [SCNVector3(0, 0, 0),
                                  SCNVector3(0, 1, 0),
                                  SCNVector3(1, 0, 0),
                                  SCNVector3(1, 1, 0),
    ]
    let vertexData = Data(
        bytes: vertices,
        count: vertices.count * MemoryLayout<SCNVector3>.size
    )
    let vertexSource = SCNGeometrySource(
        data: vertexData,
        semantic: SCNGeometrySource.Semantic.vertex,
        vectorCount: vertices.count,
        usesFloatComponents: true,
        componentsPerVector: 3,
        bytesPerComponent: MemoryLayout<Float>.size,
        dataOffset: 0,
        dataStride: MemoryLayout<SCNVector3>.size
    )
    
    // Faces
    let indices: [Int32] = [0, 2, 1, 1, 2, 3]
    
//    let indexData = Data(
//        bytes: indices,
//        count: indices.count * MemoryLayout<Int32>.size
//    )
//    let indexElement = SCNGeometryElement(
//        data: indexData,
//        primitiveType: SCNGeometryPrimitiveType.triangles,
//        primitiveCount: indices.count / 3,
//        bytesPerIndex: MemoryLayout<Int32>.size
//    )
    
    let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
    
    // Normals
    let normals: [SCNVector3] = [SCNVector3(0, 0, 1),
                                 SCNVector3(0, 0, 1),
                                 SCNVector3(0, 0, 1),
                                 SCNVector3(0, 0, 1),
    ]
    let normalData = Data(
        bytes: normals,
        count: normals.count * MemoryLayout<SCNVector3>.size
    )
    let normalSource = SCNGeometrySource(
        data: normalData,
        semantic: SCNGeometrySource.Semantic.normal,
        vectorCount: normals.count,
        usesFloatComponents: true,
        componentsPerVector: 3,
        bytesPerComponent: MemoryLayout<Float>.size,
        dataOffset: 0,
        dataStride: MemoryLayout<SCNVector3>.size
    )
    
    // TODO: replace all this shit with RealityKit
    
    // Colors
    let colors: [SCNVector4] = [SCNVector4(1.0, 0.0, 0.0, 1.0),
                                SCNVector4(0.0, 1.0, 0.0, 1.0),
                                SCNVector4(0.0, 0.0, 1.0, 1.0),
                                SCNVector4(0.0, 1.0, 0.0, 1.0),
     ]
    let colorData = Data(
        bytes: colors,
        count: colors.count * MemoryLayout<SCNVector4>.size
    )
    let colorSource = SCNGeometrySource(
        data: colorData,
        semantic: SCNGeometrySource.Semantic.color,
        vectorCount: colors.count,
        usesFloatComponents: true,
        componentsPerVector: 4,
        bytesPerComponent: MemoryLayout<Float>.size,
        dataOffset: 0,
        dataStride: MemoryLayout<SCNVector4>.size
    )
    
    let geometry = SCNGeometry(
        sources: [vertexSource, normalSource, colorSource],
        elements: [element]
//        elements: [indexElement]
    )
    let material = SCNMaterial()
    material.diffuse.contents = UIColor.white
    geometry.materials = [material]
    
    let node = SCNNode(geometry: geometry)
    node.position = SCNVector3(0, 0, 0)
    
    return node
}

