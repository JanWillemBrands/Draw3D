//
//  PencilViewContainer.swift
//  Draw3D
//
//  Created by Johannes Brands on 27/10/2022.
//

import SwiftUI
import PencilKit

struct PencilViewContainer: UIViewRepresentable {
    let canvasView: PKCanvasView
    let picker: PKToolPicker
    
    @Binding var drawingDidChange: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput
        canvasView.becomeFirstResponder()
        canvasView.delegate = context.coordinator
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
//        picker.addObserver(canvasView3D)
//        picker.setVisible(true, forFirstResponder: uiView)
        uiView.tool = PKInkingTool(.pen, color: .green, width: 50)
        DispatchQueue.main.async {
            uiView.becomeFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PencilViewContainer
        
        init(_ view: PencilViewContainer) {
            self.parent = view
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            print("drawing strokes \(canvasView.drawing.strokes.count)")
            if !canvasView.drawing.bounds.isEmpty {
                print("drawing changed")
                parent.drawingDidChange.toggle()
            }
        }
        
        func canvasViewDidFinishRendering(_ canvasView: PKCanvasView) {
//            debugPrint("rendered \(canvasView.drawing.strokes.count)")
        }
        
        func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
//            debugPrint("beginTool \(canvasView.drawing.strokes.count)")
        }
        
        func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
//            debugPrint("endTool \(canvasView.drawing.strokes.count)")
        }
    }
    
}
