//
//  ContentView.swift
//  Draw3D
//
//  Created by Johannes Brands on 26/10/2022.
//

import SwiftUI
import SceneKit
import SceneKit.ModelIO
import PencilKit
import RealityKit

struct ContentView: View {
    
    @StateObject var model = PaintableModel()
    
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
        
//    @State internal var scene: SCNScene = triangleScene
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
                    SceneViewContainer(scene: model.paintScene, renderer: $renderer, showWireframe: $showWireFrame)
                    PencilViewContainer(canvasView: modelCanvas, picker: picker, drawingDidChange: $drawingDidChange)
                        .disabled(modelCanMove)
                }
                .overlay(alignment: .bottomTrailing) {
                    if showWireFrame {
                        Image(uiImage: model.texture)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .padding(50)
                    }
                }
            
            .onChange(of: drawingDidChange) { _ in
                
                for stroke in modelCanvas.drawing.strokes {
//                    let _ = stroke.path.map { element in element.location }
                    for index in stroke.path.indices {
                        let point = stroke.path[index]
//                        _ = textureCoordinateFromScreenCoordinate(with: renderer, of: point.location)
                        model.paintTriangleFace(of: renderer, at: point.location)
                    }
                }
                
                modelCanvas.drawing.strokes.removeAll()
            }
            
            
            .navigationTitle("baloney")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    MoveButton()
                    DrawButton()
                    RunButton()
                    InspectButton()
                }
                ToolbarItemGroup(placement: .secondaryAction) {
                    UndoButton()
                    RedoButton()
                    EraseButton()
                }
            }
            .toolbarRole(.editor)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
