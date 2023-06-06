//
//  CRXSimulation.swift
//  Draw3D
//
//  Created by Johannes Brands on 10/05/2023.
//

import SwiftUI
import SceneKit

struct CRXSimulation: View {
    
    //    let crxScene = SCNScene(named: "SceneKit Asset Catalog.scnassets/3D_CRX-10iA_v02.scn")!
    let crxScene = SCNScene(named: "SceneKit Asset Catalog.scnassets/stupid.scn")!
    
    let base:       SCNNode
    let shoulder:   SCNNode
    let elbow:      SCNNode
    let wrist1:     SCNNode
    let wrist2:     SCNNode
    let wrist3:     SCNNode
    let flange:     SCNNode
    
    let ikConstraint: SCNIKConstraint
    
    @State var angle = ""
    
    init() {
        base = crxScene.rootNode.childNode(withName: "base", recursively: true)!
        ikConstraint = .inverseKinematicsConstraint(chainRootNode: base)
        
        shoulder = crxScene.rootNode.childNode(withName: "shoulder", recursively: true)!
        let shoulderShift = shoulder.simdPosition / 2
        shoulder.simdPivot = simd_float4x4(columns: (SIMD4(1, 0, 0, 0),
                                                     SIMD4(0, 1, 0, 0),
                                                     SIMD4(0, 0, 1, 0),
                                                     SIMD4(-shoulderShift, 1)))
        shoulder.simdPosition -= shoulderShift
//        shoulder.constraints = [yRotationConstraint]
        
        
        elbow = crxScene.rootNode.childNode(withName: "elbow", recursively: true)!
        let elbowShift = elbow.simdPosition / 2
        elbow.simdPivot = simd_float4x4(columns: (SIMD4(1, 0, 0, 0),
                                                  SIMD4(0, 1, 0, 0),
                                                  SIMD4(0, 0, 1, 0),
                                                  SIMD4(-elbowShift, 1)))
        elbow.simdPosition -= elbowShift
//        elbow.constraints = [yRotationConstraint]
        
        
        wrist1 = crxScene.rootNode.childNode(withName: "wrist1", recursively: true)!
        let wrist1Shift = wrist1.simdPosition / 2
        wrist1.simdPivot = simd_float4x4(columns: (SIMD4(1, 0, 0, 0),
                                                   SIMD4(0, 1, 0, 0),
                                                   SIMD4(0, 0, 1, 0),
                                                   SIMD4(-wrist1Shift, 1)))
        wrist1.simdPosition -= wrist1Shift
//        wrist1.constraints = [yRotationConstraint]
        
        
        wrist2 = crxScene.rootNode.childNode(withName: "wrist2", recursively: true)!
        let wrist2Shift = wrist2.simdPosition / 2
        wrist2.simdPivot = simd_float4x4(columns: (SIMD4(1, 0, 0, 0),
                                                   SIMD4(0, 1, 0, 0),
                                                   SIMD4(0, 0, 1, 0),
                                                   SIMD4(-wrist2Shift, 1)))
        wrist2.simdPosition -= wrist2Shift
//        wrist2.constraints = [yRotationConstraint]
        
        
        wrist3 = crxScene.rootNode.childNode(withName: "wrist3", recursively: true)!
        let wrist3Shift = wrist3.simdPosition / 2
        wrist3.simdPivot = simd_float4x4(columns: (SIMD4(1, 0, 0, 0),
                                                   SIMD4(0, 1, 0, 0),
                                                   SIMD4(0, 0, 1, 0),
                                                   SIMD4(-wrist3Shift, 1)))
        wrist3.simdPosition -= wrist3Shift
//        wrist3.constraints = [yRotationConstraint]
        
        flange = crxScene.rootNode.childNode(withName: "flange", recursively: true)!
        let flangeShift = flange.simdPosition / 2
        flange.simdPivot = simd_float4x4(columns: (SIMD4(1, 0, 0, 0),
                                                   SIMD4(0, 1, 0, 0),
                                                   SIMD4(0, 0, 1, 0),
                                                   SIMD4(-flangeShift, 1)))
        flange.simdPosition -= flangeShift
//        flange.constraints = [ikConstraint]//, rotationConstraint]
        
        
        //        flange.enumerateHierarchy { child, stop in
        //            if let materials = child.geometry?.materials {
        //                for m in materials {
        //                    m.diffuse.contents = UIColor.red
        //                }
        //            }
        //        }
        
//        ikConstraint.targetPosition = flange.worldPosition
        
        angle = base.simdPosition.debugDescription
        
//        let shoulderJoint = SCNPhysicsHingeJoint(
//            body: shoulder.physicsBody!,
//            axis: SCNVector3(0, 1, 0),
//            anchor: shoulder.position)
//
//        crxScene.physicsWorld.addBehavior(shoulderJoint)
//
        let flangeJoint = SCNPhysicsHingeJoint(
            body: flange.physicsBody!,
            axis: SCNVector3(0, 1, 0),
            anchor: flange.position)

        crxScene.physicsWorld.addBehavior(flangeJoint)

    }
    
//    let xRotationConstraint = SCNTransformConstraint(inWorldSpace: false) { node, matrix in
//        node.eulerAngles.y = 0
//        node.eulerAngles.z = 0
//        return node.transform
//    }
//
//    let yRotationConstraint = SCNTransformConstraint(inWorldSpace: false) { node, matrix in
//        node.eulerAngles.x = 0
//        node.eulerAngles.z = 0
//        return node.transform
//    }
//
//    let zRotationConstraint = SCNTransformConstraint(inWorldSpace: false) { node, matrix in
//        node.eulerAngles.x = 0
//        node.eulerAngles.y = 0
//        return node.transform
//    }
//
//    let rotationConstraint = SCNTransformConstraint(inWorldSpace: false) { node, matrix in
//        node.eulerAngles.x = 0
//        node.eulerAngles.y = 0
//        node.eulerAngles.z = 0
//        return node.transform
//    }
    
    var body: some View {
        VStack {
            Text(angle)
            Button("move") {
                angle = base.simdPivot.debugDescription
                //            let tp = flange.simdWorldPosition + SIMD3(-1, -1, -1)
                let tp = SIMD3<Float>(0.1, 0.1, 0.1)
                let to = SIMD3<Float>(1, 1, 1)
//                ikConstraint.targetPosition = SCNVector3(tp)
                flange.simdPosition = tp
                flange.eulerAngles = SCNVector3(to)
                //                flange.simdRotation = flange.simdRotation + SIMD4(0.1, 0.1, 0.1, 0.1)
                //                flange.simdPosition = flange.simdPosition + SIMD3(0.1, 0.1, 0.1)
            }
            SceneView(scene: crxScene, options: [.autoenablesDefaultLighting, .allowsCameraControl])
                .frame(width: 800, height: 800)
                .border(.black)
        }
    }
}

struct CRXSimulation_Previews: PreviewProvider {
    static var previews: some View {
        CRXSimulation()
    }
}
