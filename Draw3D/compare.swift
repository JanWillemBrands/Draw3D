//
//  compare.swift
//  Draw3D
//
//  Created by Johannes Brands on 02/03/2023.
//

import SwiftUI
import SceneKit
import SceneKit.ModelIO

struct compare: View {
    
    let original = SCNScene(named: "SceneKit Asset Catalog.scnassets/bronze.usdz")!
    
    var modified: SCNScene
    
    var model: PaintableModel
    
    @State var before = ""
    @State var after = ""

    init() {
        model = PaintableModel(from: original)
        modified = model.paintableScene(from: original)
    }
    
    func loadGeometry() {

//        model = PaintableModel(from: original)
//        modified = model!.paintableScene(from: original)

    }
    
    var body: some View {
        VStack {
            HStack {
                Button("load") { loadGeometry() }
                Button("copy") { }
                Button("color") { }
                Text(before)
                Text(after)
            }
            .padding()
            HStack {
                SceneView(scene: original, options: [.autoenablesDefaultLighting,.allowsCameraControl])
                    .frame(width: 500, height: 500)
                    .border(Color.red)
                    .padding()
                SceneView(scene: modified, options: [.autoenablesDefaultLighting,.allowsCameraControl])
                    .frame(width: 500, height: 500)
                    .border(Color.green)
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
