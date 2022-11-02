//
//  PencilViewOverlay.swift
//  Draw3D
//
//  Created by Johannes Brands on 30/10/2022.
//

import SwiftUI
import PencilKit

struct PencilViewOverlay: UIViewRepresentable {
    let canvasView: PKCanvasView
    var sourceView: PKCanvasView
    let picker: PKToolPicker

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput
        canvasView.becomeFirstResponder()
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        picker.addObserver(canvasView)
        picker.setVisible(true, forFirstResponder: uiView)
        uiView.tool = PKInkingTool(.pen, color: .blue, width: 5)
        for stroke in sourceView.drawing.strokes {
            uiView.drawing.strokes.append(stroke)
        }
        DispatchQueue.main.async {
            uiView.becomeFirstResponder()
        }
    }
}
