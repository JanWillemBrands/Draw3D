//
//  ToolbarButtons.swift
//  Draw3D
//
//  Created by Johannes Brands on 01/11/2022.
//

import SwiftUI
import SceneKit
import PencilKit
import UniformTypeIdentifiers

extension ContentView {
    
    var stl: UTType { UTType(filenameExtension: "stl")! }
    var obj: UTType { UTType(filenameExtension: "obj")! }
    var mtl: UTType { UTType(filenameExtension: "mtl")! }
    
    @ViewBuilder func ImportButton() -> some View {
        Button(
            action: { isPresentingFileImport = true},
            label: { Label("Import", systemImage: "square.and.arrow.down") }
        )
        .fileImporter(isPresented: $isPresentingFileImport, allowedContentTypes: [UTType.usdz, UTType.threeDContent, stl, obj]) { result in
            switch result {
            case .success(let url):
                modelCanvas.drawing = PKDrawing()
                if url.startAccessingSecurityScopedResource()
                {
                    dm.getModelFrom(url)
                    url.stopAccessingSecurityScopedResource()
                }
            case .failure(let error):
                logger.error("Cannot import file \(error)")
            }
        }
    }
    
    @ViewBuilder func CaptureButton() -> some View {
        Button(
            action: { logger.debug("Capture")},
            label: { Label("Capture", systemImage: "plus.viewfinder") }
        )
    }
    
    @ViewBuilder func ExportButton() -> some View {
        Button(
            action: {},
            label: { Label("Export", systemImage: "square.and.arrow.up") }
        )
    }
    
    @ViewBuilder func UndoButton() -> some View {
        Button(
            action: { undoManager?.undo() },
            label: { Label("Undo", systemImage: "arrow.uturn.backward") }
        )
    }
    
    @ViewBuilder func RedoButton() -> some View {
        Button(
            action: { undoManager?.redo() },
            label: { Label("Redo", systemImage: "arrow.uturn.forward") }
        )
    }
    
    @ViewBuilder func EraseButton() -> some View {
        Button(
            action: { isPresentingConfirm = true },
            label: { Label("Erase", systemImage: "eraser") }
        )
        .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
            Button("Erase drawing?", role: .destructive) {
                modelCanvas.drawing = PKDrawing()
            }
        } message: {
            Text("You cannot undo this action.")
        }
    }
    
    @ViewBuilder func MoveDrawToggle() -> some View {
        Button(
            action: { modelCanMove.toggle() },
            label: { modelCanMove ? Label("Move", systemImage: "move.3d") : Label("Draw", systemImage: "scribble.variable") }
        )
        .foregroundColor(Color("Laguna"))
    }
    
    @ViewBuilder func RunButton() -> some View {
        Button(
            action: {
                let paintedVertexIndices: [Int] = dm.colors.enumerated().compactMap { (index, color) in
                    color.x == 1 ? index : nil
                }
                let path: [Waypoint] = paintedVertexIndices.map { index in
                    Waypoint(position: SIMD3<Float>(dm.vertices[index]), orientation: SIMD3<Float>(dm.normals[index]))
                }
                
                let optimalPath = optimized(path)
                
                let nzl = nozzle
                dm.scene.rootNode.addChildNode(nzl)
                move(node: nzl, along: optimalPath)
                // Do not yet remove the nozzle in this closure, the move animation extends beyond it.
                // scene?.rootNode.childNode(withName: "nozzle", recursively: true)?.removeFromParentNode()
            },
            label: { Label("Run", systemImage: "figure.run") }
        )
    }
    
    @ViewBuilder func TechnicalButton() -> some View {
        Button(
            action: {
                debugPrint("PoV \(String(describing: renderer?.pointOfView))")
                showWireFrame.toggle()
                if showWireFrame {
                    dm.scene.rootNode.addChildNode(axes)
                } else {
                    dm.scene.rootNode.childNode(withName: "axes", recursively: true)?.removeFromParentNode()
                }
            },
            label: { Label("Ruler", systemImage: "ruler") }
        )
    }
    
}
