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
        child.geometry?.firstMaterial?.emission.contents = UIImage(named: "ball")
    }
}

func emitWhite(from node: SCNNode?) {
    node?.enumerateHierarchy { child, stop in
        child.geometry?.firstMaterial?.emission.contents = UIColor.white
    }
}

func emitClear(from node: SCNNode?) {
    node?.enumerateHierarchy { child, stop in
        child.geometry?.firstMaterial?.emission.contents = UIColor.clear
    }
}

func mainNode(in scene: SCNScene?) -> SCNNode? {
    let node = scene?.rootNode.childNode(withName: "g0", recursively: true)
    logger.debug("mainNode: \(node.debugDescription)")
    return node
}

var axesNode: SCNNode {
    let node = SCNNode()
    
    let shaftRadius = 0.003
    let tipLength = 10 * shaftRadius
    let tipRadius = 3 * shaftRadius
    let shaftLength = 0.3 - tipLength
    let shaftShift = Float(shaftLength / 2)
    let tipShift = Float(shaftLength + tipLength / 2)
    
    let xGeometry = SCNCylinder(radius: shaftRadius, height: shaftLength)
    xGeometry.firstMaterial?.diffuse.contents = UIColor.red
    let x = SCNNode(geometry: xGeometry)
    x.eulerAngles = SCNVector3(x: 0, y: 0, z: .pi/2)
    x.position = SCNVector3(x: shaftShift, y: 0, z: 0)
    node.addChildNode(x)
    
    let xTip = SCNCone(topRadius: 0, bottomRadius: tipRadius, height: tipLength)
    xTip.firstMaterial?.diffuse.contents = UIColor.red
    let xT = SCNNode(geometry: xTip)
    xT.eulerAngles = SCNVector3(x: 0, y: 0, z: -.pi/2)
    xT.position = SCNVector3(x: tipShift, y: 0, z: 0)
    node.addChildNode(xT)

    let yGeometry = SCNCylinder(radius: shaftRadius, height: shaftLength)
    yGeometry.firstMaterial?.diffuse.contents = UIColor.green
    let y = SCNNode(geometry: yGeometry)
    y.eulerAngles = SCNVector3(x: 0, y: 0, z: 0)
    y.position = SCNVector3(x: 0, y: shaftShift, z: 0)
    node.addChildNode(y)
    
    let yTip = SCNCone(topRadius: 0, bottomRadius: tipRadius, height: tipLength)
    yTip.firstMaterial?.diffuse.contents = UIColor.green
    let yT = SCNNode(geometry: yTip)
    yT.eulerAngles = SCNVector3(x: 0, y: 0, z: 0)
    yT.position = SCNVector3(x: 0, y: tipShift, z: 0)
    node.addChildNode(yT)

    let zGeometry = SCNCylinder(radius: shaftRadius, height: shaftLength)
    zGeometry.firstMaterial?.diffuse.contents = UIColor.blue
    let z = SCNNode(geometry: zGeometry)
    z.eulerAngles = SCNVector3(x: .pi/2, y: 0, z: 0)
    z.position = SCNVector3(x: 0, y: 0, z: shaftShift)
    node.addChildNode(z)
    
    let zTip = SCNCone(topRadius: 0, bottomRadius: tipRadius, height: tipLength)
    zTip.firstMaterial?.diffuse.contents = UIColor.blue
    let zT = SCNNode(geometry: zTip)
    zT.eulerAngles = SCNVector3(x: .pi/2, y: 0, z: 0)
    zT.position = SCNVector3(x: 0, y: 0, z: tipShift)
    node.addChildNode(zT)

    return node
}

func addAxes(to scene: SCNScene?) -> SCNNode? {
    let a = axesNode
    scene?.rootNode.addChildNode(a)
    return a
}

func removeAxes(node: SCNNode?) {
    node?.removeFromParentNode()
}

struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
#if os(iOS)
        configuration.icon
#else
        Label(configuration.icon, image: configuration.icon)
#endif
    }
}

func findHits(in scene: SCNScene?) -> [CGPoint] {
    // Find hits along the z-axis
    let pointA = SCNVector3(x: 0, y: 0, z: +1)
    let pointB = SCNVector3(x: 0, y: 0, z: -1)
    
    var textureHits: [CGPoint] = []
    
    if let hits = scene?.rootNode.hitTestWithSegment(from: pointA, to: pointB, options: [:]) {
        for hit in hits {
            let textureHit = hit.textureCoordinates(withMappingChannel: 0)
            textureHits.append(textureHit)
            logger.debug("texture hit at: \(textureHit.debugDescription)")
        }
        return textureHits
    }
    return []
}

func apply(_ hits: [CGPoint], to texture: UIImage?) -> UIImage? {
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

func updateTexture(of scene: inout SCNScene?, and texture: UIImage?, with image: UIImage?) -> UIImage? {
    var img: UIImage?
    if let texture {
        let size = texture.size
        let area = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(size)
        
        texture.draw(in: area)
        
        image?.draw(in: area, blendMode: .normal, alpha: 1)
        
        let ctx = UIGraphicsGetCurrentContext()!
//        ctx.saveGState()
        let rect = CGRect(x: 0, y: 0, width: 512, height: 512)
        ctx.setFillColor(UIColor.tintColor.cgColor)
        ctx.fillEllipse(in: rect)
//        ctx.restoreGState()

        img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
//    let newScene = scene?.copy() as? SCNScene
//    newScene?.rootNode.geometry?.firstMaterial?.diffuse.contents = newTexture
//    scene?.rootNode.geometry?.firstMaterial?.diffuse.contents = newTexture
    return img
}

//func UItoCI() {
//    let ui = UIImage(named: "apple")
//    if let cg = ui?.cgImage {
//        let ci = CIImage(cgImage: cg)
//    }
//}
