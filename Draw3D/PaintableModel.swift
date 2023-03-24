//
//  PaintableModel.swift
//  Draw3D
//
//  Created by Johannes Brands on 04/11/2022.
//

// https://stackoverflow.com/questions/69480030/extract-faces-information-from-scngeometry-in-scenekit
// https://stackoverflow.com/questions/48428988/scenekit-how-to-identify-and-access-faces-from-3d-model
// https://stackoverflow.com/questions/17250501/extracting-vertices-from-scenekit/66748865#66748865

import SceneKit

class PaintableModel {
    
    let paintScene = SCNScene()
    var paintNode = SCNNode()
    
    public var vertices: [SCNVector3] = []
    public var normals:  [SCNVector3] = []
    public var colors:   [SCNVector4] = []
    public var indices:  [Int32] = []
    
    var vertexSource = SCNGeometrySource()
    var normalSource = SCNGeometrySource()
    var colorSource  = SCNGeometrySource()

    var texture = UIImage()
    
    let transparent = SCNVector4(0, 0, 0, 0)
    let opaqueRed   = SCNVector4(1, 0, 0, 1)
    
    init(from scene: SCNScene) {
        
        // Find the first node in the scene that contains a geometry.
        scene.rootNode.enumerateHierarchy { child, stop in
            if let geometry = child.geometry {
                stop.pointee = true
                //        geometry.subdivisionLevel = 3

                // Save a copy of the diffuse material.
                texture = geometry.firstMaterial?.diffuse.contents as? UIImage ?? UIImage()

                // Get the face indices from the first element as an array.
                indices = geometry.element(at: 0).data.withUnsafeBytes { ptr in
                    [Int32].init(ptr.bindMemory(to: Int32.self))
                }

                if let vs = geometry.sources(for: .vertex).first {
                    // Extract the vertex coordinates as an array.
                    vertices = vs.data.withUnsafeBytes { ptr in
                        [SCNVector3].init(ptr.bindMemory(to: SCNVector3.self))
                    }
                    vertexSource = vs
                }
                
                if let ns = geometry.sources(for: .normal).first {
                    // Extract the vertex normals as an array.
                    normals = ns.data.withUnsafeBytes { ptr in
                        [SCNVector3].init(ptr.bindMemory(to: SCNVector3.self))
                    }
                    normalSource = ns
                }
                
                if let cs = geometry.sources(for: .color).first {
                    // Extract the vertex colors as an array.
                    colors = cs.data.withUnsafeBytes { ptr in
                        [SCNVector4].init(ptr.bindMemory(to: SCNVector4.self))
                    }
                    colorSource = cs
                } else {
                    // Create a transparent per-vertex color source to use as a paint layer.
                    colors = Array(repeating: transparent, count: vertices.count)
                }
                
                // TODO: Add some random paint for testing purposes.
                for i in stride(from: 0, to: colors.count, by: 2) {
                    colors[i] = opaqueRed
                }
                
                // Convert the array of paint colors into a geometry color source.
                let paintSource = SCNGeometrySource(
                    data: colors.withUnsafeBytes { ptr in .init(ptr) },
                    semantic: .color,
                    vectorCount: colors.count,
                    usesFloatComponents: true,
                    componentsPerVector: 4,
                    bytesPerComponent: MemoryLayout<Float>.size,
                    dataOffset: 0,
                    dataStride: MemoryLayout<SCNVector4>.size)
                
                // Create a geometry with a single color paint source.
                let geometryWithPaint = SCNGeometry(
                    sources: [vertexSource] + [normalSource] + [paintSource],
                    elements: geometry.elements
                )
                paintNode = SCNNode(geometry: geometryWithPaint)
                paintNode.name = "paintnode"
                // Copy the roughness to make the paint look similar to the original surface.
                paintNode.geometry?.materials.first?.roughness.contents = geometry.firstMaterial?.roughness.contents
                paintNode.geometry?.firstMaterial?.lightingModel = .physicallyBased

                // Create a copy of the original node.
                let copyNode = SCNNode(geometry: geometry)
                copyNode.name = "copynode"
                copyNode.geometry?.firstMaterial?.lightingModel = .physicallyBased

                // Build a modified scene with the paint node on top of the copy node.
                paintScene.rootNode.addChildNode(paintNode)
                paintNode.addChildNode(copyNode)
            }
        }
    }
    
