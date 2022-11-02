//
//  ContentView.swift
//  Draw3D
//
//  Created by Johannes Brands on 26/10/2022.
//

import SwiftUI
import SceneKit
import PencilKit
import CoreGraphics

//func update(texture: inout NSImage, at: CGPoint) {
//    let synthImage = NSImage(named: "KanaKanaTexture")
//    let synthImage = NSImage(size: NSSize(width: 1024, height: 1024))
//    texture.lockFocus()
//
//    texture.unlockFocus()
//    let gc = NSGraphicsContext()
//
//    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1024, height: 1024))
//
//    let img = renderer.image { ctx in
//        let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512)
//
//        ctx.cgContext.setFillColor(NSColor.red.cgColor)
//        ctx.cgContext.setStrokeColor(NSColor.black.cgColor)
//        ctx.cgContext.setLineWidth(10)
//
//        ctx.cgContext.addRect(rectangle)
//        ctx.cgContext.drawPath(using: .fillStroke)
//    }
//
////    imageView.image = img
//    return img
//
//    let sourceTexture = CGImage(pngDataProviderSource: <#T##CGDataProvider#>, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
//    var image: NSImage?
//    image = NSImage(cgImage: sourceTexture, size: .zero)
//    return image
//}

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.undoManager) internal var undoManager
    
    let canvasView3D = PKCanvasView()
    let canvasView2D = PKCanvasView()
    let picker = PKToolPicker()
    
    @State private var isShowingToolPicker = true
    @State internal var isShowingTechnical = false
    @State internal var isPresentingConfirm = false
    @State internal var isPresentingFileImport = false
    @State internal var isPositioning = true

    @State internal var scene: SCNScene?
    @State internal var texture: UIImage?
    @State internal var axes: SCNNode?
    
    @State internal var hits: [CGPoint] = []
        
    // TODO: change to URL
    var models = ["one", "two"]
    @State private var selection: Set<String> = []
    
    var body: some View {
        NavigationSplitView {
            List(models, id: \.self, selection: $selection) { group in
                Text(group)
            }
        } detail: {
            HStack {
                // The left view shows the 3D model with the PencilKit painting on top.
                ZStack {
//                    SceneView(scene: scene, pointOfView: SCNNode(), options: [.autoenablesDefaultLighting, .allowsCameraControl])
                        
                    SceneViewRepresentatable(scene: scene, showTechnical: $isShowingTechnical)
                        .aspectRatio(1, contentMode: .fit)
                    PencilViewRepresentable(canvasView: canvasView3D, picker: picker)
//                        .onChange(of: canvasView3D.drawing.strokes.count) { _ in
//                            debugPrint("wow")
//                        }
                    // TODO: move this into the UIViewRepresentable?
                        .disabled(isPositioning)
                }
                .aspectRatio(1, contentMode: .fit)
                .border(Color.primary)
                
                // The right view shows the texture with the synthetic painting on top.
                ZStack {
                    Image(uiImage: texture ?? UIImage(named: "KanaKanaTexture")!)
                        .resizable()
//                    PencilViewOverlay(canvasView: canvasView2D, sourceView: canvasView3D, picker: picker)
//                        .disabled(true)
//                        .allowsHitTesting(false)
                }
                .aspectRatio(1, contentMode: .fit)
                .border(Color.primary)
            }
//            .navigationTitle("baloney")
//            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    ImportButton()
                    CaptureButton()
                    ExportButton()
                }
                
                ToolbarItemGroup(placement: .secondaryAction) {
                    ControlGroup {
                        UndoButton()
                        RedoButton()
                        EraseButton()
                    }
                    
                    ControlGroup {
                        MoveDrawToggle()
                        HitButton()
                    }
                    
                    TechnicalButton()
                }
            }
            .toolbarRole(.editor)
            //            .labelStyle(VerticalLabelStyle())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let previewURL = URL(fileURLWithPath: "/Users/janwillem/Documents/Captures/bronze.usdz")
    static let previewScene = try? SCNScene(url: previewURL)
    
    static var previews: some View {
        ContentView()
    }
}
