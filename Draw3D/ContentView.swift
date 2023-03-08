//
//  ContentView.swift
//  Draw3D
//
//  Created by Johannes Brands on 26/10/2022.
//

import SwiftUI
import SceneKit
import PencilKit
import RealityKit

struct ContentView: View {
    @EnvironmentObject var dm: DrawingModel

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.undoManager) var undoManager
    
    let modelCanvas = PKCanvasView()
    @State internal var showWireFrame = false
    
    let picker = PKToolPicker()
    
    @State private var isShowingToolPicker = true
    @State internal var isPresentingConfirm = false
    @State internal var isPresentingFileImport = false
    
    @State internal var modelCanMove = true
    @State internal var drawingDidChange = false
        
    @State internal var scene: SCNScene? = triangleScene
    @State internal var renderer: SCNSceneRenderer?

    @State internal var originalTexture: UIImage?
//    @State internal var modifiedTexture: UIImage?
    @State private var textureViewSize = CGSize.zero
    
    @State internal var axes: SCNNode?
    @State internal var nozzle: SCNNode?

    @State internal var hits: [CGPoint]? = []

    var models = ["one", "two"]
    @State private var selection: Set<String> = []
    
    var body: some View {
        NavigationSplitView {
            List(models, id: \.self, selection: $selection) { group in
                Text(group)
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    ImportButton()
                    CaptureButton()
                    ExportButton()
                }
            }
        } detail: {
                ZStack {
                    SceneViewContainer(scene: scene, renderer: $renderer, showWireframe: $showWireFrame)
                    PencilViewContainer(canvasView: modelCanvas, picker: picker, drawingDidChange: $drawingDidChange)
                        .disabled(modelCanMove)
                }
                .overlay(alignment: .bottomTrailing) {
                    Image(uiImage: originalTexture!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .shadow(color: .black, radius: 5, x: 5, y: 5)
                        .padding(50)
                }
            
            .onChange(of: drawingDidChange) { _ in
                
//                let adjustedStrokes = modelCanvas.drawing.strokes.map { stroke -> PKStroke in
//                    var stroke = stroke
//
//                    stroke.ink = PKInk(.pen, color: .clear)
//
//                    let newPoints = stroke.path.indices.compactMap { index -> PKStrokePoint? in
//                        let point = stroke.path[index]
//
//                        guard let texturePoint = textureCoordinateFromScreenCoordinate(with: renderer, of: point.location) else { return nil }
//
//                        let newLocation = CGPoint(x: textureViewSize.width * texturePoint.x, y: textureViewSize.height * texturePoint.y)
//
//                        let adjustedPoint = PKStrokePoint(
//                            location: newLocation,
//                            timeOffset: point.timeOffset,
//                            size: point.size,
//                            opacity: point.opacity,
//                            force: point.force,
//                            azimuth: point.azimuth,
//                            altitude: point.altitude)
//
//                        return adjustedPoint
//                    }
//
//                    stroke.path = PKStrokePath(
//                        controlPoints: newPoints,
//                        creationDate: stroke.path.creationDate)
//
//                    return stroke
//                }
                
                for stroke in modelCanvas.drawing.strokes {
                    for index in stroke.path.indices {
                        let point = stroke.path[index]
                        _ = textureCoordinateFromScreenCoordinate(with: renderer, of: point.location)
                    }
                }
                
                modelCanvas.drawing.strokes.removeAll()
                
            }
            
            
            .navigationTitle("baloney")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    MoveDrawToggle()
                    RunButton()
                    TechnicalButton()
                }
                ToolbarItemGroup(placement: .secondaryAction) {
                    UndoButton()
                    RedoButton()
                    EraseButton()
                }
            }
            .toolbarRole(.editor)
//                        .labelStyle(VerticalLabelStyle())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let previewURL = URL(fileURLWithPath: "/Users/janwillem/Documents/Captures/bronze.usdz")
    static let previewScene = try? SCNScene(url: previewURL)
    
    static var previews: some View {
        ContentView(originalTexture: UIImage(named: "KanaKanaTexture")!)
            .environmentObject(DrawingModel())

    }
}
