//
//  ContentView.swift
//  Draw3D
//
//  Created by Johannes Brands on 26/10/2022.
//

import SwiftUI
import SceneKit
import PencilKit

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.undoManager) var undoManager
    
    let modelCanvas = PKCanvasView()
    @State internal var showWireFrame = false
    
    let textureCanvas = PKCanvasView()
    
    let picker = PKToolPicker()
    
    @State private var isShowingToolPicker = true
    @State internal var isPresentingConfirm = false
    @State internal var isPresentingFileImport = false
    
    @State internal var modelCanMove = true
    @State internal var drawingDidChange = false
    
    @State internal var scene: SCNScene? = triangleScene
    @State internal var renderer: SCNSceneRenderer?

    @State internal var originalTexture: UIImage?
    @State internal var modifiedTexture: UIImage?
    @State private var textureViewSize = CGSize.zero
    
    @State internal var axes: SCNNode?
    
    @State internal var hits: [CGPoint]? = []

    var models = ["one", "two"]
    @State private var selection: Set<String> = []
    
    var body: some View {
        NavigationSplitView {
            List(models, id: \.self, selection: $selection) { group in
                Text(group)
            }
        } detail: {
            HStack {
                ZStack {
                    SceneViewContainer(scene: scene, renderer: $renderer, showWireframe: $showWireFrame)
                        .aspectRatio(1, contentMode: .fit)
                    PencilViewContainer(canvasView: modelCanvas, picker: picker, drawingDidChange: $drawingDidChange)
                        .disabled(modelCanMove)
                }
                .aspectRatio(1, contentMode: .fit)
                .border(Color.primary)
                
                ZStack {
                    Image(uiImage: originalTexture!)
                        .resizable()
                    PencilViewOverlay(canvasView: textureCanvas)
                        .disabled(true)
                }
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onChange(of: geo.size) { newValue in
                                textureViewSize = newValue
                            }
                    }
                )
                .aspectRatio(1, contentMode: .fit)
                .border(Color.primary)
            }
            .onChange(of: drawingDidChange) { _ in
                let adjustedStrokes = modelCanvas.drawing.strokes.map { stroke -> PKStroke in
                    var stroke = stroke
                    
                    stroke.ink = PKInk(.pen, color: .green)
                    
                    let newPoints = stroke.path.indices.compactMap { index -> PKStrokePoint? in
                        let point = stroke.path[index]
                        
                        guard let texturePoint = textureCoordinateFromScreenCoordinate(with: renderer, of: point.location) else { return nil }
                        
                        let location = CGPoint(x: textureViewSize.width * texturePoint.x, y: textureViewSize.height * texturePoint.y)

                        let adjustedPoint = PKStrokePoint(
                            location: location,
                            timeOffset: point.timeOffset,
                            size: point.size,
                            opacity: point.opacity,
                            force: point.force,
                            azimuth: point.azimuth,
                            altitude: point.altitude)
                        return adjustedPoint
                    }
                    
                    stroke.path = PKStrokePath(
                        controlPoints: newPoints,
                        creationDate: stroke.path.creationDate)
                    
                    return stroke
                }
                
                textureCanvas.drawing.strokes.append(contentsOf: adjustedStrokes)
                modelCanvas.drawing.strokes.removeAll()
                
                let transformedDrawing = textureCanvas.drawing.image(from: textureCanvas.bounds, scale: 1)
                modifiedTexture = blend(texture: originalTexture, with: transformedDrawing)

                let modifiedMaterial = SCNMaterial()
                modifiedMaterial.diffuse.contents = modifiedTexture
                
//                mainNode(in: scene)?.geometry?.materials = [modifiedMaterial]
//                mainNode(in: scene)?.geometry?.firstMaterial?.diffuse.contents = modifiedTexture
// REMOVE !!!!
                mainNode(in: scene)?.geometry?.materials = []


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
                    UndoButton()
                    RedoButton()
                    EraseButton()
                    MoveDrawToggle()
                    RunButton()
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
        ContentView(originalTexture: UIImage(named: "KanaKanaTexture")!)
    }
}
