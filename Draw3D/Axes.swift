//
//  Axes.swift
//  Draw3D
//
//  Created by Johannes Brands on 08/11/2022.
//

import SceneKit

var axes: SCNNode {
    let node = SCNNode()
    node.name = "axes"
    
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

func addAxes(to scene: SCNScene) {
    scene.rootNode.addChildNode(axes)
}

func removeAxes(from scene: SCNScene) {
    scene.rootNode.childNode(withName: "axes", recursively: true)?.removeFromParentNode()
}
