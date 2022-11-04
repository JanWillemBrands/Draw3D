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
    @State internal var isShowingTechnical = false
    
    let textureCanvas = PKCanvasView()
    
    let picker = PKToolPicker()
    
    @State private var isShowingToolPicker = true
    @State internal var isPresentingConfirm = false
    @State internal var isPresentingFileImport = false
    
    @State internal var modelCanMove = true
    @State internal var drawingDidChange = false
    
    @State internal var scene: SCNScene?
    @State internal var renderer: SCNSceneRenderer?

    @State internal var originalTexture: UIImage?
    @State internal var modifiedTexture: UIImage?
    
//    @State internal var texture: UIImage?
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
                    SceneViewContainer(scene: scene, renderer: $renderer, showTechnical: $isShowingTechnical)
                        .aspectRatio(1, contentMode: .fit)
                    PencilViewContainer(canvasView: modelCanvas, picker: picker, canvasViewDrawingDidChange: $drawingDidChange)
                        .disabled(modelCanMove)
                }
                .frame(width: 500, height: 500)
                .aspectRatio(1, contentMode: .fit)
                .border(Color.primary)
                
                ZStack {
                    Image(uiImage: originalTexture!)
//                    Image(uiImage: modifiedTexture ?? originalTexture!)
                        .resizable()
                    PencilViewOverlay(canvasView: textureCanvas)
                        .disabled(true)
                }
                .frame(width: 500, height: 500)
                .aspectRatio(1, contentMode: .fit)
                .border(Color.primary)
            }
            .onAppear {
                
            }
            .onChange(of: drawingDidChange) { _ in
                debugPrint("strokes \(modelCanvas.drawing.strokes.count)")
                
                let adjustedStrokes = modelCanvas.drawing.strokes.map { stroke -> PKStroke in
                    var stroke = stroke
                    
                    stroke.ink = PKInk(.pen, color: .green)
                    let newPoints = stroke.path.indices.compactMap { index -> PKStrokePoint? in
                        let point = stroke.path[index]
                        
                        guard let texturePoint = textureCoordinateFromScreenCoordinate(with: renderer, of: point.location) else { return nil }
                        
                        debugPrint("TP \(texturePoint)")
                        debugPrint("pl \(point.location)")
                        
                        let adjustedPoint = PKStrokePoint(
                            location: CGPoint(x: 500*texturePoint.x, y: 500*texturePoint.y),
//                            location: point.location,
                            timeOffset: point.timeOffset,
//                            size: CGSize(width: 100, height: 100),
                            size: point.size,
//                            size: CGSize(width: point.size.width * 0.5, height: point.size.height * 0.5),
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
                mainNode(in: scene)?.geometry?.firstMaterial?.diffuse.contents = modifiedTexture
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
