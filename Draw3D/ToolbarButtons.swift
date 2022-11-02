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
                if url.startAccessingSecurityScopedResource() {
                    (scene, texture) = getModelFrom(url)
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
            action: { debugPrint(canvasView3D.drawing.strokes.count)
                let adjustedStrokes = canvasView3D.drawing.strokes.map { stroke -> PKStroke in
                    var stroke = stroke
                    // Adjust the stroke ink to be black.
                    stroke.ink = PKInk(.pen, color: .black)
                    
                    // Adjust the stroke widths to be more uniform.
                    let newPoints = stroke.path.indices.compactMap { index -> PKStrokePoint? in
                        let point = stroke.path[index]
                        let adjustedPoint = PKStrokePoint(
                            location: point.location,
                            timeOffset: point.timeOffset,
                            size: CGSize(width: point.size.width * 0.5, height: point.size.height * 0.5),
                            opacity: point.opacity,
                            force: point.force,
                            azimuth: point.azimuth,
                            altitude: point.altitude)
                        return adjustedPoint
                    }
                    stroke.path = PKStrokePath(controlPoints: newPoints, creationDate: stroke.path.creationDate)
                    
                    return stroke
                }
                
                canvasView3D.drawing.strokes.append(contentsOf: adjustedStrokes)
                },
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
                canvasView3D.drawing = PKDrawing()
            }
        } message: {
            Text("You cannot undo this action.")
        }
    }
    
    @ViewBuilder func MoveDrawToggle() -> some View {
        Button(
            action: { isPositioning.toggle() },
            label: { isPositioning ? Label("Move", systemImage: "move.3d") : Label("Draw", systemImage: "scribble.variable") }
        )
        .foregroundColor(Color("Laguna"))
    }
    
    @ViewBuilder func HitButton() -> some View {
        Button(
            action: {
                hits = findHits(in: scene)
                texture = apply(hits, to: texture)
                //                                texture = updateTexture(of: &scene, and: texture, with: UIImage(named: "apple"))
                mainNode(in: scene)?.geometry?.firstMaterial?.diffuse.contents = texture
            },
            label: { Label("Hits \(hits.count)", systemImage: "figure.run") }
        )
    }
    
    @ViewBuilder func TechnicalButton() -> some View {
        Button(
            action: {
                isShowingTechnical.toggle()
                if let scene {
                    if isShowingTechnical {
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
