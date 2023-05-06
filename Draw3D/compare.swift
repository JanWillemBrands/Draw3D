//
//  compare.swift
//  Draw3D
//
//  Created by Johannes Brands on 02/03/2023.
//

import SwiftUI
import SceneKit

struct compare: View {
    
    let original = SCNScene(named: "SceneKit Asset Catalog.scnassets/cup.usdz")!
    
    var copy: SCNScene {
        let c = SCNScene()
        var g0 = SCNGeometry()
        var g1 = SCNGeometry()
        var g2 = SCNGeometry()
        let m = SCNMaterial()
        m.diffuse.contents = UIColor.orange

        var vertexSources: [SCNGeometrySource] = []
        var normalSources: [SCNGeometrySource] = []
        var colorSources:  [SCNGeometrySource] = []
        var texcoordSources:  [SCNGeometrySource] = []

        // find the first node with a geometry
        original.rootNode.enumerateHierarchy { child, stop in
            if let geometry = child.geometry {
                stop.pointee = true
                
                vertexSources = geometry.sources(for: .vertex)
                normalSources = geometry.sources(for: .normal)
                colorSources = geometry.sources(for: .color)
                texcoordSources = geometry.sources(for: .texcoord)

                g0 = geometry.copy() as! SCNGeometry
                g1 = SCNGeometry(sources: geometry.sources, elements: geometry.elements)
                g2 = SCNGeometry(
                    sources: vertexSources + normalSources + colorSources + texcoordSources,
                    elements: geometry.elements
                )

                g0 = geometry.copy() as! SCNGeometry
                                
//                g.materials = [m]
            }
        }
        let n = SCNNode(geometry: g2)
        c.rootNode.addChildNode(n)
        return c
    }
    
    var model = PaintableModel()
    
    var body: some View {
        VStack {
            Text((copy.rootNode.childNodes.first?.geometry?.sources.debugDescription)!)
            HStack {
                SceneView(scene: original, options: [.autoenablesDefaultLighting, .allowsCameraControl])
                    .frame(width: 500, height: 500)
                    .border(.black)
                    .padding()
                //            SceneView(scene: model.paintScene, options: [.autoenablesDefaultLighting, .allowsCameraControl])
                SceneView(scene: copy, options: [.autoenablesDefaultLighting, .allowsCameraControl])
                    .frame(width: 500, height: 500)
                    .border(.black)
                    .padding()
            }
        }
    }
}

struct compare_Previews: PreviewProvider {
    static var previews: some View {
        compare()
    }
}
