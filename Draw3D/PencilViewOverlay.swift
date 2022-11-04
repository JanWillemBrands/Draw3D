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

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
