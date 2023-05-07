//
//  compare.swift
//  Draw3D
//
//  Created by Johannes Brands on 02/03/2023.
//

import SwiftUI
import SceneKit

struct CompareGeometries: View {
    
    let original = SCNScene(named: "SceneKit Asset Catalog.scnassets/toy_robot_vintage.usdz")!
    @State var copy = SCNScene()
    @State var reconstructed = SCNScene()

    func makeCopy() -> SCNScene {
        let s = SCNScene()
        var g = SCNGeometry()
        
        original.rootNode.enumerateHierarchy { child, stop in
            if let geometry = child.geometry {
                stop.pointee = true
                g = geometry.copy() as! SCNGeometry
            }
        }
        let n = SCNNode(geometry: g)
        s.rootNode.addChildNode(n)
        return s
    }
    
    func makeReconstructed() -> SCNScene {
        let s = SCNScene()
        var n = SCNNode()
        var g = SCNGeometry()
        
        original.rootNode.enumerateHierarchy { child, stop in
            if let geometry = child.geometry {
                stop.pointee = true
                n = child.clone()
//                g = geometry.copy() as! SCNGeometry
//                g = SCNGeometry(sources: geometry.sources, elements: geometry.elements)
//                g.materials = []
                n.geometry = SCNGeometry(sources: geometry.sources, elements: geometry.elements)
                n.geometry?.materials = []
                //                g = geometry.copy() as! SCNGeometry
                //                g = SCNGeometry(sources: geometry.sources, elements: geometry.elements)
                //                g.materials = geometry.materials
                //                g = geometry.copy() as! SCNGeometry
                //                g = SCNGeometry(sources: geometry.sources, elements: geometry.elements)
                //                g.materials = geometry.materials
                s.rootNode.addChildNode(n)
            }
        }
        return s
    }
    
    var body: some View {
        HStack {
            SceneView(scene: original, options: [.autoenablesDefaultLighting])
                .frame(width: 500, height: 500)
                .border(.black)
            SceneView(scene: copy, options: [.autoenablesDefaultLighting])
                .frame(width: 500, height: 500)
                .border(.black)
            SceneView(scene: reconstructed, options: [.autoenablesDefaultLighting])
                .frame(width: 500, height: 500)
                .border(.black)
        }
        .onAppear {
            copy = makeCopy()
            reconstructed = makeReconstructed()
        }
    }
}

struct CompareGeometries_Previews: PreviewProvider {
    static var previews: some View {
        CompareGeometries()
    }
}
