//
//  VertexModel.swift
//  Draw3D
//
//  Created by Johannes Brands on 04/11/2022.
//

import SceneKit

// a triangle in the XY plane

var triangleScene: SCNScene {
    let scene = SCNScene()
    
    scene.rootNode.addChildNode(triangleNode)
    
    return scene
}

var triangleNode: SCNNode {
    // Vertices
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
    let indices: [Int32] = [0,2,1,1,2,3]
    
    let indexData = Data(
        bytes: indices,
        count: indices.count * MemoryLayout<Int32>.size
    )
    let indexElement = SCNGeometryElement(
        data: indexData,
        primitiveType: SCNGeometryPrimitiveType.triangles,
        primitiveCount: indices.count / 3,
        bytesPerIndex: MemoryLayout<Int32>.size
    )
    
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
    
    // Colors
    let colors: [SCNVector4] = [SCNVector4(0.5, 0.5, 0.5, 1.0),
                                SCNVector4(0.5, 0.5, 0.5, 1.0),
                                SCNVector4(0.5, 0.5, 0.5, 1.0),
                                SCNVector4(0.5, 0.5, 0.5, 1.0),
     ]
    let colorData = Data(
        bytes: colors,
        count: colors.count * MemoryLayout<SCNVector3>.size
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
    
    // Geometry
    let voxelGeometry = SCNGeometry(
        sources: [vertexSource, normalSource, colorSource],
        elements: [indexElement]
    )
    let voxelMaterial = SCNMaterial()
    voxelMaterial.diffuse.contents = UIColor.white
    voxelGeometry.materials = [voxelMaterial]
    
    let voxelNode = SCNNode(geometry: voxelGeometry)
    voxelNode.position = SCNVector3(0, 0, 0)
    
    return voxelNode
}

extension SCNGeometrySource {
    convenience init(data: [SCNVector3], semantic: SCNGeometrySource.Semantic) {
        let sourceData = Data(
            bytes: data,
            count: data.count * MemoryLayout<SCNVector3>.size
        )
        
        self.init(
            data: sourceData,
            semantic: semantic,
            vectorCount: data.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<SCNVector3>.size
        )
    }
}

extension SCNGeometrySource {
    convenience init(colors: [SCNVector4]) {
        let sourceData = Data(
            bytes: colors,
            count: colors.count * MemoryLayout<SCNVector4>.size
        )
        
        self.init(
            data: sourceData,
            semantic: .color,
            vectorCount: colors.count,
            usesFloatComponents: true,
            componentsPerVector: 4,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<SCNVector4>.size
        )
    }
}

extension SCNGeometryElement {
    convenience init(data: [Int32]) {
        let elementData = Data(
            bytes: data,
            count: data.count * MemoryLayout<Int32>.size
        )
        
        self.init(
            data: elementData,
            primitiveType: SCNGeometryPrimitiveType.triangles,
            primitiveCount: data.count / 3,
            bytesPerIndex: MemoryLayout<Int32>.size
        )
    }
}

extension Collection {
    func chunked(into size: Index.Stride) -> [[Element]] where Index: Strideable {
        precondition(size > 0, "Chunk size should be atleast 1")
        return stride(from: self.startIndex, to: self.endIndex, by: size).map {
            Array(self[$0..<Swift.min($0.advanced(by: size), self.endIndex)])
        }
    }
}

extension ContiguousBytes {
    func objects<T>() -> [T] {
        withUnsafeBytes {
            .init($0.bindMemory(to: T.self))
        }
    }
    var triangles: [(Int32, Int32, Int32)] { objects() }
}

extension Array {
    var data: Data {
        withUnsafeBytes {
            .init($0)
        }
    }
}

extension SCNGeometryElement {
    var triangles: [(Int32, Int32, Int32)] {
        self.data.objects()
    }
}

extension SCNGeometryElement {
    var faces: [[Int]] {
        func arrayFromData<Integer: BinaryInteger>(_ type: Integer.Type, startIndex: Int = 0, size: Int) -> [Int] {
            assert(self.bytesPerIndex == MemoryLayout<Integer>.size)
            return [Integer](unsafeUninitializedCapacity: size) { arrayBuffer, capacity in
                self.data.copyBytes(to: arrayBuffer, from: startIndex..<startIndex + size * MemoryLayout<Integer>.size)
                capacity = size
            }
                .map { Int($0) }
        }

        func integersFromData(startIndex: Int = 0, size: Int = self.primitiveCount) -> [Int] {
            switch self.bytesPerIndex {
            case 1:
                return arrayFromData(UInt8.self, startIndex: startIndex, size: size)
            case 2:
                return arrayFromData(UInt16.self, startIndex: startIndex, size: size)
            case 4:
                return arrayFromData(UInt32.self, startIndex: startIndex, size: size)
            case 8:
                return arrayFromData(UInt64.self, startIndex: startIndex, size: size)
            default:
                return []
            }
        }

        func vertices(primitiveSize: Int) -> [[Int]] {
            integersFromData(size: self.primitiveCount * primitiveSize)
                .chunked(into: primitiveSize)
        }

        switch self.primitiveType {
        case .point:
            return vertices(primitiveSize: 1)
        case .line:
            return vertices(primitiveSize: 2)
        case .triangles:
            return vertices(primitiveSize: 3)
        case .triangleStrip:
            let vertices = integersFromData(size: self.primitiveCount + 2)
            return (0..<vertices.count - 2).map { index in
                Array(vertices[(index..<(index + 3))])
            }
        case .polygon:
            let polygonSizes = integersFromData()
            let allPolygonsVertices = integersFromData(startIndex: polygonSizes.count * self.bytesPerIndex, size: polygonSizes.reduce(into: 0, +=))
            var current = 0
            return polygonSizes.map { count in
                defer {
                    current += count
                }
                return Array(allPolygonsVertices[current..<current + count])
            }
        @unknown default:
            return []
        }
    }
}

extension  SCNGeometry {
    
    /**
     Get the vertices (3d points coordinates) of the geometry.
     
     - returns: An array of SCNVector3 containing the vertices of the geometry.
     */
    func vertices() -> [SCNVector3] {
        guard let source = self.sources(for: .vertex).first else { return [] }
        
        let stride = source.dataStride / source.bytesPerComponent
        let offset = source.dataOffset / source.bytesPerComponent
        
        return source.data.withUnsafeBytes { dataBytes in
            let buffer: UnsafePointer<Float> = dataBytes.baseAddress!.assumingMemoryBound(to: Float.self)
            var result: [SCNVector3] = []
            for i in 0 ..< source.vectorCount {
                let start = i * stride + offset
                let x = buffer[start]
                let y = buffer[start + 1]
                let z = buffer[start + 2]
                result.append(SCNVector3(x, y, z))
            }
            return result
        }
    }
    
    func normals() -> [SCNVector3] {
        guard let source = self.sources(for: .normal).first else { return [] }
        
        let stride = source.dataStride / source.bytesPerComponent
        let offset = source.dataOffset / source.bytesPerComponent
        
        return source.data.withUnsafeBytes { dataBytes in
            let buffer: UnsafePointer<Float> = dataBytes.baseAddress!.assumingMemoryBound(to: Float.self)
            var result: [SCNVector3] = []
            for i in 0 ..< source.vectorCount {
                let start = i * stride + offset
                let x = buffer[start]
                let y = buffer[start + 1]
                let z = buffer[start + 2]
                result.append(SCNVector3(x, y, z))
            }
            return result
        }
    }
    
    func colors() -> [SCNVector3] {
        guard let source = self.sources(for: .color).first else { return [] }
        
        let stride = source.dataStride / source.bytesPerComponent
        let offset = source.dataOffset / source.bytesPerComponent
        
        return source.data.withUnsafeBytes { dataBytes in
            let buffer: UnsafePointer<Float> = dataBytes.baseAddress!.assumingMemoryBound(to: Float.self)
            var result: [SCNVector3] = []
            for i in 0 ..< source.vectorCount {
                let start = i * stride + offset
                let x = buffer[start]
                let y = buffer[start + 1]
                let z = buffer[start + 2]
                result.append(SCNVector3(x, y, z))
            }
            return result
        }
    }
    
    func elements() -> [Int32]? {
        guard let element = self.elements.first else { return nil }
        
        let faces = element.data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> [Int32] in
            guard let boundPtr = ptr.baseAddress?.assumingMemoryBound(to: Int32.self) else { return [] }
            let buffer = UnsafeBufferPointer(start: boundPtr, count: element.data.count / 4)
            return Array<Int32>(buffer)
        }
        return faces
    }
    
}
