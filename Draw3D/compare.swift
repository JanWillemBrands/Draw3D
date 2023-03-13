//
//  compare.swift
//  Draw3D
//
//  Created by Johannes Brands on 02/03/2023.
//

import SwiftUI
import SceneKit

struct compare: View {
    
    let original = SCNScene(named: "SceneKit Asset Catalog.scnassets/bronze.usdz")!
    
    var model: PaintableModel { PaintableModel(from: original) }
    
    var body: some View {
            HStack {
                SceneView(scene: original, options: [.autoenablesDefaultLighting,.allowsCameraControl])
                    .frame(width: 500, height: 500)
                    .border(.red)
                    .padding()
                SceneView(scene: model.paintScene, options: [.autoenablesDefaultLighting,.allowsCameraControl])
                    .frame(width: 500, height: 500)
                    .border(.green)
                    .padding()
            }
    }
}

struct compare_Previews: PreviewProvider {
    static var previews: some View {
        compare()
    }
}
