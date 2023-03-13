//
//  ToolbarButtons.swift
//  Draw3D
//
//  Created by Johannes Brands on 01/11/2022.
//

import SwiftUI
import SceneKit
import SceneKit.ModelIO
import PencilKit
import UniformTypeIdentifiers

extension ContentView {
    
    var stl: UTType { UTType(filenameExtension: "stl")! }
    var obj: UTType { UTType(filenameExtension: "obj")! }
    //    var mtl: UTType { UTType(filenameExtension: "mtl")! }
    
    @ViewBuilder func ImportButton() -> some View {
        Button(
            action: { isPresentingFileImport = true},
            label: { Label("Import", systemImage: "square.and.arrow.down") }
        )
        .fileImporter(isPresented: $isPresentingFileImport, allowedContentTypes: [UTType.usdz, UTType.threeDContent, stl, obj]) { result in
            switch result {
            case .success(let url):
                modelCanvas.drawing = PKDrawing()   // An empty drawing.
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    scene = getSceneFrom(url)
                    model = PaintableModel(from: scene)
                }
            case .failure(let error):
                logger.error("Cannot import file \(error)")
                //                fatalError("Cannot import file \(error)")
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
                modelCanvas.drawing = PKDrawing()   // An empty drawing.
            }
        } message: {
            Text("You cannot undo this action.")
        }
    }
    
    @ViewBuilder func MoveButton() -> some View {
        Button(
            action: { modelCanMove = true },
            label: { Label("Move", systemImage: "move.3d") }
            
        )
        .labelStyle(.titleAndIcon)
        .foregroundColor( modelCanMove ? Color("Laguna") : .accentColor)
    }
    
    @ViewBuilder func DrawButton() -> some View {
        Button(
            action: { modelCanMove = false },
            label: { Label("Draw", systemImage: "scribble.variable") }
            
        )
        .labelStyle(.titleAndIcon)
        .foregroundColor( !modelCanMove ? Color("Laguna") : .accentColor)
    }
    
    @ViewBuilder func RunButton() -> some View {
        Button(
            action: {
                let paintedVertexIndices: [Int] = vertexColor.enumerated().compactMap { (index, color) in
                    color.x == 1 ? index : nil
                }
                let path: [Waypoint] = paintedVertexIndices.map { index in
                    Waypoint(position: vertices[index], orientation: normals[index])
                }
                let optimalPath = optimized(path)
       
                let nozzle = nozzle
                scene.rootNode.addChildNode(nozzle)
                move(node: nozzle, along: optimalPath)
            },
            label: { Label("Run", systemImage: "figure.run") }
        )
        .labelStyle(.titleAndIcon)
    }
    
    @ViewBuilder func InspectButton() -> some View {
        Button(
            action: {
                debugPrint("PoV \(String(describing: renderer?.pointOfView))")
                showWireFrame.toggle()
                if showWireFrame {
                    addAxes(to: scene)
                    addNozzle(to: scene)
                } else {
                    removeAxes(from: scene)
                    removeNozzle(from: scene)
                }
            },
            label: { Label("Inspect", systemImage: "ruler") }
        )
        .labelStyle(.titleAndIcon)
    }
    
    func getSceneFrom(_ url: URL) -> SCNScene {
        var scene: SCNScene
        //        var texture: UIImage?
        
        if url.pathExtension == "usdz" {
            do {
                scene = try SCNScene(url: url, options: [.checkConsistency: true])
            } catch {
                fatalError("Unable to load scene file.")
            }
        } else {
            let mdlAsset = MDLAsset(url: url)
            mdlAsset.loadTextures()
            scene = SCNScene(mdlAsset: mdlAsset)
            
            //            let mdlMeshes = mdlAsset.childObjects(of: MDLMesh.self) as? [MDLMesh]
            //            let firstMesh = mdlMeshes?.first
            //            let firstSubmesh = firstMesh?.submeshes?.firstObject as? MDLSubmesh
            //            let mdlMaterial = firstSubmesh?.material
            //            let baseColor = mdlMaterial?.property(with: .baseColor)
            //            let textureSamplerValue = baseColor?.textureSamplerValue
            //            let mdlTexture = textureSamplerValue?.texture
            //            if let imageFromTexture = mdlTexture?.imageFromTexture()?.takeUnretainedValue() {
            //                texture = UIImage(cgImage: imageFromTexture)
            //            } else {
            //                texture = scene.rootNode.childNodes.first?.geometry?.firstMaterial?.diffuse.contents as? UIImage
            //            }
        }
        
        // TODO: why is this necessary to remove flickering when rotating model?
        //        let material = SCNMaterial()
        //        material.diffuse.contents = texture
        //
        //        mainNode(in: scene)?.geometry?.materials = [material]
        
        return scene
    }
    
    
}
