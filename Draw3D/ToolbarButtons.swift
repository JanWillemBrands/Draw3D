//
//  ToolbarButtons.swift
//  Draw3D
//
//  Created by Johannes Brands on 01/11/2022.
//

import SwiftUI
import PencilKit

extension ContentView {
    
    @ViewBuilder func ImportButton() -> some View {
        Button(
            action: { isPresentingFileImport = true},
            label: { Label("Import", systemImage: "square.and.arrow.down") }
        )
        .fileImporter(isPresented: $isPresentingFileImport, allowedContentTypes: [.usdz]) { result in
            switch result {
            case .success(let url):
                modelCanvas.drawing = PKDrawing()
                textureCanvas.drawing = PKDrawing()
                if url.startAccessingSecurityScopedResource() {
                    (scene, originalTexture) = getModelFrom(url)
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
                hits = findTextureHits(with: renderer, of: CGPoint(x: 250, y: 250))
                modifiedTexture = apply(hits, to: originalTexture)
                mainNode(in: scene)?.geometry?.firstMaterial?.diffuse.contents = modifiedTexture
            },
            label: { Label("Run", systemImage: "figure.run") }
        )
    }
    
    @ViewBuilder func TechnicalButton() -> some View {
        Button(
            action: {
                debugPrint("PoV \(String(describing: renderer?.pointOfView))")
                showWireFrame.toggle()
                if let scene {
                    if showWireFrame {
                        axes = addAxes(to: scene)
                    } else {
                        removeAxes(node: axes)
                    }
                }
            },
            label: { Label("Ruler", systemImage: "ruler") }
        )
    }
    
}
