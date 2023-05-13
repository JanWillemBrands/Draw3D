//
//  CRXSimulation.swift
//  Draw3D
//
//  Created by Johannes Brands on 10/05/2023.
//

import SwiftUI
import SceneKit

struct CRXSimulation: View {
    
    let crxScene = SCNScene(named: "SceneKit Asset Catalog.scnassets/3D_CRX-10iA_v02.scn")!
    
    let base: SCNNode
    let shoulder: SCNNode
    let elbow: SCNNode
    let wrist1: SCNNode
    let wrist2: SCNNode
    let wrist3: SCNNode
    let flange: SCNNode
    
    let ikConstraint: SCNIKConstraint
    
    @State var angle = ""
    
    init() {
        base = crxScene.rootNode.childNode(withName: "base", recursively: true)!

        shoulder = crxScene.rootNode.childNode(withName: "shoulder", recursively: true)!
        shoulder.constraints = [xRotationConstraint]

        elbow = crxScene.rootNode.childNode(withName: "elbow", recursively: true)!
        elbow.constraints = [xRotationConstraint]

        wrist1 = crxScene.rootNode.childNode(withName: "wrist1", recursively: true)!
        wrist1.constraints = [xRotationConstraint]

        wrist2 = crxScene.rootNode.childNode(withName: "wrist2", recursively: true)!
        wrist2.simdPivot = make
//        wrist2.constraints = [xRotationConstraint]

        wrist3 = crxScene.rootNode.childNode(withName: "wrist3", recursively: true)!
        wrist3.constraints = [xRotationConstraint]

        flange = crxScene.rootNode.childNode(withName: "flange", recursively: true)!
        
        angle = wrist2.simdPosition.description

        flange.enumerateHierarchy { child, stop in
            if let materials = child.geometry?.materials {
                for m in materials {
                    m.diffuse.contents = UIColor.red
                }
            }
        }
                
        ikConstraint = SCNIKConstraint.inverseKinematicsConstraint(chainRootNode: base)
//        ikConstraint.targetPosition = flange.worldPosition
        flange.constraints = [ikConstraint, xRotationConstraint]

    }
    
    let xRotationConstraint = SCNTransformConstraint(inWorldSpace: false) { node, matrix in
        node.eulerAngles.y = 0
        node.eulerAngles.z = 0
        return node.transform
    }
                                                                          
    let yRotationConstraint = SCNTransformConstraint(inWorldSpace: false) { node, matrix in
        node.eulerAngles.x = 0
        node.eulerAngles.z = 0
        return node.transform
    }
    
    let zRotationConstraint = SCNTransformConstraint(inWorldSpace: false) { node, matrix in
        node.eulerAngles.x = 0
        node.eulerAngles.y = 0
        return node.transform
    }
    
    var body: some View {
        VStack {
            Text(angle)
            Button("move") {
                let tp = flange.simdWorldPosition + SIMD3(0.1, 0.1, 0.1)
                ikConstraint.targetPosition = SCNVector3(tp)
//                flange.simdRotation = flange.simdRotation + SIMD4(0.1, 0.1, 0.1, 0.1)
//                flange.simdPosition = flange.simdPosition + SIMD3(0.1, 0.1, 0.1)
            }
            SceneView(scene: crxScene, options: [.autoenablesDefaultLighting, .allowsCameraControl])
                .frame(width: 500, height: 500)
                .border(.black)
        }
    }
}

struct CRXSimulation_Previews: PreviewProvider {
    static var previews: some View {
        CRXSimulation()
    }
}
