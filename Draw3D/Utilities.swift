//
//  Utilities.swift
//  Draw3D
//
//  Created by Johannes Brands on 27/10/2022.
//

import SceneKit

func dump(node: SCNNode) {
    node.enumerateHierarchy { child, stop in
        print(child.debugDescription)
    }
}

//public var vertices: [SCNVector3] = []
//public var normals: [SCNVector3] = []
//public var colors: [SCNVector4] = []
//public var triangles: [(Int32, Int32, Int32)] = []
//
//public var hexes: [(Int32, Int32, Int32, Int32, Int32, Int32)] = []
//
//func textureCoordinateFromScreenCoordinate(with renderer: SCNSceneRenderer?, of point: CGPoint) -> CGPoint? {
//
//    let hitOptions = [SCNHitTestOption.searchMode: SCNHitTestSearchMode.closest.rawValue]
//
//    guard let hit = renderer?.hitTest(point, options: hitOptions).first else { return nil }
//
//    if let geometry = hit.node.geometry {
//        // get the sources from the loaded .USDZ file as SCNGeometrySource.
//        let vertexSources = geometry.sources(for: .vertex)              // there is always exactly one vertext source.
//        let normalSources = geometry.sources(for: .normal)              // there may be one or zero normal source.
//        let textureSources = geometry.sources(for: .texcoord)           // there may be one or zero normal source.
//        // let colorSources = geometry.sources(for: .color)             // there may be one or zero color source.
//        // let elements = geometry.elements                             // there is always at least one element.
//
//        // get the sources from the loaded .USDZ file as array of SCNVector3.
//        vertices = geometry.vertices()
//        normals = geometry.normals()
//        if colors.isEmpty {
//            colors = [SCNVector4](repeating: SCNVector4(0, 0, 0, 0), count: vertices.count)
//        }
//
//        // CAUTION: MAJOR HACK to deal with USDZ model that contains <SCNGeometryElement: 0x60000382b800 | 25000 x triangle, 2 channels, int indices>
//        // Reading a .usdz file from SCNScene init will yield INTERLEAVED geometry elements.
//        // Furtunately reading a .usdz file from MDLAsset init will not be interleaved.
//        // MDLAsset can be easily converted into SCNScene.
//
//        triangles = geometry.elements.first!.triangles
//        let hitTriangle = triangles[hit.faceIndex]
//        // Color the vertices of the hit triangle red.
//        colors[Int(hitTriangle.0)] = SCNVector4(1, 0, 0, 1)
//        colors[Int(hitTriangle.1)] = SCNVector4(1, 0, 0, 1)
//        colors[Int(hitTriangle.2)] = SCNVector4(1, 0, 0, 1)
//
//
////        print(geometry.elements.first!.bytes[0...63])
////        print(geometry.elements.first!.triangles[0...15])
////        print(geometry.elements.first!.hexes[0...7])
////
////        print("mirror ", String(reflecting: geometry.elements.first))
////
////
////        hexes = geometry.elements.first!.hexes
////        let hitHex = hexes[hit.faceIndex]
////        print("hitHex", hitHex)
////
////        // Color the vertices of the hit triangle red.
////        colors[Int(hitHex.0)] = SCNVector4(1, 0, 0, 1)
////        colors[Int(hitHex.2)] = SCNVector4(1, 0, 0, 1)
////        colors[Int(hitHex.4)] = SCNVector4(1, 0, 0, 1)
//
////        // Color the other hex vertices green.
////        colors[Int(hitHex.1)] = SCNVector4(0, 1, 0, 1)
////        colors[Int(hitHex.3)] = SCNVector4(0, 1, 0, 1)
////        colors[Int(hitHex.5)] = SCNVector4(0, 1, 0, 1)
//
//        // Maybe the vertices are interleaved with the normals?
////        print("n1", normals[Int(hitHex.1)])
////        print("n2", normals[Int(hitHex.3)])
////        print("n3", normals[Int(hitHex.5)])
//
////        let newVertexSource = SCNGeometrySource(vertices: vertices)
////        let newNormalSource = SCNGeometrySource(normals: normals)
//        let newColorSource = SCNGeometrySource(colors: colors)
////        let newColorSource = SCNGeometrySource(data: colors, semantic: .color)
//
//        let newGeometry = SCNGeometry(
//            sources: vertexSources + normalSources + textureSources + [newColorSource],
//            elements: geometry.elements
//        )
////        hit.node.geometry = newGeometry
//        renderer?.scene?.rootNode.childNodes.first?.geometry = newGeometry
////        renderer?.scene?.rootNode.geometry = newGeometry
//    }
//
//    return hit.textureCoordinates(withMappingChannel: 0)
//}
//
//func apply(_ hits: [CGPoint]?, to texture: UIImage?) -> UIImage? {
//    guard let hits else { return nil }
//
//    var img: UIImage?
//    if let texture {
//        let size = texture.size
//        let area = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//        UIGraphicsBeginImageContext(size)
//
//        texture.draw(in: area)
//
//        let ctx = UIGraphicsGetCurrentContext()!
//
//        for hit in hits {
//            //                    ctx.saveGState()
//            let hitPoint = CGPoint(x: hit.x * size.width, y: hit.y * size.height)
//            logger.debug("hitPoint at: \(hitPoint.debugDescription)")
//            let rect = CGRect(x: hitPoint.x-10, y: hitPoint.y-10, width: 20, height: 20)
//            ctx.setFillColor(UIColor.tintColor.cgColor)
//            ctx.fillEllipse(in: rect)
//            //                    ctx.restoreGState()
//        }
//
//        img = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//    }
//    return img
//}
//
//func blend(texture: UIImage?, with image: UIImage?) -> UIImage? {
//    var img: UIImage?
//    if let texture {
//        let size = texture.size
//        let area = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//        UIGraphicsBeginImageContext(size)
//
//        texture.draw(in: area)
//
//        image?.draw(in: area, blendMode: .normal, alpha: 1)
//
//        //        let ctx = UIGraphicsGetCurrentContext()!
//        //        ctx.saveGState()
//        //        let rect = CGRect(x: 0, y: 0, width: 512, height: 512)
//        //        ctx.setFillColor(UIColor.tintColor.cgColor)
//        //        ctx.fillEllipse(in: rect)
//        //        ctx.restoreGState()
//
//        img = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//    }
//    return img
//}
//
//func UItoCI() {
//    let ui = UIImage(named: "apple")
//    if let cg = ui?.cgImage {
//        let ci = CIImage(cgImage: cg)
//    }
//}
