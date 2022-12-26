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
    @EnvironmentObject var dm: DrawingModel
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.undoManager) var undoManager
    
    let modelCanvas = PKCanvasView()
    
    let picker = PKToolPicker()
    
    @State internal var showWireFrame = false
    @State private var isShowingToolPicker = true
    @State internal var isPresentingConfirm = false
    @State internal var isPresentingFileImport = false
    @State internal var modelCanMove = true
    @State internal var drawingDidChange = false
    
    @State internal var renderer: SCNSceneRenderer?
    
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
                SceneViewContainer(scene: dm.scene, renderer: $renderer, showWireframe: $showWireFrame)
                PencilViewContainer(canvasView: modelCanvas, picker: picker, drawingDidChange: $drawingDidChange)
                    .disabled(modelCanMove)
            }
            .onChange(of: drawingDidChange) { _ in
                var dots: [PKStroke] = []
                for stroke in modelCanvas.drawing.strokes {
                    for point in stroke.path.interpolatedPoints(by: .distance(10)) {
                        dm.changeColorOfFaceRenderedAtScreenCoordinate(with: renderer, of: point.location)
                        let ink = PKInk(.pen, color: .systemYellow)
                        let dotPoint = PKStrokePoint(
                            location: point.location,
                            timeOffset: point.timeOffset,
                            size: CGSize(width: 5.0, height: 5.0),
                            opacity: 2.0,
                            force: 1.0,
                            azimuth: 0.0,
                            altitude: 0.0)
                        
                        // Create a single-point path (a 'dot') for every control point.
                        let dotPath = PKStrokePath(controlPoints: [dotPoint], creationDate: .now)
                        let dotStroke = PKStroke(ink: ink, path: dotPath)
                        dots.append(dotStroke)
                    }
                }
                modelCanvas.drawing.strokes.removeAll()
                modelCanvas.drawing.strokes.append(contentsOf: dots)
            }
            
            //                .onChange(of: drawingDidChange) { _ in
            //                    let adjustedStrokes = modelCanvas.drawing.strokes.map { stroke -> PKStroke in
            //                        var stroke = stroke
            //
            //                        // TODO: REMOVE !!!
            //                        stroke.ink = PKInk(.pen, color: .clear)
            //    //                    stroke.ink = PKInk(.pen, color: .green)
            //
            //                        let newPoints = stroke.path.indices.compactMap { index -> PKStrokePoint? in
            //                            let point = stroke.path[index]
            //
            //                            guard let texturePoint = textureCoordinateFromScreenCoordinate(with: renderer, of: point.location) else { return nil }
            //
            //                            let newLocation = CGPoint(x: textureViewSize.width * texturePoint.x, y: textureViewSize.height * texturePoint.y)
            //
            //                            let adjustedPoint = PKStrokePoint(
            //                                location: newLocation,
            //                                timeOffset: point.timeOffset,
            //                                size: point.size,
            //                                opacity: point.opacity,
            //                                force: point.force,
            //                                azimuth: point.azimuth,
            //                                altitude: point.altitude)
            //
            //                            return adjustedPoint
            //                        }
            //
            //                        stroke.path = PKStrokePath(
            //                            controlPoints: newPoints,
            //                            creationDate: stroke.path.creationDate)
            //
            //                        return stroke
            //                    }
            //
            //                    modelCanvas.drawing.strokes.removeAll()
            //
            //                    // TODO: why is this copy necessary to remove flickering when rotating model?
            //                    let material = SCNMaterial()
            //                    material.diffuse.contents = originalTexture
            //    //                let mainNode = scene?.rootNode.childNodes.first
            //                    let mainNode = scene?.rootNode.childNode(withName: "g0", recursively: true)
            //                    mainNode?.geometry?.materials = [material]
            //                }
            
            
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
            .labelStyle(VerticalLabelStyle())
        }
    }
}

struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
#if os(iOS)
        //        Label(configuration.title, image: configuration.icon)
        configuration.icon
#else
        Label(configuration.title, image: configuration.icon)
#endif
    }
}

struct ContentView_Previews: PreviewProvider {
    //    static let previewURL = URL(fileURLWithPath: "/Users/janwillem/Documents/Captures/bronze.usdz")
    //    static let previewScene = try? SCNScene(url: previewURL)
    
    static var previews: some View {
        ContentView()
            .environmentObject(DrawingModel())
    }
}
