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
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    
//                    model.asset = MDLAsset(url: url)
                    model.asset = MDLAsset(url: url,
                                           vertexDescriptor: nil,
                                           bufferAllocator: nil,
                                           preserveTopology: false,
                                           error: nil)
                    let scene = getSceneFrom(url)
                    model.extractSceneGeometry(from: scene)
                    
                    modelCanvas.drawing = PKDrawing()   // An empty drawing.
                }
            case .failure(let error):
                logger.error("Cannot import file \(error)")
                // TODO: add error popup
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
                let paintedVertexIndices: [Int] = model.colors.enumerated().compactMap { (index, color) in
                    SIMD4<Float>(color) == SIMD4<Float>(model.opaqueRed) ? index : nil
                }
                let path: [Waypoint] = paintedVertexIndices.map { index in
                    Waypoint(position: model.vertices[index], orientation: model.normals[index])
                }
                let optimalPath = optimized(path)
                
                let nozzle = nozzle
                model.paintScene.rootNode.addChildNode(nozzle)
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
                    addAxes(to: model.paintScene)
                    addNozzle(to: model.paintScene)
                } else {
                    removeAxes(from: model.paintScene)
                    removeNozzle(from: model.paintScene)
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
            
            let mdlMeshes = mdlAsset.childObjects(of: MDLMesh.self) as? [MDLMesh]
            let firstMesh = mdlMeshes?.first
            let firstSubmesh = firstMesh?.submeshes?.firstObject as? MDLSubmesh
            let mdlMaterial = firstSubmesh?.material
            let baseColor = mdlMaterial?.property(with: .baseColor)
            let textureSamplerValue = baseColor?.textureSamplerValue
            let mdlTexture = textureSamplerValue?.texture
            if let imageFromTexture = mdlTexture?.imageFromTexture()?.takeUnretainedValue() {
                model.texture = UIImage(cgImage: imageFromTexture)
            } else {
                model.texture = scene.rootNode.childNodes.first?.geometry?.firstMaterial?.diffuse.contents as? UIImage ?? UIImage(named: "KanaKanaTexture")!
            }
        }
        return scene
    }
}
