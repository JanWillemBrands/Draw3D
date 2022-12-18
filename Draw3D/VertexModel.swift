//
//  VertexModel.swift
//  Draw3D
//
//  Created by Johannes Brands on 04/11/2022.
//

import SceneKit

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

extension ContiguousBytes {
    func objects<T>() -> [T] {
        withUnsafeBytes {
            .init($0.bindMemory(to: T.self))
        }
    }
//    var triangles: [(Int32, Int32, Int32)] { objects() }
//    var bytes: [UInt8] { objects() }
}

extension Array {
    var data: Data {
        withUnsafeBytes {
            .init($0)
        }
    }
}

extension SCNGeometryElement {
    var hexes: [(Int32, Int32, Int32, Int32, Int32, Int32)] {
        self.data.objects()
    }
    var triangles: [(Int32, Int32, Int32)] {
        self.data.objects()
    }
    var bytes: [UInt8] {
        self.data.objects()
    }
}

//extension SCNGeometryElement {
//    var faces: [[Int]] {
//        func arrayFromData<Integer: BinaryInteger>(_ type: Integer.Type, startIndex: Int = 0, size: Int) -> [Int] {
//            assert(self.bytesPerIndex == MemoryLayout<Integer>.size)
//            return [Integer](unsafeUninitializedCapacity: size) { arrayBuffer, capacity in
//                self.data.copyBytes(to: arrayBuffer, from: startIndex..<startIndex + size * MemoryLayout<Integer>.size)
//                capacity = size
//            }
//                .map { Int($0) }
//        }
//
//        func integersFromData(startIndex: Int = 0, size: Int = self.primitiveCount) -> [Int] {
//            switch self.bytesPerIndex {
//            case 1:
//                return arrayFromData(UInt8.self, startIndex: startIndex, size: size)
//            case 2:
//                return arrayFromData(UInt16.self, startIndex: startIndex, size: size)
//            case 4:
//                return arrayFromData(UInt32.self, startIndex: startIndex, size: size)
//            case 8:
//                return arrayFromData(UInt64.self, startIndex: startIndex, size: size)
//            default:
//                return []
//            }
//        }
//
//        func vertices(primitiveSize: Int) -> [[Int]] {
//            integersFromData(size: self.primitiveCount * primitiveSize)
//                .chunked(into: primitiveSize)
//        }
//
//        switch self.primitiveType {
//        case .point:
//            return vertices(primitiveSize: 1)
//        case .line:
//            return vertices(primitiveSize: 2)
//        case .triangles:
//            return vertices(primitiveSize: 3)
//        case .triangleStrip:
//            let vertices = integersFromData(size: self.primitiveCount + 2)
//            return (0..<vertices.count - 2).map { index in
//                Array(vertices[(index..<(index + 3))])
//            }
//        case .polygon:
//            let polygonSizes = integersFromData()
//            let allPolygonsVertices = integersFromData(startIndex: polygonSizes.count * self.bytesPerIndex, size: polygonSizes.reduce(into: 0, +=))
//            var current = 0
//            return polygonSizes.map { count in
//                defer {
//                    current += count
//                }
//                return Array(allPolygonsVertices[current..<current + count])
//            }
//        @unknown default:
//            return []
//        }
//    }
//}

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
                let length = sqrt(x*x + y*y + z*z)
                result.append(SCNVector3(x / length, y / length, z / length))
            }
            return result
        }
    }
    
    func colors() -> [SCNVector4] {
        guard let source = self.sources(for: .color).first else { return [] }
        
        let stride = source.dataStride / source.bytesPerComponent
        let offset = source.dataOffset / source.bytesPerComponent
        
        return source.data.withUnsafeBytes { dataBytes in
            let buffer: UnsafePointer<Float> = dataBytes.baseAddress!.assumingMemoryBound(to: Float.self)
            var result: [SCNVector4] = []
            for i in 0 ..< source.vectorCount {
                let start = i * stride + offset
                let x = buffer[start]
                let y = buffer[start + 1]
                let z = buffer[start + 2]
                let w = buffer[start + 3]
                result.append(SCNVector4(x, y, z, w))
            }
            return result
        }
    }
    
    /// https://stackoverflow.com/questions/69480030/extract-faces-information-from-scngeometry-in-scenekit
    /// https://stackoverflow.com/questions/48428988/scenekit-how-to-identify-and-access-faces-from-3d-model
    /// https://stackoverflow.com/questions/17250501/extracting-vertices-from-scenekit/66748865#66748865
    /// For .uscz sources the faces may be interleaved vertex and normal data.  For a triangle format it could be:
    /// f0: v0, n0, v1, n1, v2, n2
    /// f1: v2, n2, v3, n3, v4, n4
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
