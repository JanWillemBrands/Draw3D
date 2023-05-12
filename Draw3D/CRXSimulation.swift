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
    
    var base: SCNNode {
        return crxScene.rootNode.childNode(withName: "base", recursively: true)!
    }
    
    var shoulder: SCNNode {
        let node = crxScene.rootNode.childNode(withName: "shoulder", recursively: true)!
        node.enumerateHierarchy { child, stop in
            if let materials = child.geometry?.materials {
                for m in materials {
                    m.diffuse.contents = UIColor.red
                }
            }
        }
        node.constraints = [zRotationConstraint]
        return node
    }
    
    var elbow: SCNNode {
        let node = crxScene.rootNode.childNode(withName: "elbow", recursively: true)!
        node.enumerateHierarchy { child, stop in
            if let materials = child.geometry?.materials {
                for m in materials {
                    m.diffuse.contents = UIColor.red
                }
            }
        }
        node.constraints = [yRotationConstraint]
        return node
    }
    
    var wrist1: SCNNode {
        let node = crxScene.rootNode.childNode(withName: "wrist1", recursively: true)!
        node.enumerateHierarchy { child, stop in
            if let materials = child.geometry?.materials {
                for m in materials {
                    m.diffuse.contents = UIColor.red
                }
            }
        }
        node.constraints = [yRotationConstraint]
        return node
    }
    
    var wrist2: SCNNode {
        let node = crxScene.rootNode.childNode(withName: "wrist2", recursively: true)!
        node.enumerateHierarchy { child, stop in
            if let materials = child.geometry?.materials {
                for m in materials {
                    m.diffuse.contents = UIColor.red
                }
            }
        }
        node.constraints = [xRotationConstraint]
        return node
    }
    
    var wrist3: SCNNode {
        let node = crxScene.rootNode.childNode(withName: "wrist3", recursively: true)!
        node.enumerateHierarchy { child, stop in
            if let materials = child.geometry?.materials {
                for m in materials {
                    m.diffuse.contents = UIColor.red
                }
            }
        }
        node.constraints = [yRotationConstraint]
        return node
    }
    
    var flange: SCNNode {
        let node = crxScene.rootNode.childNode(withName: "flange", recursively: true)!
        node.enumerateHierarchy { child, stop in
            if let materials = child.geometry?.materials {
                for m in materials {
                    m.diffuse.contents = UIColor.red
                }
            }
        }
        node.constraints = [xRotationConstraint]
        return node
    }
    
    let xRotationConstraint = SCNTransformConstraint(inWorldSpace: false) { node, matrix in
//        if node.presentation.simdRotation.sum() > 0 {
            node.eulerAngles.y = 0
            node.eulerAngles.z = 0
//        }
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
                                                                          
//        constraint = SCNIKConstraint.inverseKinematicsConstraint(chainRootNode: base)
////        aimConstraint.setMaxAllowedRotationAngle(90, forJoint: nozzleNode)
//        flange.constraints = [constraint]
    
    var body: some View {
        VStack {
            Button("move") {
                flange.simdRotation = flange.simdRotation + SIMD4(0.01, 0.01, 0.01, 0.5)
                flange.simdPosition = SIMD3(-0.1, -0.1, -0.1)
            }
            SceneView(scene: crxScene, options: [.autoenablesDefaultLighting, .allowsCameraControl])
                .frame(width: 500, height: 500)
                .border(.black)
        }
        .onAppear {
            let constraint = SCNIKConstraint.inverseKinematicsConstraint(chainRootNode: shoulder)
            flange.constraints = [constraint]
        }
    }
}

struct CRXSimulation_Previews: PreviewProvider {
    static var previews: some View {
        CRXSimulation()
    }
}