    func paintTriangleFace(of renderer: SCNSceneRenderer?, at point: CGPoint) {
        
        let hitOptions = [SCNHitTestOption.searchMode: SCNHitTestSearchMode.closest.rawValue]
        
        guard let hit = renderer?.hitTest(point, options: hitOptions).first else { return }
        
        if let geometry = hit.node.geometry {
            
            // Ignore all geometry elements except the first one.
            let firstElement = geometry.element(at: 0)
            
            // Handle only geometries with triangle faces/primitives.
            guard firstElement.primitiveType == .triangles else { return }
            
            // CAUTION: MAJOR HACK using private methods to deal with USDZ model that contains <SCNGeometryElement: 0x60000382b800 | 25000 x triangle, 2 channels, int indices>
            var channelCount = 1
            if firstElement.hasInterleavedIndicesChannels() {
                channelCount = firstElement.indicesChannelCount()
            }
            
            // Find the three corners of the face that was hit.
            let stepsize = 3 * channelCount
            let corner1 = hit.faceIndex * stepsize
            let corner2 = hit.faceIndex * stepsize + channelCount
            let corner3 = hit.faceIndex * stepsize + channelCount + channelCount
            
            // Color the vertices of the triangle face that was hit.
            colors[Int(indices[corner1])] = opaqueRed
            colors[Int(indices[corner2])] = opaqueRed
            colors[Int(indices[corner3])] = opaqueRed
            
            // Convert the array of paint colors into a geometry color source.
            let paintSource = SCNGeometrySource(
                data: colors.withUnsafeBytes { ptr in .init(ptr) },
                semantic: .color,
                vectorCount: colors.count,
                usesFloatComponents: true,
                componentsPerVector: 4,
                bytesPerComponent: MemoryLayout<Float>.size,
                dataOffset: 0,
                dataStride: MemoryLayout<SCNVector4>.size)
            
            // Update the geometry with the new color paint source.
            let geometryWithPaint = SCNGeometry(
                sources: [vertexSource] + [normalSource] + [paintSource],
                elements: geometry.elements
            )
            
            // Rebuild the paint layer.
            paintNode = SCNNode(geometry: geometryWithPaint)
        }
    }
    
}

extension SCNGeometry {
    
//    func vertices_old() -> [SCNVector3] {
//        guard let source = self.sources(for: .vertex).first else { return [] }
//
//        let stride = source.dataStride / source.bytesPerComponent
//        let offset = source.dataOffset / source.bytesPerComponent
//
//        return source.data.withUnsafeBytes { dataBytes in
//            let buffer: UnsafePointer<Float> = dataBytes.baseAddress!.assumingMemoryBound(to: Float.self)
//            var result: [SCNVector3] = []
//            for i in 0 ..< source.vectorCount {
//                let start = i * stride + offset
//                let x = buffer[start]
//                let y = buffer[start + 1]
//                let z = buffer[start + 2]
//                result.append(SCNVector3(x, y, z))
//            }
//            return result
//        }
//    }
    
    func vertices() -> [SCNVector3] {
        guard let source = self.sources(for: .vertex).first else { return [] }
        
        return source.data.withUnsafeBytes { ptr in
            [SCNVector3].init(ptr.bindMemory(to: SCNVector3.self))
        }
    }
    
//    func normals_old() -> [SCNVector3] {
//        guard let source = self.sources(for: .normal).first else { return [] }
//
//        let stride = source.dataStride / source.bytesPerComponent
//        let offset = source.dataOffset / source.bytesPerComponent
//
//        return source.data.withUnsafeBytes { dataBytes in
//            let buffer: UnsafePointer<Float> = dataBytes.baseAddress!.assumingMemoryBound(to: Float.self)
//            var result: [SCNVector3] = []
//            for i in 0 ..< source.vectorCount {
//                let start = i * stride + offset
//                let x = buffer[start]
//                let y = buffer[start + 1]
//                let z = buffer[start + 2]
//                result.append(SCNVector3(x, y, z))
//            }
//            return result
//        }
//    }
    
    func normals() -> [SCNVector3] {
        guard let source = self.sources(for: .normal).first else { return [] }
        
        return source.data.withUnsafeBytes { ptr in
            [SCNVector3].init(ptr.bindMemory(to: SCNVector3.self))
        }
    }
    
//    func colors_old() -> [SCNVector4] {
//        guard let source = self.sources(for: .color).first else { return [] }
//
//        let stride = source.dataStride / source.bytesPerComponent
//        let offset = source.dataOffset / source.bytesPerComponent
//
//        return source.data.withUnsafeBytes { dataBytes in
//            let buffer: UnsafePointer<Float> = dataBytes.baseAddress!.assumingMemoryBound(to: Float.self)
//            var result: [SCNVector4] = []
//            for i in 0 ..< source.vectorCount {
//                let start = i * stride + offset
//                let x = buffer[start]
//                let y = buffer[start + 1]
//                let z = buffer[start + 2]
//                let w = buffer[start + 3]
//                result.append(SCNVector4(x, y, z, w))
//            }
//            return result
//        }
//    }
    
    func colors() -> [SCNVector4] {
        guard let source = self.sources(for: .color).first else { return [] }
        
        return source.data.withUnsafeBytes { ptr in
            [SCNVector4].init(ptr.bindMemory(to: SCNVector4.self))
        }
    }
    
}

